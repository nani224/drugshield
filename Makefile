# ============================================================================
# DrugShield — Unified Build System
# SIH26231: Digital Companion for Field Drug Testing
# ============================================================================

.PHONY: help setup flutter-run backend-run fabric-up fabric-down dashboard-run test clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Environment Setup
# ---------------------------------------------------------------------------
setup: ## Install all dependencies (run once)
	@echo "==> Installing Flutter dependencies..."
	cd apps/mobile && flutter pub get
	@echo "==> Installing Go dependencies..."
	cd backend && go mod tidy
	cd chaincode && go mod tidy
	@echo "==> Installing Dashboard dependencies..."
	cd dashboard && pnpm install
	@echo "==> Installing ML dependencies..."
	cd ml && pip install -r requirements.txt
	@echo "==> Bootstrap monorepo with Melos..."
	melos bootstrap

# ---------------------------------------------------------------------------
# Mobile App
# ---------------------------------------------------------------------------
flutter-run: ## Run Flutter app on connected device/emulator
	cd apps/mobile && flutter run --debug

flutter-build-apk: ## Build release APK
	cd apps/mobile && flutter build apk --release

# ---------------------------------------------------------------------------
# Backend Gateway
# ---------------------------------------------------------------------------
backend-run: ## Run Go gateway microservice
	cd backend && go run cmd/gateway/main.go

backend-build: ## Compile Go gateway binary
	cd backend && go build -o bin/gateway cmd/gateway/main.go

# ---------------------------------------------------------------------------
# Hyperledger Fabric Network
# ---------------------------------------------------------------------------
fabric-up: ## Start Fabric consortium network (Docker)
	cd network && docker compose -f docker-compose-fabric.yml up -d
	@echo "==> Waiting for peers to start..."
	sleep 10
	cd network/scripts && bash create-channel.sh
	cd network/scripts && bash deploy-chaincode.sh

fabric-down: ## Stop Fabric network
	cd network && docker compose -f docker-compose-fabric.yml down -v

# ---------------------------------------------------------------------------
# Infrastructure (PostgreSQL + Redis + IPFS)
# ---------------------------------------------------------------------------
infra-up: ## Start PostgreSQL, Redis, IPFS containers
	docker compose up -d postgres redis ipfs

infra-down: ## Stop infrastructure containers
	docker compose down

# ---------------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------------
dashboard-run: ## Run Next.js dashboard in dev mode
	cd dashboard && pnpm dev

dashboard-build: ## Build Next.js for production
	cd dashboard && pnpm build

# ---------------------------------------------------------------------------
# ML Pipeline
# ---------------------------------------------------------------------------
ml-train: ## Train MobileNetV3 model
	cd ml && python -m notebooks.02_train_mobilenetv3

ml-quantize: ## Quantize model to INT8 TFLite
	cd ml && python -m notebooks.03_quantize_int8

# ---------------------------------------------------------------------------
# Code Generation
# ---------------------------------------------------------------------------
proto: ## Generate gRPC code from Protobuf definitions
	melos run gen:proto

ffigen: ## Generate Dart FFI bindings from C headers
	melos run gen:ffigen

# ---------------------------------------------------------------------------
# Testing
# ---------------------------------------------------------------------------
test: ## Run all tests across monorepo
	melos run test
	cd backend && go test ./...
	cd chaincode && go test ./...
	python test/e2e_pipeline_test.py
	python test/performance_benchmarks.py

test-e2e: ## Run end-to-end 4-tier pipeline test
	python test/e2e_pipeline_test.py

test-benchmark: ## Run latency and throughput benchmarks
	python test/performance_benchmarks.py

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
clean: ## Clean all build artifacts
	melos run clean
	cd backend && rm -rf bin/
	cd dashboard && rm -rf .next/ node_modules/
