#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

INSTANCE_NO=4
WATCH_INTERVAL=3

PROJECT=$(grep COMPOSE_PROJECT_NAME .env | cut -d'=' -f2)

if [ "$(uname -m)" = "armv7l" ]; then
  COMPOSE= docker-compose-arm32v7.yml
else
  COMPOSE=docker-compose.yml
fi

function stop_iroha {
  if docker ps | grep -q ${PROJECT}_node${FAILED_INSTANCE}_1; then
    echo "# docker stop ${PROJECT}_node${FAILED_INSTANCE}_1"
    docker stop ${PROJECT}_node${FAILED_INSTANCE}_1
  fi
  if docker ps | grep -q ${PROJECT}_postgres${FAILED_INSTANCE}_1; then
    echo "# docker stop ${PROJECT}_postgres${FAILED_INSTANCE}_1"
    docker stop ${PROJECT}_postgres${FAILED_INSTANCE}_1
  fi
  if docker ps | grep -q ${PROJECT}_redis${FAILED_INSTANCE}_1; then
    echo "# docker stop ${PROJECT}_redis${FAILED_INSTANCE}_1"
    docker stop ${PROJECT}_redis${FAILED_INSTANCE}_1
  fi
}

function start_iroha {
  DIR=$(pwd)
  cd node${INSTANCE_NO}
  echo "# docker-compose -p ${PROJECT} -f ${COMPOSE} up -d"
  docker-compose -p ${PROJECT} -f ${COMPOSE} up -d
  cd ${DIR}
}

while true; do
  for i in $(seq ${INSTANCE_NO}); do
    if ! docker ps | grep -q ${PROJECT}_redis${i}_1; then
      echo "ERROR ${PROJECT}_redis${i}_1 stopped!!"
      FAILED_INSTANCE=${i}
      stop_iroha
      start_iroha
    fi
    if ! docker ps | grep -q ${PROJECT}_postgres${i}_1; then
      echo "ERROR ${PROJECT}_postgres${i}_1 stopped!!"
      FAILED_INSTANCE=${i}
      stop_iroha
      start_iroha
    fi
    if ! docker ps | grep -q ${PROJECT}_node${i}_1; then
      FAILED_INSTANCE=${i}
      echo "ERROR ${PROJECT}_node${i}_1 stopped!!"
      stop_iroha
      start_iroha
    fi
  done

  sleep ${WATCH_INTERVAL}
done
