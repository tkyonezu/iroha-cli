#!/bin/bash
#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

apt -y install cmake gcc g++ git python3 python3-pip
apt -y clean

git clone -b feature/remove-redis https://github.com/tkyonezu/iroha-cli.git

cd iroha-cli

pip3 install -r requirements.txt
python3 setup.py install
python3 setup.py develop

exit 0
