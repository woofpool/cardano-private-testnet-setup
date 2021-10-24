#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# This script sets up a cluster that starts out in Byron
# The script generates all the files needed for the setup

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. "${SCRIPT_PATH}"/read-config.shlib; # load the config library functions

ROOT="$(config_get ROOT)";
INIT_SUPPLY="$(config_get INIT_SUPPLY)"
FEE="$(config_get FEE)"
NETWORK_MAGIC="$(config_get NETWORK_MAGIC)"
SECURITY_PARAM="$(config_get SECURITY_PARAM)"

BFT_NODES="node-bft1 node-bft2"
BFT_NODES_N="1 2"
NUM_BFT_NODES=2

POOL_NODES="node-pool1"

ALL_NODES="${BFT_NODES} ${POOL_NODES}"

FUNDS_PER_GENESIS_ADDRESS=$((${INIT_SUPPLY} / ${NUM_BFT_NODES}))
FUNDS_PER_BYRON_ADDRESS=$((${FUNDS_PER_GENESIS_ADDRESS} - ${FEE}))
# We need to allow for a fee to transfer the funds out of the genesis.
# We don't care too much, 1 ada is more than enough.

OS=$(uname -s) DATE=
case $OS in
  Darwin )       DATE="gdate";;
  * )            DATE="date";;
esac

START_TIME="$(${DATE} -d "now + 30 seconds" +%s)"

if ! mkdir "${ROOT}"; then
  echo "The ${ROOT} directory already exists, please move or remove it"
  exit
fi

# copy and tweak the configuration
cp "${SCRIPT_PATH}"/../configuration/byron-mainnet-node-config.yaml ${ROOT}/configuration.yaml
sed -i ${ROOT}/configuration.yaml \
    -e 's/Protocol: RealPBFT/Protocol: Cardano/' \
    -e '/Protocol/ aPBftSignatureThreshold: 0.6' \
    -e 's/minSeverity: Info/minSeverity: Debug/' \
    -e 's|GenesisFile: genesis.json|ByronGenesisFile: byron/genesis.json|' \
    -e '/ByronGenesisFile/ aShelleyGenesisFile: shelley/genesis.json' \
    -e '/ByronGenesisFile/ aAlonzoGenesisFile: shelley/genesis.alonzo.json' \
    -e 's/RequiresNoMagic/RequiresMagic/' \
    -e 's/LastKnownBlockVersion-Major: 0/LastKnownBlockVersion-Major: 1/' \
    -e 's/LastKnownBlockVersion-Minor: 2/LastKnownBlockVersion-Minor: 0/'
# Options for making it easier to trigger the transition to Shelley
# If neither of those are used, we have to
# - post an update proposal + votes to go to protocol version 1
# - after that's activated, change the configuration to have
#   'LastKnownBlockVersion-Major: 2', and restart the nodes
# - post another proposal + vote to go to protocol version 2

#uncomment this for an automatic transition after the first epoch
# echo "TestShelleyHardForkAtEpoch: 1" >> ${ROOT}/configuration.yaml
#uncomment this to trigger the hardfork with protocol version 1
#echo "TestShelleyHardForkAtVersion: 1"  >> ${ROOT}/configuration.yaml


pushd ${ROOT}

# create the node directories
for NODE in ${ALL_NODES}; do

  mkdir "${NODE}" "${NODE}/byron" "${NODE}/shelley"

done

# Make topology files
#TODO generalise this over the N BFT nodes and pool nodes
cat > node-bft1/topology.json <<EOF
{
   "Producers": [
     {
       "addr": "127.0.0.1",
       "port": 3002,
       "valency": 1
     }
   , {
       "addr": "127.0.0.1",
       "port": 3003,
       "valency": 1
     }
   ]
 }
EOF
echo 3001 > node-bft1/port

cat > node-bft2/topology.json <<EOF
{
   "Producers": [
     {
       "addr": "127.0.0.1",
       "port": 3001,
       "valency": 1
     }
   , {
       "addr": "127.0.0.1",
       "port": 3003,
       "valency": 1
     }
   ]
 }
EOF
echo 3002 > node-bft2/port

cat > node-pool1/topology.json <<EOF
{
   "Producers": [
     {
       "addr": "127.0.0.1",
       "port": 3001,
       "valency": 1
     }
   , {
       "addr": "127.0.0.1",
       "port": 3002,
       "valency": 1
     }
   ]
 }
