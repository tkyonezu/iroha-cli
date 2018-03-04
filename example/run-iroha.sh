#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

BLOCK_STORE_PATH=./block_store

IROHA_CONFIG="config/iroha.conf"
GENESIS_BLOCK="config/genesis.block"
KEYPAIR_NAME="${KEYPAIR_NAME:-config/node0}"

if [ -f ${BLOCK_STORE_PATH}/0000000000000001 ]; then
  /opt/iroha/bin/irohad --config ${IROHA_CONFIG} --keypair_name ${KEYPAIR_NAME}
else
  /opt/iroha/bin/irohad --config ${IROHA_CONFIG} --genesis_block ${GENESIS_BLOCK} --keypair_name ${KEYPAIR_NAME}
fi

exit 0
