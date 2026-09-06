#!/bin/bash
# ==============================================================================
# DrugShield — Deploy Chaincode Lifecycle Script
# SIH26231: Digital Companion for Field Drug Testing
# ==============================================================================
set -e

CC_NAME="drug_chaincode"
CC_VERSION="1.0"
CC_SEQUENCE="1"
CHANNEL_NAME="seizures-channel"
CC_SRC_PATH="../../chaincode"
COLLECTIONS_CONFIG="../../chaincode/collections_config.json"

echo "📦 [DrugShield Fabric] Packaging chaincode ${CC_NAME} v${CC_VERSION}..."

peer lifecycle chaincode package ${CC_NAME}.tar.gz \
  --path ${CC_SRC_PATH} \
  --lang golang \
  --label ${CC_NAME}_${CC_VERSION}

echo "📥 Installing chaincode on peers..."
peer lifecycle chaincode install ${CC_NAME}.tar.gz

PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
echo "✅ Package ID: ${PACKAGE_ID}"

echo "✍️ Approving chaincode definition for NCB Org..."
peer lifecycle chaincode approveformyorg -o orderer.drugshield.gov.in:7050 \
  --channelID ${CHANNEL_NAME} \
  --name ${CC_NAME} \
  --version ${CC_VERSION} \
  --package-id ${PACKAGE_ID} \
  --sequence ${CC_SEQUENCE} \
  --collections-config ${COLLECTIONS_CONFIG}

echo "🚀 Committing chaincode definition to ${CHANNEL_NAME}..."
peer lifecycle chaincode commit -o orderer.drugshield.gov.in:7050 \
  --channelID ${CHANNEL_NAME} \
  --name ${CC_NAME} \
  --version ${CC_VERSION} \
  --sequence ${CC_SEQUENCE} \
  --collections-config ${COLLECTIONS_CONFIG}

echo "🎉 ${CC_NAME} v${CC_VERSION} is committed and ready for transactions!"