EOF
echo 3003 > node-pool1/port


cat > byron.genesis.spec.json <<EOF
{
  "heavyDelThd":     "300000000000",
  "maxBlockSize":    "2000000",
  "maxTxSize":       "4096",
  "maxHeaderSize":   "2000000",
  "maxProposalSize": "700",
  "mpcThd": "20000000000000",
  "scriptVersion": 0,
  "slotDuration": "1000",
  "softforkRule": {
    "initThd": "900000000000000",
    "minThd": "600000000000000",
    "thdDecrement": "50000000000000"
  },
  "txFeePolicy": {
    "multiplier": "43946000000",
    "summand": "155381000000000"
  },
  "unlockStakeEpoch": "18446744073709551615",
  "updateImplicit": "10000",
  "updateProposalThd": "100000000000000",
  "updateVoteThd": "1000000000000"
}
EOF

cardano-cli byron genesis genesis \
  --protocol-magic ${NETWORK_MAGIC} \
  --start-time "${START_TIME}" \
  --k ${SECURITY_PARAM} \
  --n-poor-addresses 0 \
  --n-delegate-addresses ${NUM_BFT_NODES} \
  --total-balance ${INIT_SUPPLY} \
  --delegate-share 1 \
  --avvm-entry-count 0 \
  --avvm-entry-balance 0 \
  --protocol-parameters-file byron.genesis.spec.json \
  --genesis-output-dir byron
mv byron.genesis.spec.json byron/genesis.spec.json

# compute the ByronGenesisHash and add to configuration.yaml
byronGenesisHash=$(cardano-cli byron genesis print-genesis-hash --genesis-json byron/genesis.json)
echo "ByronGenesisHash: $byronGenesisHash" >> configuration.yaml

# Symlink the BFT operator keys from the genesis delegates, for uniformity
for N in ${BFT_NODES_N}; do

  ln -s ../../byron/delegate-keys.00$((${N} - 1)).key     "node-bft${N}/byron/delegate.key"
  ln -s ../../byron/delegation-cert.00$((${N} - 1)).json  "node-bft${N}/byron/delegate.cert"

done

# Create keys, addresses and transactions to withdraw the initial UTxO into
# regular addresses.
for N in ${BFT_NODES_N}; do

  cardano-cli byron key keygen \
    --secret byron/payment-keys.00$((${N} - 1)).key \

  cardano-cli byron key signing-key-address \
    --testnet-magic 42 \
    --secret byron/payment-keys.00$((${N} - 1)).key > byron/address-00$((${N} - 1))

  cardano-cli byron key signing-key-address \
    --testnet-magic 42 \
    --secret byron/genesis-keys.00$((${N} - 1)).key > byron/genesis-address-00$((${N} - 1))

  cardano-cli byron transaction issue-genesis-utxo-expenditure \
    --genesis-json byron/genesis.json \
    --testnet-magic 42 \
    --tx tx$((${N} - 1)).tx \
    --wallet-key byron/delegate-keys.00$((${N} - 1)).key \
    --rich-addr-from "$(head -n 1 byron/genesis-address-00$((${N} - 1)))" \
    --txout "(\"$(head -n 1 byron/address-00$((${N} - 1)))\", $FUNDS_PER_BYRON_ADDRESS)"

done

# Update Proposal and votes
cardano-cli byron governance create-update-proposal \
            --filepath update-proposal \
            --testnet-magic 42 \
            --signing-key byron/delegate-keys.000.key \
            --protocol-version-major 1 \
            --protocol-version-minor 0 \
            --protocol-version-alt 0 \
            --application-name "cardano-sl" \
            --software-version-num 1 \
            --system-tag "linux" \
            --installer-hash 0

for N in ${BFT_NODES_N}; do
    cardano-cli byron governance create-proposal-vote \
                --proposal-filepath update-proposal \
                --testnet-magic 42 \
                --signing-key byron/delegate-keys.00$((${N} - 1)).key \
                --vote-yes \
                --output-filepath update-vote.00$((${N} - 1))
done

cardano-cli byron governance create-update-proposal \
            --filepath update-proposal-1 \
            --testnet-magic 42 \
            --signing-key byron/delegate-keys.000.key \
            --protocol-version-major 2 \
            --protocol-version-minor 0 \
            --protocol-version-alt 0 \
            --application-name "cardano-sl" \
            --software-version-num 1 \
            --system-tag "linux" \
            --installer-hash 0

