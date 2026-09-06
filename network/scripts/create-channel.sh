#!/bin/bash
# ==============================================================================
# DrugShield — Create & Join Seizures Channel
# SIH26231: Digital Companion for Field Drug Testing
# ==============================================================================
set -e

CHANNEL_NAME="seizures-channel"
ORDERER_CA="/var/hyperledger/orderer/tls/ca.crt"
ORDERER_ADMIN="orderer.drugshield.gov.in:7050"

echo "⛓️  [DrugShield Fabric] Creating channel ${CHANNEL_NAME}..."

# 1. Generate Channel Genesis Block
configtxgen -profile SeizuresChannel -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID ${CHANNEL_NAME}

# 2. Submit Create Channel transaction to Orderer
osnadmin channel join \
  --channelID ${CHANNEL_NAME} \
  --config-block ./channel-artifacts/${CHANNEL_NAME}.block \
  -o ${ORDERER_ADMIN} \
  --ca-file ${ORDERER_CA}

echo "✅ Channel ${CHANNEL_NAME} created and active on Raft Orderer."

# 3. Join all 4 organization peers to the channel
PEERS=("peer0.ncb.gov.in:7051" "peer0.police.gov.in:8051" "peer0.cfsl.gov.in:9051" "peer0.judiciary.gov.in:10051")

for PEER in "${PEERS[@]}"; do
  echo "🔗 Joining ${PEER} to ${CHANNEL_NAME}..."
  CORE_PEER_ADDRESS=${PEER} peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
done

echo "🎉 All 4 consortium peers successfully joined to ${CHANNEL_NAME}!"
