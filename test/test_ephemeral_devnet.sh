#!/bin/sh

DEVNET_PATH=private-testnet
DEVNET_READY_FLAG=ready.flag

set -e

. test/_helpers.sh

echo "fresh bootstrap should give the user1 some funds"

nohup scripts/automate.sh &
pid=$!
while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done

echo $pid
test/assert_user1_has_funds.sh
user1_tx_1=$(get_address_biggest_tx $(cat private-testnet/address/user1.addr))
kill -9 $pid

echo "followup bootstrap should flush the state give the (new) user1 some funds"
nohup scripts/automate.sh &
pid=$!
while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done
echo $pid

test/assert_user1_has_funds.sh
user1_tx_2=$(get_address_biggest_tx $(cat private-testnet/address/user1.addr))
kill -9 $pid

if [ $user1_tx_1 = $user1_tx_2 ]; then
  echo "ephemeral devnet attempted to reuse the old ledger"
  exti 1
