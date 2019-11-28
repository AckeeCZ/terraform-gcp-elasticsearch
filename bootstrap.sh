#!/bin/bash

set -ueo pipefail

echo "/dev/disk/by-id/google-elasticpd /var/lib/elasticsearch ext4 defaults 0 0" >> /etc/fstab
lsblk -o label /dev/disk/by-id/google-elasticpd | grep -q elastic-data || mkfs.ext4 -L elastic-data /dev/disk/by-id/google-elasticpd
mount /var/lib/elasticsearch
chown elasticsearch:elasticsearch /var/lib/elasticsearch

systemctl enable elasticsearch.service
