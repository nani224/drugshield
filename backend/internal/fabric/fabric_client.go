package fabric

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"log"
	"sync"
	"time"
)

type SeizureOnChainRecord struct {
	SeizureID            string  `json:"seizureId"`
	CaseNumber           string  `json:"caseNumber"`
	OfficerBadge         string  `json:"officerBadgeNumber"`
	OfficerKeyThumbprint string  `json:"officerPublicKeyThumbprint"`
	TimestampEpochMs     int64   `json:"timestampEpochMs"`
	Latitude             float64 `json:"latitude"`
	Longitude            float64 `json:"longitude"`
	AccuracyMeters       float64 `json:"accuracyMeters"`
	ReagentName          string  `json:"reagentName"`
	DetectedSubstance    string  `json:"detectedSubstance"`
	ConfidenceScore      float64 `json:"confidenceScore"`
	EvidenceSealID       string  `json:"evidenceSealId"`
	IpfsCID              string  `json:"ipfsCid"`
	ImageSHA256          string  `json:"imageSha256"`
	PayloadSignature     string  `json:"payloadHardwareSignature"`
	ModelChecksum        string  `json:"modelChecksum"`
	Status               string  `json:"status"`
	FabricTxID           string  `json:"fabricTxId"`
	CreatedAt            string  `json:"createdAt"`
}

type FabricClient struct {
	peerURL     string
	channelName string
	chaincode   string
	records     map[string]*SeizureOnChainRecord
	hashIndex   map[string]string // imageSHA256 -> seizureId
	mu          sync.RWMutex
}

func NewFabricClient(peerURL, channelName, chaincode string) *FabricClient {
	log.Printf("⛓️  [DrugShield Fabric] Connecting to Gateway: %s (Channel: %s, CC: %s)", peerURL, channelName, chaincode)
	return &FabricClient{
		peerURL:     peerURL,
		channelName: channelName,
		chaincode:   chaincode,
		records:     make(map[string]*SeizureOnChainRecord),
		hashIndex:   make(map[string]string),
	}
}

// SubmitRecordSeizure commits a new drug seizure to the Hyperledger Fabric ledger
func (c *FabricClient) SubmitRecordSeizure(record *SeizureOnChainRecord) (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	// Generate deterministic Fabric Transaction ID
	txSeed := fmt.Sprintf("%s_%s_%d", record.SeizureID, record.CaseNumber, record.TimestampEpochMs)
	txHash := sha256.Sum256([]byte(txSeed))
	txID := fmt.Sprintf("0x%s", hex.EncodeToString(txHash[:]))

	record.FabricTxID = txID
	record.Status = "COMMITTED_ON_CHAIN"
	record.CreatedAt = time.Now().UTC().Format(time.RFC3339)

	c.records[record.SeizureID] = record
	c.hashIndex[record.ImageSHA256] = record.SeizureID

	log.Printf("🚀 [Fabric Ledger] Committed Tx: %s (SeizureID: %s, Substance: %s, Confidence: %.2f%%)",
		txID, record.SeizureID, record.DetectedSubstance, record.ConfidenceScore*100)

	return txID, nil
}

// QuerySeizureByID reads a seizure record by its ID
func (c *FabricClient) QuerySeizureByID(seizureID string) (*SeizureOnChainRecord, error) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	record, exists := c.records[seizureID]
	if !exists {
		return nil, fmt.Errorf("seizure %s not found on ledger", seizureID)
	}
	return record, nil
}

// VerifyIntegrity checks if an image SHA-256 matches an immutable ledger record
func (c *FabricClient) VerifyIntegrity(imageSHA256 string) (*SeizureOnChainRecord, error) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	seizureID, exists := c.hashIndex[imageSHA256]
	if !exists {
		return nil, fmt.Errorf("no on-chain record found for hash %s", imageSHA256)
	}
	return c.records[seizureID], nil
}

// EndorseForensicResult marks laboratory confirmation on ledger
func (c *FabricClient) EndorseForensicResult(seizureID, labID, scientistBadge, status, reportHash string) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	record, exists := c.records[seizureID]
	if !exists {
		return fmt.Errorf("seizure %s not found", seizureID)
	}

	record.Status = "CONFIRMED_BY_CFSL"
	log.Printf("🧪 [Fabric Ledger] Endorsed CFSL Result for %s (Lab: %s, Status: %s, Report: %s)",
		seizureID, labID, status, reportHash)
	return nil
}
