#!/bin/sh

DEVNET_PATH=private-testnet
DEVNET_READY_FLAG=ready.flag


. test/_helpers.sh

echo "fresh bootstrap should give the user1 some funds"
nohup scripts/automate.sh &
pid=$!

# let the script remove things it needs to remove
sleep 5

while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done
user1_lovelace=$(get_address_biggest_lovelace $(cat ${DEVNET_PATH}/addresses/user1.addr))
echo $user1_lovelace
# user should have some lovelace there
if [ "$user1_lovelace" = "" ]; then
  echo "User's address hasn't been funded"
  exit 1
fi

user1_tx_1=$(get_address_biggest_tx $(cat ${DEVNET_PATH}/addresses/user1.addr))

sleep 5

echo "followup bootstrap with the KEEP flag on"
nohup scripts/automate.sh 1 &
pid=$!

# let the script remove things it needs to remove
sleep 5

while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done
echo $pid

echo $CARDANO_NODE_SOCKET_PATH

user1_lovelace=$(get_address_biggest_lovelace $(cat ${DEVNET_PATH}/addresses/user1.addr))
# user should have some lovelace there
if [ "$user1_lovelace" = "" ]; then
  echo "User's address hasn't been funded after the reset"
  exit 1
fi

user1_tx_2=$(get_address_biggest_tx $(cat ${DEVNET_PATH}/addresses/user1.addr))

pkill cardano-node
pkill $pid

echo $user1_tx_1
echo $user1_tx_2
if [ $user1_tx_1 != $user1_tx_2 ]; then
  echo "persistent devnet didn't reuse addresses from the first run, that's wrong"
  exti 1
fi