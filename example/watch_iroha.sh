#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

SYSLOG=0		# 1=enable 0=disable syslog message

if [ $# -ge 1 ]; then
  INSTANCE_NO=$1
else
  INSTANCE_NO=${INSTANCE_NO:-4}
fi

if [ $# -ge 2 ]; then
  WATCH_INTERVAL=$2
else
  WATCH_INTERVAL=${WATCH_INTERVAL:-3}
fi

PROJECT=$(grep COMPOSE_PROJECT_NAME .env | cut -d'=' -f2)

if [ "$(uname -m)" = "armv7l" ]; then
  COMPOSE= docker-compose-arm32v7.yml
else
  COMPOSE=docker-compose.yml
fi

#
# Syslog messages
#
function syslog {
  LEVEL=$1
  shift

  echo "$(date +'%b %d %H:%M:%S') $(hostname) user.${LEVEL}: $*"
  if [ ${SYSLOG} -eq 1 ]; then
    logger -p user.${LEVEL} "$*"
  fi
}

#
# Stop Iroha containers
#
function stop_iroha {
  for container in node postgres redis; do
    if docker ps | grep -q ${PROJECT}_${container}${FAILED_INSTANCE}_1; then
      echo "# docker stop ${PROJECT}_${container}${FAILED_INSTANCE}_1"
      docker stop ${PROJECT}_${container}${FAILED_INSTANCE}_1
    fi
  done
}

#
# Start Iroha containers
#
function start_iroha {
  DIR=$(pwd)
  cd node${INSTANCE_NO}
  echo "# docker-compose -p ${PROJECT} -f ${COMPOSE} up -d"
  docker-compose -p ${PROJECT} -f ${COMPOSE} up -d
  cd ${DIR}
}

#
# Wait until the container starts up
#
for i in $(seq ${INSTANCE_NO}); do
  for container in redis postgres node; do
    while true; do
      if docker ps | grep -q ${PROJECT}_${container}${i}_1; then
        break
      fi
      sleep 1
    done
    syslog info "${PROJECT}_${container}${i} started up."
  done
done

#
# Watchdog Iroha containers
#
syslog info "INFO Watchdog started redis, postgres, iroha ${INSTANCE_NO} instances."

while true; do
  for i in $(seq ${INSTANCE_NO}); do
    for container in redis postgres node; do
      if ! docker ps | grep -q ${PROJECT}_${container}${i}_1; then
        syslog err "${PROJECT}_${container}${i}_1 stopped."
        FAILED_INSTANCE=${i}
        stop_iroha
        start_iroha
      fi
    done
  done

  sleep ${WATCH_INTERVAL}
done
