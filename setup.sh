#! /bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-Licence-Identifier: Apache-2.0
#

apt update
apt upgrade -y

apt install -y cmake gcc g++ git python3 python3-pip
apt clean -y

if [ "$(basename $(pwd))" != "iroha-cli" ] || [ ! -f requirements.txt ]; then
  git clone https://github.com/tkyonezu/iroha-cli.git
  cd iroha-cli
fi

pip3 install -r requirements.txt
python3 setup.py install
python3 setup.py develop

exit 0
