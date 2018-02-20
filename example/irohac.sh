#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

if [ $# -lt 2 ]; then
  echo "Usage: irohac <creator_accout> <command> [<args>]" >&2
  exit 1
fi

if [ "$(uname -m)" = "armv7l" ]; then
  PROJECT=arm32v7
else
  PROJECT=hyperledger
fi

# Change localhost to Iroha's real IP address
## IROHA_HOST=localhost:50051
IROHA_HOST=$(docker network inspect bridge | grep Gateway | awk '{ print $2 }' | sed 's/"//g'):50051

CREATOR_ID=$1
shift

docker run -t --rm --name irohac -v $(pwd):/root/.irohac ${PROJECT}/irohac irohac --hostname=${IROHA_HOST} --account_id=${CREATOR_ID} $*

exit 0
