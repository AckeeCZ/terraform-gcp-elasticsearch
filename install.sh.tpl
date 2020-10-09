#!/bin/bash

set -ue -o pipefail

export ES_VERSION=${es_version}

curl https://raw.githubusercontent.com/AckeeCZ/packer-elasticsearch/master/packer/install.sh > install.sh

if [[ -f install.sh ]];then
  bash install.sh
fi

curl https://raw.githubusercontent.com/AckeeCZ/packer-elasticsearch/master/packer/stackdriver.sh > stackdriver.sh

if [[ -f stackdriver.sh ]];then
  bash stackdriver.sh
fi