for N in ${BFT_NODES_N}; do
    cardano-cli byron governance create-proposal-vote \
                --proposal-filepath update-proposal-1 \
                --testnet-magic 42 \
                --signing-key byron/delegate-keys.00$((${N} - 1)).key \
                --vote-yes \
                --output-filepath update-vote-1.00$((${N} - 1))
done

echo "====================================================================="
echo "Generated genesis keys and genesis files:"
echo
ls -1 byron/*
echo "====================================================================="


# Set up our template
mkdir shelley
startTimeUtc=$(date --date="+30 seconds" --utc +%FT%TZ)
cardano-cli genesis create --testnet-magic 42 --start-time $startTimeUtc --genesis-dir shelley

# Then edit the genesis.spec.json ...

# We're going to use really quick epochs (300 seconds), by using short slots 0.2s
# and K=10, but we'll keep long KES periods so we don't have to bother
# cycling KES keys
sed -i shelley/genesis.spec.json \
    -e 's/"slotLength": 1/"slotLength": 0.2/' \
    -e 's/"activeSlotsCoeff": 5.0e-2/"activeSlotsCoeff": 0.1/' \
    -e 's/"securityParam": 2160/"securityParam": 10/' \
    -e 's/"epochLength": 432000/"epochLength": 1500/' \
    -e 's/"maxLovelaceSupply": 0/"maxLovelaceSupply": 1000000000000/' \
    -e 's/"decentralisationParam": 1.0/"decentralisationParam": 0.7/' \
    -e 's/"major": 0/"major": 2/' \
    -e 's/"updateQuorum": 5/"updateQuorum": 2/'

# Now generate for real:

cardano-cli genesis create \
    --testnet-magic 42 \
    --start-time $startTimeUtc \
    --genesis-dir shelley/ \
    --gen-genesis-keys ${NUM_BFT_NODES} \
    --gen-utxo-keys 1

# compute the Shelly genesis hash and add to configuration.yaml
shelleyGenesisHash=$(cardano-cli genesis hash --genesis shelley/genesis.json)
echo "ShelleyGenesisHash: $shelleyGenesisHash" >> configuration.yaml

# compute the Shelly Alonzo genesis hash and add to configuration.yaml
alonzoGenesisHash=$(cardano-cli genesis hash --genesis shelley/genesis.alonzo.json)
echo "AlonzoGenesisHash: $alonzoGenesisHash" >> configuration.yaml

echo "====================================================================="
echo "Generated genesis keys and genesis files:"
echo
ls -1 shelley/*
echo "====================================================================="

echo "Generated shelley/genesis.json:"
echo
cat shelley/genesis.json
echo
echo "====================================================================="

# Make the pool operator cold keys
# This was done already for the BFT nodes as part of the genesis creation

for NODE in ${POOL_NODES}; do

  cardano-cli node key-gen \
      --cold-verification-key-file                 ${NODE}/shelley/operator.vkey \
      --cold-signing-key-file                      ${NODE}/shelley/operator.skey \
      --operational-certificate-issue-counter-file ${NODE}/shelley/operator.counter

  cardano-cli node key-gen-VRF \
      --verification-key-file ${NODE}/shelley/vrf.vkey \
      --signing-key-file      ${NODE}/shelley/vrf.skey

done

# Symlink the BFT operator keys from the genesis delegates, for uniformity

for N in ${BFT_NODES_N}; do

  ln -s ../../shelley/delegate-keys/delegate${N}.skey node-bft${N}/shelley/operator.skey
  ln -s ../../shelley/delegate-keys/delegate${N}.vkey node-bft${N}/shelley/operator.vkey
  ln -s ../../shelley/delegate-keys/delegate${N}.counter node-bft${N}/shelley/operator.counter
  ln -s ../../shelley/delegate-keys/delegate${N}.vrf.vkey node-bft${N}/shelley/vrf.vkey
  ln -s ../../shelley/delegate-keys/delegate${N}.vrf.skey node-bft${N}/shelley/vrf.skey

done


# Make hot keys and for all nodes

for NODE in ${ALL_NODES}; do

  cardano-cli node key-gen-KES \
      --verification-key-file ${NODE}/shelley/kes.vkey \
      --signing-key-file      ${NODE}/shelley/kes.skey

  cardano-cli node issue-op-cert \
      --kes-period 0 \
      --kes-verification-key-file                  ${NODE}/shelley/kes.vkey \
      --cold-signing-key-file                      ${NODE}/shelley/operator.skey \
      --operational-certificate-issue-counter-file ${NODE}/shelley/operator.counter \
      --out-file                                   ${NODE}/shelley/node.cert

done

echo "Generated node operator keys (cold, hot) and operational certs:"
echo
ls -1 ${ALL_NODES}
echo "====================================================================="


# Make some payment and stake addresses
# user1..n:       will own all the funds in the system, we'll set this up from
#                 initial utxo the
# pool-owner1..n: will be the owner of the pools and we'll use their reward
#                 account for pool rewards

USER_ADDRS="user1"
POOL_ADDRS="pool-owner1"

ADDRS="${USER_ADDRS} ${POOL_ADDRS}"

mkdir addresses

for ADDR in ${ADDRS}; do

  # Payment address keys
  cardano-cli address key-gen \
      --verification-key-file addresses/${ADDR}.vkey \
      --signing-key-file      addresses/${ADDR}.skey

  # Stake address keys
  cardano-cli stake-address key-gen \
      --verification-key-file addresses/${ADDR}-stake.vkey \
      --signing-key-file      addresses/${ADDR}-stake.skey

  # Payment addresses
  cardano-cli address build \
      --payment-verification-key-file addresses/${ADDR}.vkey \
      --stake-verification-key-file addresses/${ADDR}-stake.vkey \
      --testnet-magic 42 \
      --out-file addresses/${ADDR}.addr

  # Stake addresses
  cardano-cli stake-address build \
      --stake-verification-key-file addresses/${ADDR}-stake.vkey \
      --testnet-magic 42 \
      --out-file addresses/${ADDR}-stake.addr

  # Stake addresses registration certs
  cardano-cli stake-address registration-certificate \
      --stake-verification-key-file addresses/${ADDR}-stake.vkey \
      --out-file addresses/${ADDR}-stake.reg.cert

done

# user N will delegate to pool N
USER_POOL_N="1"

for N in ${USER_POOL_N}; do

  # Stake address delegation certs
  cardano-cli stake-address delegation-certificate \
      --stake-verification-key-file addresses/user${N}-stake.vkey \
      --cold-verification-key-file  node-pool${N}/shelley/operator.vkey \
      --out-file addresses/user${N}-stake.deleg.cert

  ln -s ../addresses/pool-owner${N}-stake.vkey node-pool${N}/owner.vkey
  ln -s ../addresses/pool-owner${N}-stake.skey node-pool${N}/owner.skey

done

echo "Generated payment address keys, stake address keys,"
echo "stake address regitration certs, and stake address delegatation certs"
echo
ls -1 addresses/
echo "====================================================================="


# Next is to make the stake pool registration cert

for NODE in ${POOL_NODES}; do

  cardano-cli stake-pool registration-certificate \
    --testnet-magic 42 \
    --pool-pledge 0 --pool-cost 0 --pool-margin 0 \
    --cold-verification-key-file             ${NODE}/shelley/operator.vkey \
    --vrf-verification-key-file              ${NODE}/shelley/vrf.vkey \
    --reward-account-verification-key-file   ${NODE}/owner.vkey \
    --pool-owner-stake-verification-key-file ${NODE}/owner.vkey \
    --out-file                               ${NODE}/registration.cert
done

echo "Generated stake pool registration certs:"
ls -1 node-*/registration.cert
echo "====================================================================="

