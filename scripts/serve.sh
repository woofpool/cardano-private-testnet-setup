#!/bin/sh

ROOT=private-testnet
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export CARDANO_NODE_SOCKET_PATH=$ROOT/node-bft1/node.sock

wait_until_socket_detected()
{
  echo "wait until socket is detected, socket: $CARDANO_NODE_SOCKET_PATH"
  while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
    echo "Sleep 10 secs"; sleep 10
  done
  echo "socket is detected"
}

wait_until_count_of_running_nodes() {
  echo "wait until running node count is $1"
  running_nodes_cnt=$( ps -ef | grep 'cardano-node' | grep -v grep | wc -l )
  while [ $running_nodes_cnt -ne $1 ]; do
    echo "Sleep 5 secs"; sleep 5
    running_nodes_cnt=$( ps -ef | grep 'cardano-node' | grep -v grep | wc -l )
  done
  echo "running node count is $1"
}

kill_running_nodes() {
  echo "send kill signal for each running node PID"
  for PID in `ps -ef | grep 'cardano-node' | grep -v grep |  awk '{print $2}'`;do kill -TERM $PID 2> /dev/null; done
  wait_until_count_of_running_nodes 0
}

start_all_nodes() {
  echo "start all the nodes in bg"
  $ROOT/run/all.sh > /dev/null 2>&1 &
  wait_until_count_of_running_nodes 3
  echo
  echo "PIDs of started nodes:"
  for PID in `ps -ef | grep 'cardano-node' | grep -v grep |  awk '{print $2}'`;do echo "PID: $PID"; done
}

restart_nodes_in_bg()
{
  echo "Request to (re)start nodes received"
  kill_running_nodes
  start_all_nodes
  echo "Nodes restarted"
}

run_update_script()
{
  echo "request to run update-$1 script"
  if [ -z "$2" ]
  then
    "${SCRIPT_PATH}"/update-$1.sh
  else
    "${SCRIPT_PATH}"/update-$1.sh $2
  fi
  echo "Sleep 10 secs to ensure update votes are received"; sleep 10
  echo "update-$1 script completed"
}

wait_for_epoch_to_advance()
{
  target_epoch_no=$(expr $epoch_no + $1)
  echo "Waiting until epoch $target_epoch_no"
  while [ $epoch_no -lt $target_epoch_no ]; do
    echo "Sleep 30 secs"; sleep 30
    epoch_no=$(cardano-cli query tip --testnet-magic 42 | jq '.epoch')
  done
  echo "reached epoch: $epoch_no"
}

query_tip()
{
  cardano-cli query tip --testnet-magic 42
}

running_nodes_cnt=$( ps -ef | grep 'cardano-node' | grep -v grep | wc -l )
if [ $running_nodes_cnt -gt 0 ]; then
  echo "Script aborted, since running cardano nodes have been found."
  exit
fi

# delete root folder to get clean slate
rm -rf $ROOT

# run script to create config
"${SCRIPT_PATH}"/mkfiles.sh

echo
restart_nodes_in_bg

echo
wait_until_socket_detected

echo
echo "starting protocol updates..."

epoch_no=0

echo
run_update_script "1"
query_tip

echo
wait_for_epoch_to_advance 1
query_tip

echo
run_update_script "2"

echo
restart_nodes_in_bg
query_tip

wait_for_epoch_to_advance 1
query_tip

echo
run_update_script "3" $epoch_no

echo
restart_nodes_in_bg
query_tip

echo
wait_for_epoch_to_advance 1
query_tip

echo
run_update_script "4" $epoch_no

echo
restart_nodes_in_bg
query_tip

echo
wait_for_epoch_to_advance 1
query_tip

echo
run_update_script "5" $epoch_no

echo
restart_nodes_in_bg
query_tip

echo
wait_for_epoch_to_advance 1
query_tip

echo
run_update_script "6" $epoch_no

echo
restart_nodes_in_bg
query_tip

echo
wait_for_epoch_to_advance 1

query_tip
echo
current_era=$( cardano-cli query tip --testnet-magic 42 | jq '.era' )
protocol_version=$( cardano-cli query protocol-parameters --testnet-magic 42 | jq '.protocolVersion.major' )
echo "Nodes are running in era: $current_era, major protocol version: $protocol_version"

wait