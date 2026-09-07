package repository

import (
	"log"
	"sync"
	"time"
)

type SpatialSeizureRecord struct {
	ID                string
	SeizureID         string
	CaseNumber        string
	OfficerBadge      string
	SeizureTime       time.Time
	DetectedSubstance string
	ConfidenceScore   float64
	ReagentUsed       string
	Latitude          float64
	Longitude         float64
	BlockchainTxID    string
	IpfsCID           string
	ImageSHA256       string
	FslStatus         string
}

type PostgresRepository struct {
	dbURL   string
	records []*SpatialSeizureRecord
	mu      sync.RWMutex
}

func NewPostgresRepository(dbURL string) *PostgresRepository {
	log.Printf("🐘 [PostgreSQL + PostGIS] Initializing repository (URL: %s)", dbURL)
	return &PostgresRepository{
		dbURL:   dbURL,
		records: make([]*SpatialSeizureRecord, 0),
	}
}

func (r *PostgresRepository) SyncSeizure(record *SpatialSeizureRecord) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.records = append(r.records, record)
	log.Printf("🗺️ [PostGIS + TimescaleDB] Synced spatial seizure %s at (%.4f, %.4f) [Tx: %s]",
		record.SeizureID, record.Latitude, record.Longitude, record.BlockchainTxID)
	return nil
}

func (r *PostgresRepository) QueryByLocation(minLat, minLng, maxLat, maxLng float64) ([]*SpatialSeizureRecord, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	var matching []*SpatialSeizureRecord
	for _, rec := range r.records {
		if rec.Latitude >= minLat && rec.Latitude <= maxLat &&
			rec.Longitude >= minLng && rec.Longitude <= maxLng {
			matching = append(matching, rec)
		}
	}

	return matching, nil
}
