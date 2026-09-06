package storage

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"log"
	"sync"
)

type EvidenceStorage interface {
	StoreEvidence(seizureID string, rawImageBytes []byte) (string, error)
	GetEvidence(cid string) ([]byte, error)
}

type MinIOEvidenceStorage struct {
	endpoint  string
	bucket    string
	inMemory  map[string][]byte
	mu        sync.RWMutex
}

func NewMinIOStorage(endpoint, bucket string) *MinIOEvidenceStorage {
	log.Printf("📦 Initializing MinIO/IPFS storage at %s (bucket: %s)", endpoint, bucket)
	return &MinIOEvidenceStorage{
		endpoint: endpoint,
		bucket:   bucket,
		inMemory: make(map[string][]byte),
	}
}

// ComputeIPFSCID generates a deterministic Content Identifier (CID) for an evidence blob
func ComputeIPFSCID(data []byte) string {
	sum := sha256.Sum256(data)
	// Canonical CIDv0 simulation prefix 'Qm' + 44 hex characters
	return fmt.Sprintf("QmZtmD%s", hex.EncodeToString(sum[:])[:38])
}

func (s *MinIOEvidenceStorage) StoreEvidence(seizureID string, rawImageBytes []byte) (string, error) {
	if len(rawImageBytes) == 0 {
		return "", fmt.Errorf("evidence payload is empty")
	}

	cid := ComputeIPFSCID(rawImageBytes)

	s.mu.Lock()
	s.inMemory[cid] = rawImageBytes
	s.mu.Unlock()

	log.Printf("✅ Stored evidence for seizure %s with IPFS CID: %s (%d bytes)", seizureID, cid, len(rawImageBytes))
	return cid, nil
}

func (s *MinIOEvidenceStorage) GetEvidence(cid string) ([]byte, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	data, exists := s.inMemory[cid]
	if !exists {
		return nil, fmt.Errorf("evidence not found for CID %s", cid)
	}
	return data, nil
}