echo "So you can now do various things:"
echo " * Start the nodes"
echo " * Initiate successive protocol updates"
echo " * Query the node's ledger state"
echo
echo "To start the nodes, in separate terminals use the following scripts:"
echo

mkdir -p run

for NODE in ${BFT_NODES}; do
  (
    echo "#!/usr/bin/env bash"
    echo ""
    echo "cardano-node run \\"
    echo "  --config                          ${ROOT}/configuration.yaml \\"
    echo "  --topology                        ${ROOT}/${NODE}/topology.json \\"
    echo "  --database-path                   ${ROOT}/${NODE}/db \\"
    echo "  --socket-path                     ${ROOT}/${NODE}/node.sock \\"
    echo "  --shelley-kes-key                 ${ROOT}/${NODE}/shelley/kes.skey \\"
    echo "  --shelley-vrf-key                 ${ROOT}/${NODE}/shelley/vrf.skey \\"
    echo "  --shelley-operational-certificate ${ROOT}/${NODE}/shelley/node.cert \\"
    echo "  --port                            $(cat ${NODE}/port) \\"
    echo "  --delegation-certificate          ${ROOT}/${NODE}/byron/delegate.cert \\"
    echo "  --signing-key                     ${ROOT}/${NODE}/byron/delegate.key \\"
    echo "  | tee -a ${ROOT}/${NODE}/node.log"
  ) > run/${NODE}.sh

  chmod a+x run/${NODE}.sh

  echo $ROOT/run/${NODE}.sh
