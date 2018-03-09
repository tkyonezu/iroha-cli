# Copyright 2018 Takeshi Yonezu All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all setup docker up down logs logs1 up4 down4 logs4 up7 down7 logs7 test test-local test-docker version

IROHA_IMG := $(shell grep IROHA_IMG .env | cut -d"=" -f2)
COMPOSE_PROJECT_NAME := $(shell grep COMPOSE_PROJECT_NAME example/.env | cut -d'=' -f2)

UKERNEL := $(shell uname -s)
UMACHINE := $(shell uname -m)

ifeq ($(UKERNEL),Linux)
  ifeq ($(UMACHINE),x86_64)
    PROJECT := hyperledger
    DOCKER := Dockerfile
    COMPOSE := docker-compose.yml
  endif
  ifeq ($(UMACHINE),armv7l)
    PROJECT := arm32v7
    DOCKER := Dockerfile.arm32v7
    COMPOSE := docker-compose-arm32v7.yml
  endif
endif

ifeq ($(UKERNEL),Darwin)
  PROJECT := hyperledger
  DOCKER := Dockerfile
  COMPOSE := docker-compose.yml
endif

ifeq ($(DOCKER), )
$(error This platform "$(UKERNEL)/$(UMACHINE)" in not supported.)
endif

all: setup

setup:
	sudo bash setup.sh

docker:
	cd docker; docker build --rm -t $(PROJECT)/irohac -f $(DOCKER) .

help:
	@echo "help          - show make targets"
	@echo "all (default) - buid iroha-dev container, and build iroha"
	@echo "setup         - setup irohac on local host"
	@echo "docker        - build irohac container"
	@echo "up            - running iroha container by docker-compose"
	@echo "down          - stop and remove iroha container by docker-compose"
	@echo "logs          - show logs of iroha_node_1 container"
	@echo "logs1         - show logs of iroha_node1_1 container (multi)"
	@echo "test          - exec test commands (local)"
	@echo "test-docker   - exec test commands (docker)"
	@echo "up4           - running iroha container by docker-compose (4 nodes)"
	@echo "down4         - stop and remove iroha container by docker-compose (4 nodes)"
	@echo "logs4         - show logs of iroha_node_1 container (4 nodes)"
	@echo "up7           - running iroha container by docker-compose (7 nodes)"
	@echo "down7         - stop and remove iroha container by docker-compose (7 nodes)"
	@echo "logs7         - show logs of iroha_node_1 container (7 nodes)"
	@echo "version       - show labels in container"

up:
	@cd example; if ! test -d block_store; then mkdir block_store; fi
	cd example; docker-compose -p $(COMPOSE_PROJECT_NAME) -f $(COMPOSE) up -d

down:
	cd example; docker-compose -p $(COMPOSE_PROJECT_NAME)  -f $(COMPOSE) down

up4:
	@cd example/node4; if ! test -d block_store1; then for i in 1 2 3 4; do mkdir block_store$$i; done; fi
	cd example/node4; docker-compose -p $(COMPOSE_PROJECT_NAME) -f $(COMPOSE) up -d

up7:
	@cd example/node7; if ! test -d block_store1; then for i in 1 2 3 4 5 6 7; do mkdir block_store$$i; done; fi
	cd example/node7; docker-compose -p $(COMPOSE_PROJECT_NAME) -f $(COMPOSE) up -d

down4:
	cd example/node4; docker-compose -p $(COMPOSE_PROJECT_NAME)  -f $(COMPOSE) down

down7:
	cd example/node7; docker-compose -p $(COMPOSE_PROJECT_NAME)  -f $(COMPOSE) down

logs:
	docker logs -f iroha_node_1

logs1:
	docker logs -f iroha_node1_1

logs4:
	cd example/node4; bash logs4.sh

logs7:
	cd example/node7; bash logs7.sh

test:
	cd example; bash test-local.sh

test-local: test

test-docker:
	cd example; bash test-docker.sh

version:
	docker inspect -f {{.Config.Labels}} $(PROJECT)/$(IROHA_IMG)
