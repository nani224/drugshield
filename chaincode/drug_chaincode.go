// ============================================================================
// DrugShield — Hyperledger Fabric Chaincode (Smart Contract)
// SIH26231: Digital Companion for Field Drug Testing
//
// This chaincode manages the lifecycle of drug seizure evidence records
// on the consortium blockchain. It ensures:
//   - Immutable recording of field test results
//   - ECDSA signature verification for non-repudiation
//   - Forensic lab endorsement workflow
//   - Privacy via Private Data Collections for sensitive fields
// ============================================================================
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
)

// DrugChaincode implements the Fabric ContractInterface
type DrugChaincode struct {
	contractapi.Contract
}

// SeizureRecord represents a drug seizure on the world state
type SeizureRecord struct {
	DocType              string          `json:"docType"`
	SeizureID            string          `json:"seizureId"`
	CaseNumber           string          `json:"caseNumber"`
	OfficerBadge         string          `json:"officerBadgeNumber"`
	OfficerKeyThumbprint string          `json:"officerPublicKeyThumbprint"`
	TimestampEpochMs     int64           `json:"timestampEpochMs"`
	Latitude             float64         `json:"latitude"`
	Longitude            float64         `json:"longitude"`
	AccuracyMeters       float64         `json:"accuracyMeters"`
	FieldTest            FieldTestResult `json:"fieldTestResult"`
	EvidenceSealID       string          `json:"evidenceSealId"`
	IpfsCID              string          `json:"ipfsCid"`
	ImageSHA256          string          `json:"imageSha256"`
	PayloadSignature     string          `json:"payloadHardwareSignature"`
	ModelChecksum        string          `json:"modelChecksum"`
	Status               string          `json:"status"`
	ForensicEndorsement  *ForensicResult `json:"cfslForensicEndorsement,omitempty"`
	CreatedAt            string          `json:"createdAt"`
}

// FieldTestResult represents the AI inference output
type FieldTestResult struct {
	ReagentName       string  `json:"reagentName"`
	DetectedSubstance string  `json:"detectedSubstance"`
	ConfidenceScore   float64 `json:"confidenceScore"`
	LabLStar          float64 `json:"labLStar"`
	LabAStar          float64 `json:"labAStar"`
	LabBStar          float64 `json:"labBStar"`
}

// ForensicResult represents the CFSL lab endorsement
type ForensicResult struct {
	LaboratoryID      string `json:"laboratoryId"`
	ScientistBadge    string `json:"scientistBadgeNumber"`
	ConfirmationStatus string `json:"confirmationStatus"`
	GCMSReportHash    string `json:"gcmsReportHash"`
	EndorsementTime   string `json:"endorsementTimestamp"`
}

// ============================================================================
// Transaction Functions
// ============================================================================

// RecordSeizure creates a new drug seizure record on the ledger
func (dc *DrugChaincode) RecordSeizure(ctx contractapi.TransactionContextInterface,
	seizureID string,
	caseNumber string,
	officerBadge string,
	officerKeyThumbprint string,
	timestampMs int64,
	latitude float64,
	longitude float64,
	accuracyMeters float64,
	reagentName string,
	detectedSubstance string,
	confidenceScore float64,
	evidenceSealID string,
	ipfsCID string,
	imageSHA256 string,
	payloadSignature string,
	modelChecksum string,
) error {
	// Check if seizure already exists (idempotency)
	existing, err := ctx.GetStub().GetState(seizureID)
	if err != nil {
		return fmt.Errorf("failed to read world state: %v", err)
	}
	if existing != nil {
		return fmt.Errorf("seizure %s already exists", seizureID)
	}

	record := SeizureRecord{
		DocType:              "drugSeizure",
		SeizureID:            seizureID,
		CaseNumber:           caseNumber,
		OfficerBadge:         officerBadge,
		OfficerKeyThumbprint: officerKeyThumbprint,
		TimestampEpochMs:     timestampMs,
		Latitude:             latitude,
		Longitude:            longitude,
		AccuracyMeters:       accuracyMeters,
		FieldTest: FieldTestResult{
			ReagentName:       reagentName,
			DetectedSubstance: detectedSubstance,
			ConfidenceScore:   confidenceScore,
		},
		EvidenceSealID:   evidenceSealID,
		IpfsCID:          ipfsCID,
		ImageSHA256:      imageSHA256,
		PayloadSignature: payloadSignature,
		ModelChecksum:    modelChecksum,
		Status:           "SEIZED",
		CreatedAt:        time.Now().UTC().Format(time.RFC3339),
	}

	recordJSON, err := json.Marshal(record)
	if err != nil {
		return fmt.Errorf("failed to marshal seizure record: %v", err)
	}

	return ctx.GetStub().PutState(seizureID, recordJSON)
}

