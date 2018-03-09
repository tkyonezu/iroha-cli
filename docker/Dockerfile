# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

FROM ubuntu:16.04

RUN apt update \
 && apt upgrade -y

RUN apt -y install cmake gcc g++ git python3 python3-pip \
 && apt clean -y

RUN git clone https://github.com/tkyonezu/iroha-cli.git \
 && cd iroha-cli \
 && sed -i "s/m = bytearray.fromhex(message.decode('utf-8'))/m = message/" iroha_cli/crypto_ed25519.py \
 && pip3 install -r requirements.txt \
 && python3 setup.py install \
 && python3 setup.py develop

CMD ["/bin/bash"]
