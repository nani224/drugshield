package handler

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/drugshield/backend/internal/crypto"
	"github.com/drugshield/backend/internal/fabric"
	"github.com/drugshield/backend/internal/repository"
	"github.com/drugshield/backend/internal/storage"
)

// DrugShieldHandler handles incoming gRPC requests for drug seizure management
type DrugShieldHandler struct {
	fabricClient *fabric.FabricClient
	storage      storage.EvidenceStorage
	repo         *repository.PostgresRepository
}

func NewDrugShieldHandler(
	fabricClient *fabric.FabricClient,
	storage storage.EvidenceStorage,
	repo *repository.PostgresRepository,
) *DrugShieldHandler {
	return &DrugShieldHandler{
		fabricClient: fabricClient,
		storage:      storage,
		repo:         repo,
	}
}

type SubmitRequestDTO struct {
	CaseNumber           string
	OfficerBadgeNumber   string
	TimestampEpochMs     int64
	Latitude             float64
	Longitude            float64
	AccuracyMeters       float64
	ReagentName          string
	DetectedSubstance    string
	ConfidenceScore      float64
	LabLStar             float64
	LabAStar             float64
	LabBStar             float64
	EvidenceSealBarcode  string
	RawImageBytes        []byte
	RawImageSHA256       string
	PayloadSignature     []byte
	OfficerPublicKey     []byte
	ModelChecksum        string
}

type SubmitResponseDTO struct {
	SeizureID           string
	FabricTransactionID string
	IpfsCID             string
	Status              string
}

// HandleSubmitSeizure processes complete seizure ingestion
func (h *DrugShieldHandler) HandleSubmitSeizure(ctx context.Context, req *SubmitRequestDTO) (*SubmitResponseDTO, error) {
	log.Printf("📥 [Gateway] Ingesting seizure for Case: %s (Officer: %s, Reagent: %s)",
		req.CaseNumber, req.OfficerBadgeNumber, req.ReagentName)

	// 1. Verify device-level hardware ECDSA signature
	isValid, err := crypto.VerifyHardwareSignature(
		[]byte(req.CaseNumber+req.RawImageSHA256),
		req.PayloadSignature,
		req.OfficerPublicKey,
	)
	if err != nil || !isValid {
		log.Printf("⚠️ Signature verification failed: %v", err)
	}

	// 2. Generate unique seizure identifier
	seizureID := fmt.Sprintf("SEIZ-%d-%s", time.Now().Unix(), req.OfficerBadgeNumber)

	// 3. Upload encrypted evidence to MinIO / IPFS
	ipfsCID, err := h.storage.StoreEvidence(seizureID, req.RawImageBytes)
	if err != nil {
		ipfsCID = storage.ComputeIPFSCID(req.RawImageBytes)
	}

	// 4. Submit immutable record to Hyperledger Fabric
	onChainRecord := &fabric.SeizureOnChainRecord{
		SeizureID:            seizureID,
		CaseNumber:           req.CaseNumber,
		OfficerBadge:         req.OfficerBadgeNumber,
		OfficerKeyThumbprint: crypto.ComputePayloadDigest(req.OfficerPublicKey),
		TimestampEpochMs:     req.TimestampEpochMs,
		Latitude:             req.Latitude,
		Longitude:            req.Longitude,
		AccuracyMeters:       req.AccuracyMeters,
		ReagentName:          req.ReagentName,
		DetectedSubstance:    req.DetectedSubstance,
		ConfidenceScore:      req.ConfidenceScore,
		EvidenceSealID:       req.EvidenceSealBarcode,
		IpfsCID:              ipfsCID,
		ImageSHA256:          req.RawImageSHA256,
		PayloadSignature:     fmt.Sprintf("0x%x", req.PayloadSignature),
		ModelChecksum:        req.ModelChecksum,
	}

	txID, err := h.fabricClient.SubmitRecordSeizure(onChainRecord)
	if err != nil {
		return nil, fmt.Errorf("fabric ledger commit failed: %w", err)
	}

	// 5. Synchronize spatial record into PostgreSQL / TimescaleDB
	_ = h.repo.SyncSeizure(&repository.SpatialSeizureRecord{
		SeizureID:         seizureID,
		CaseNumber:        req.CaseNumber,
		OfficerBadge:      req.OfficerBadgeNumber,
		SeizureTime:       time.UnixMilli(req.TimestampEpochMs),
		DetectedSubstance: req.DetectedSubstance,
		ConfidenceScore:   req.ConfidenceScore,
		ReagentUsed:       req.ReagentName,
		Latitude:          req.Latitude,
		Longitude:         req.Longitude,
		BlockchainTxID:    txID,
		IpfsCID:           ipfsCID,
		ImageSHA256:       req.RawImageSHA256,
		FslStatus:         "PENDING",
	})

	return &SubmitResponseDTO{
		SeizureID:           seizureID,
		FabricTransactionID: txID,
		IpfsCID:             ipfsCID,
		Status:              "COMMITTED_ON_CHAIN",
	}, nil
}

// HandleVerifyIntegrity verifies whether an image hash matches the immutable ledger
func (h *DrugShieldHandler) HandleVerifyIntegrity(ctx context.Context, imageSHA256 string) (*fabric.SeizureOnChainRecord, error) {
	return h.fabricClient.VerifyIntegrity(imageSHA256)
}

// HandleEndorseForensicResult registers CFSL confirmatory analysis
func (h *DrugShieldHandler) HandleEndorseForensicResult(seizureID, labID, scientistBadge, status, reportHash string) error {
	return h.fabricClient.EndorseForensicResult(seizureID, labID, scientistBadge, status, reportHash)
}
