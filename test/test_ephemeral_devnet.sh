#!/bin/sh

DEVNET_PATH=private-testnet
DEVNET_READY_FLAG=ready.flag

set -e

. test/_helpers.sh

echo "fresh bootstrap should give the user1 some funds"
nohup scripts/automate.sh &
pid=$!
while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done

user1_lovelace=$(get_address_biggest_lovelace $(cat private-testnet/addresses/user1.addr))
echo $user1_lovelace
# user should have some lovelace there
if [ $user1_lovelace == ""]; then
  exit 1
fi

user1_tx_1=$(get_address_biggest_tx $(cat private-testnet/addresses/user1.addr))
kill -9 $pid

echo "followup bootstrap should flush the state give the (new) user1 some funds"
nohup scripts/automate.sh &
pid=$!
while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done
echo $pid

user1_lovelace=$(get_address_biggest_lovelace $(cat private-testnet/addresses/user1.addr))
echo $user1_lovelace
# user should have some lovelace there
if [ $user1_lovelace == ""]; then
  exit 1
fi

user1_tx_2=$(get_address_biggest_tx $(cat private-testnet/addresses/user1.addr))
kill -9 $pid

if [ $user1_tx_1 = $user1_tx_2 ]; then
  echo "ephemeral devnet attempted to reuse the old ledger, and that's not what we expected"
  exti 1
fi