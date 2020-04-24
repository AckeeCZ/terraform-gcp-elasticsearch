#!/bin/bash

function fetch_es_pid(){
  ps -e -o pid,cmd | grep [/]usr/share/elasticsearch/bin/elasticsearch | head -n1 | awk '{print $1}'
}

# bootstrap the additional persistent volume for ES data

echo "/dev/disk/by-id/google-elasticpd /var/lib/elasticsearch ext4 defaults 0 0" >> /etc/fstab
lsblk -o label /dev/disk/by-id/google-elasticpd | grep -q elastic-data || mkfs.ext4 -L elastic-data /dev/disk/by-id/google-elasticpd
mount /var/lib/elasticsearch
chown elasticsearch:elasticsearch /var/lib/elasticsearch

# add heredoc for allowing elasticsearch server to be run as standalone binary without systemd support

if ! grep 'elasticsearch soft memlock unlimited' /etc/security/limits.conf; then

(
cat <<ADDTEXT
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
ADDTEXT
) >> /etc/security/limits.conf;

fi

# start elasticsearch server to inspect if cluster is fully discovered and master nodes have been selected
#
# /dev/full usage relates to https://stackoverflow.com/questions/15265228/pipe-to-multiple-files-but-not-stdout
#   it generates error `tee: standard output: No space left on device` but it will stop if file from tee argument is full
#   forwarding to /dev/null would not do that
su elasticsearch -s /bin/bash -c '/usr/share/elasticsearch/bin/elasticsearch | tee /tmp/elasticsearch_bootstrap_start.log >/dev/full' &

echo "waiting for ES7 bootstrap to start"
while ! grep "starting GCE discovery service" /tmp/elasticsearch_bootstrap_start.log; do
  sleep 10
done

# flag which is true until the logs contain a message saying the masters are not discovered
master_settings_missing=false

# this wait for log line 'master not discovered yet, this node has not previously joined a bootstrapped' to appear
#  if so, it will set master_settings_missing to true which allows discovery to begin with list of initial masters
#  if not, it will continue with the rest of the bootstrap script
echo "checking if master selection worked correctly"
while true; do
  if grep "master not discovered yet, this node has not previously joined a bootstrapped" /tmp/elasticsearch_bootstrap_start.log; then
    master_settings_missing=true
    break
  fi
  if curl localhost:9200/_cluster/health?pretty | grep 'status' | grep 'green'; then
    break
  fi
  sleep 10
done

# stop elastic started in this script
es_pid=$(fetch_es_pid)
while kill -0 ${es_pid}; do
  kill ${es_pid}
  sleep 10
done

if [[ ${master_settings_missing} == "true" ]]; then

  # contains the list of master nodes in $master_list, otherwise, there is nothing else in that file
  source /home/devops/master_list.sh

  # this will start elasticsearch only once with setting cluster.initial_master_nodes, this is encouraged in
  #  documentation https://www.elastic.co/guide/en/elasticsearch/reference/master/discovery-settings.html#initial_master_nodes
  #  stating you can use this option once during cluster init and do not use it after restart
  su elasticsearch -s /bin/bash -c "/usr/share/elasticsearch/bin/elasticsearch -Ecluster.initial_master_nodes=${master_list} | tee /tmp/elasticsearch_bootstrap_master_list_start.log >/dev/full" &

  # once the discovery starts, give it a few seconds to finnish
  while ! grep "starting GCE discovery service" /tmp/elasticsearch_bootstrap_master_list_start.log; do
    sleep 10
  done

  while ! curl localhost:9200/_cluster/health?pretty | grep 'status' | grep 'green'; do
    sleep 10
  done

  es_pid=$(fetch_es_pid)
  while kill -0 ${es_pid}; do
    kill ${es_pid}
    sleep 10
  done
fi

systemctl enable elasticsearch.service

if [[ -f /tmp/elasticsearch_bootstrap_start.log ]]; then
  rm /tmp/elasticsearch_bootstrap_start.log
fi
if [[ -f /tmp/elasticsearch_bootstrap_master_list_start.log ]]; then
  rm /tmp/elasticsearch_bootstrap_master_list_start.log
fi
