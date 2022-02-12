#!/bin/sh

user1_lovelace=$(get_address_biggest_lovelace $(cat private-testnet/address/user1.addr))

# empty string means the user has no funds
if [ $supportLeft == ""]; then
  exit 1
