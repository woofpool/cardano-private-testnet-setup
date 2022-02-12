#!/bin/sh

set -e

. test/_helpers.sh

echo "fresh bootstrap should give the user1 some funds"
pid=$(boostrap_the_devnet_with_pid)
test/assert_user1_has_funds.sh
user1_tx_1=$(get_address_biggest_tx $(cat private-testnet/address/user1.addr))
kill -9 $pid
echo "folloup up bootstrap should flush the state give the (new) user1 some funds"
pid=$(boostrap_the_devnet_with_pid)
test/assert_user1_has_funds.sh
user1_tx_2=$(get_address_biggest_tx $(cat private-testnet/address/user1.addr))
kill -9 $pid

if [ $user1_tx_1 = $user1_tx_2 ]; then
  echo "ephemeral devnet attempted to reuse the old ledger"
  exti 1
