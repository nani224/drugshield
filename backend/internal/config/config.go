package config

import (
	"os"
)

type Config struct {
	Port         string
	DatabaseURL  string
	RedisURL     string
	MinIOEndpoint string
	MinIOAccessKey string
	MinIOSecretKey string
	MinIOBucket  string
	FabricPeerURL string
	FabricChannel string
	FabricChaincode string
	TLSCertPath  string
	TLSKeyPath   string
}

func LoadConfig() *Config {
	return &Config{
		Port:            getEnv("GATEWAY_PORT", "50051"),
		DatabaseURL:     getEnv("DATABASE_URL", "postgres://drugshield:ds_dev_secret_2026@localhost:5432/drugshield?sslmode=disable"),
		RedisURL:        getEnv("REDIS_URL", "localhost:6379"),
		MinIOEndpoint:   getEnv("MINIO_ENDPOINT", "localhost:9000"),
		MinIOAccessKey:  getEnv("MINIO_ROOT_USER", "drugshield"),
		MinIOSecretKey:  getEnv("MINIO_ROOT_PASSWORD", "ds_minio_secret_2026"),
		MinIOBucket:     getEnv("MINIO_BUCKET", "drugshield-evidence"),
		FabricPeerURL:   getEnv("FABRIC_PEER_URL", "localhost:7051"),
		FabricChannel:   getEnv("FABRIC_CHANNEL", "seizures-channel"),
		FabricChaincode: getEnv("FABRIC_CHAINCODE", "drug_chaincode"),
		TLSCertPath:     getEnv("TLS_CERT_PATH", "tls/server.crt"),
		TLSKeyPath:      getEnv("TLS_KEY_PATH", "tls/server.key"),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