done

for NODE in ${POOL_NODES}; do
  (
    echo "#!/usr/bin/env bash"
    echo ""
    echo "cardano-node run \\"
    echo "  --config                          ${ROOT}/configuration.yaml \\"
    echo "  --topology                        ${ROOT}/${NODE}/topology.json \\"
    echo "  --database-path                   ${ROOT}/${NODE}/db \\"
    echo "  --socket-path                     ${ROOT}/${NODE}/node.sock \\"
    echo "  --shelley-kes-key                 ${ROOT}/${NODE}/shelley/kes.skey \\"
    echo "  --shelley-vrf-key                 ${ROOT}/${NODE}/shelley/vrf.skey \\"
    echo "  --shelley-operational-certificate ${ROOT}/${NODE}/shelley/node.cert \\"
    echo "  --port                            $(cat ${NODE}/port) \\"
    echo "  | tee -a ${ROOT}/${NODE}/node.log"
  ) > run/${NODE}.sh

  chmod a+x run/${NODE}.sh

  echo $ROOT/run/${NODE}.sh
done

echo "#!/usr/bin/env bash" > run/all.sh
echo "" >> run/all.sh

chmod a+x run/all.sh

for NODE in ${BFT_NODES}; do
  echo "$ROOT/run/${NODE}.sh &" >> run/all.sh
done

for NODE in ${POOL_NODES}; do
  echo "$ROOT/run/${NODE}.sh &" >> run/all.sh
done

echo "" >> run/all.sh
echo "wait" >> run/all.sh

chmod a+x run/all.sh

echo
echo "Alternatively, you can run all the nodes in one go:"
echo
echo "$ROOT/run/all.sh"

echo
echo "In order to do the protocol updates, proceed as follows:"
echo
echo "  0. wait for the nodes to start producing blocks"
echo "  1. invoke ./scripts/byron-to-alonzo/update-1.sh"
echo "     wait for the next epoch for the update to take effect"
echo
echo "  2. invoke ./scripts/byron-to-alonzo/update-2.sh"
echo "  3. restart the nodes"
echo "     wait for the next epoch for the update to take effect"
echo
echo "  4. invoke ./scripts/byron-to-alonzo/update-3.sh <N>"
echo "     Here, <N> the current epoch (2 if you're quick)."
echo "     If you provide the wrong epoch, you will see an error"
echo "     that will tell you the current epoch, and can run"
echo "     the script again."
echo "  5. restart the nodes"
echo "     wait for the next epoch for the update to take effect"
echo "  6. invoke ./scripts/byron-to-alonzo/update-4.sh <N>"
echo "  7. restart the nodes"
echo
echo "You can observe the status of the updates by grepping the logs, via"
echo
echo "  grep LedgerUpdate ${ROOT}/node-pool1/node.log"
echo
echo "When in Shelley (after 3, and before 4), you should be able "
echo "to look at the protocol parameters, or the ledger state, "
echo "using commands like"
echo
echo "CARDANO_NODE_SOCKET_PATH=${ROOT}/node-bft1/node.sock \\"
echo "  cardano-cli query protocol-parameters \\"
echo "  --cardano-mode --testnet-magic 42"
echo
echo "This will fail outside of the Shelley era. In particular, "
echo "after step 3, you will get an error message that tells you "
echo "that you are in the Allegra era. You must then use the --allegra-era flag:"
echo
echo "CARDANO_NODE_SOCKET_PATH=${ROOT}/node-bft1/node.sock \\"
echo "  cardano-cli query protocol-parameters \\"
echo "  --cardano-mode --allegra-era --testnet-magic 42"
echo
echo "Similarly, use --mary-era in the Mary era."
popd

# For an automatic transition at epoch 0, specifying mary, allegra or shelley
# will start the node in the appropriate era.
echo ""

# These are needed for cardano-submit-api
echo "EnableLogMetrics: False" >> ${ROOT}/configuration.yaml
echo "EnableLogging: True" >> ${ROOT}/configuration.yaml
