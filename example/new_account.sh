#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

if [ $# -eq 0 ]; then
  echo "Usage: $0 <account_name>"
fi

if [ "$(uname -m)" = "armv7l" ]; then
  PROJECT=arm32v7
else
  PROJECT=hyperledger
fi

docker run -t --rm --name iroha-pi -v $(pwd):/opt/iroha/config \
  ${PROJECT}/iroha-pi bash -c "cd /opt/iroha/config; \
    /opt/iroha/bin/iroha-cli --new_account --name ${1} --pass_phrase magicseed${1}" \

exit 0
