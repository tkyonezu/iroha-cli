#!/bin/sh

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

for i in $(seq 4); do
  ((n=$i+1))
  docker logs -f iroha_node${i}_1 >/dev/pts/${n} &
done
