#!/bin/sh

boostrap_the_devnet_with_pid()
{
  DEVNET_PATH=private-testnet
  DEVNET_READY_FLAG=ready.flag

  nohup scripts/automate.sh &
  PID=$!
  while [ ! -f ${DEVNET_PATH}/${DEVNET_READY_FLAG} ]; do sleep 5; done

  echo $PID
}

# retrieve the biggest (in amount of lovelace stored) tx for the given address
# $1 - address to lookup
get_address_biggest_tx()
{
  # find the greatest intput in the whole utxo and use it
  GREATEST_INPUT=$(cardano-cli query utxo --address $1 --testnet-magic 42 | tail -n +3 | awk '{printf "%s#%s %s \n", $1 , $2, $3}' | sort -rn -k2 | head -n1)

  TXID0=$(echo ${GREATEST_INPUT} | awk '{print $1}')
  echo $TXID0
}

# retrieve the amount of lovelace in the biggest (in amount of lovelace had) tx
# $1 - address to lookup
get_address_biggest_lovelace()
{
  # find the greatest intput in the whole utxo and use it
  GREATEST_INPUT=$(cardano-cli query utxo --address $1 --testnet-magic 42 | tail -n +3 | awk '{printf "%s#%s %s \n", $1 , $2, $3}' | sort -rn -k2 | head -n1)

  COINS_IN_INPUT=$(echo ${GREATEST_INPUT} | awk '{print $2}')
  echo $COINS_IN_INPUT
}