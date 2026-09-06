// ============================================================================
// DrugShield — Go Gateway Microservice Entry Point
// SIH26231: Digital Companion for Field Drug Testing
//
// This is the central ingestion gateway that:
// 1. Accepts gRPC calls from the Flutter mobile client (over mTLS)
// 2. Verifies ECDSA hardware signatures from officer devices
// 3. Uploads encrypted evidence blobs to MinIO/IPFS
// 4. Submits seizure transactions to Hyperledger Fabric
// 5. Syncs committed state to PostgreSQL for analytics
// ============================================================================
package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
)

const (
	defaultPort = "50051"
)

func main() {
	port := os.Getenv("GATEWAY_PORT")
	if port == "" {
		port = defaultPort
	}

	listener, err := net.Listen("tcp", fmt.Sprintf(":%s", port))
	if err != nil {
		log.Fatalf("Failed to listen on port %s: %v", port, err)
	}

	// TODO: Add mTLS credentials from PKI certificates
	// TODO: Add interceptors for rate limiting and logging
	grpcServer := grpc.NewServer()

	// TODO: Register DrugShieldService handler
	// pb.RegisterDrugShieldServiceServer(grpcServer, handler.NewDrugShieldHandler(fabricClient, ipfsClient, pgPool))

	log.Printf("🚀 DrugShield Gateway listening on :%s", port)

	// Graceful shutdown
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Println("⏹️  Shutting down gateway gracefully...")
		grpcServer.GracefulStop()
	}()

	if err := grpcServer.Serve(listener); err != nil {
		log.Fatalf("Failed to serve gRPC: %v", err)
	}
}