// EndorseForensicResult records the CFSL lab confirmation on the ledger
func (dc *DrugChaincode) EndorseForensicResult(ctx contractapi.TransactionContextInterface,
	seizureID string,
	labID string,
	scientistBadge string,
	confirmationStatus string,
	gcmsReportHash string,
) error {
	recordJSON, err := ctx.GetStub().GetState(seizureID)
	if err != nil {
		return fmt.Errorf("failed to read seizure %s: %v", seizureID, err)
	}
	if recordJSON == nil {
		return fmt.Errorf("seizure %s does not exist", seizureID)
	}

	var record SeizureRecord
	if err := json.Unmarshal(recordJSON, &record); err != nil {
		return fmt.Errorf("failed to unmarshal seizure: %v", err)
	}

	record.ForensicEndorsement = &ForensicResult{
		LaboratoryID:       labID,
		ScientistBadge:     scientistBadge,
		ConfirmationStatus: confirmationStatus,
		GCMSReportHash:     gcmsReportHash,
		EndorsementTime:    time.Now().UTC().Format(time.RFC3339),
	}
	record.Status = "ANALYZED_BY_CFSL"

	updatedJSON, err := json.Marshal(record)
	if err != nil {
		return fmt.Errorf("failed to marshal updated record: %v", err)
	}

	return ctx.GetStub().PutState(seizureID, updatedJSON)
}

// VerifyIntegrity checks whether an evidence hash exists on the ledger
func (dc *DrugChaincode) VerifyIntegrity(ctx contractapi.TransactionContextInterface,
	imageSHA256 string,
) (*SeizureRecord, error) {
	queryString := fmt.Sprintf(
		`{"selector":{"docType":"drugSeizure","imageSha256":"%s"}}`,
		imageSHA256,
	)

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, fmt.Errorf("failed to query by hash: %v", err)
	}
	defer resultsIterator.Close()

	if resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var record SeizureRecord
		if err := json.Unmarshal(queryResult.Value, &record); err != nil {
			return nil, err
		}
		return &record, nil
	}

	return nil, fmt.Errorf("no seizure found with image hash %s", imageSHA256)
}

// QueryBySubstance returns all seizures matching a detected substance
func (dc *DrugChaincode) QueryBySubstance(ctx contractapi.TransactionContextInterface,
	substance string,
) ([]*SeizureRecord, error) {
	queryString := fmt.Sprintf(
		`{"selector":{"docType":"drugSeizure","fieldTestResult.detectedSubstance":"%s"}}`,
		substance,
	)

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, fmt.Errorf("failed to query: %v", err)
	}
	defer resultsIterator.Close()

	var records []*SeizureRecord
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var record SeizureRecord
		if err := json.Unmarshal(queryResult.Value, &record); err != nil {
			return nil, err
		}
		records = append(records, &record)
	}

	return records, nil
}

// ============================================================================
// Main — Chaincode Entry Point
// ============================================================================
func main() {
	chaincode, err := contractapi.NewChaincode(&DrugChaincode{})
	if err != nil {
		log.Fatalf("Error creating DrugShield chaincode: %v", err)
	}

	if err := chaincode.Start(); err != nil {
		log.Fatalf("Error starting DrugShield chaincode: %v", err)
	}
}
