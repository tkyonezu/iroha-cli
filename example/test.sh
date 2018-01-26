#!/bin/bash

#
# Copyright 2018 Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Change localhost to Iroha's real IP address
IROHA_HOST=localhost:50051

ADMIN_ID=admin@test
DOMAIN_ID=iroha
ASSET_NAME=usd
ASSET_ID=${ASSET_NAME}#${DOMAIN_ID}
USER1_NAME=alice
USER1_ID=${USER1_NAME}@${DOMAIN_ID}
USER2_NAME=bob
USER2_ID=${USER2_NAME}@${DOMAIN_ID}

if [ "$(uname -m)" = "armv7l" ]; then
  PROJECT=arm32v7
else
  PROJECT=hyperledger
fi

function send {
  echo "=== $* ==="
  read junk

  CREATOR_ID=$1
  shift

  docker run -t --rm --name irohac -v $(pwd):/root/.irohac ${PROJECT}/irohac irohac --hostname=${IROHA_HOST} --account_id=${CREATOR_ID} $*
}

rm -f ${USER1_ID}* ${USER2_ID}*

send ${ADMIN_ID} CreateDomain --default_role user --domain_id ${DOMAIN_ID}

send ${ADMIN_ID} CreateAsset --asset_name ${ASSET_NAME} --domain_id ${DOMAIN_ID}

send ${ADMIN_ID} GetAssetInfo --asset_id ${ASSET_NAME}#${DOMAIN_ID}

send ${ADMIN_ID} CreateAccount --account_name ${USER1_NAME} --domain_id ${DOMAIN_ID}

send ${ADMIN_ID} GetAccount --account_id ${USER1_ID}

send ${ADMIN_ID} CreateAccount --account_name ${USER2_NAME} --domain_id ${DOMAIN_ID}

send ${ADMIN_ID} GetAccount --account_id ${USER2_ID}

send ${ADMIN_ID} AddAssetQuantity --account_id ${USER1_ID} --asset_id ${ASSET_ID} --amount 200

send ${USER1_ID} GetAccountAssets --account_id ${USER1_ID} --asset_id ${ASSET_ID}

send ${ADMIN_ID} AddAssetQuantity --account_id ${USER2_ID} --asset_id ${ASSET_ID} --amount 100

send ${USER2_ID} GetAccountAssets --account_id ${USER2_ID} --asset_id ${ASSET_ID}

send ${ADMIN_ID} TransferAsset --src_account_id ${USER2_ID} --dest_account_id ${USER1_ID} --asset_id ${ASSET_ID} --description Transfer_Asset --amount 20

send ${USER1_ID} GetAccountAssets --account_id ${USER1_ID} --asset_id ${ASSET_ID}
send ${USER2_ID} GetAccountAssets --account_id ${USER2_ID} --asset_id ${ASSET_ID}

exit 0
