# 🛡️ DrugShield — Build Progress Tracker

## ✅ Pre-Build: Environment & Audit
- [x] Audit all 5 design artifacts (12 issues found)
- [x] Document fixes for all 12 issues
- [x] Install all 11 VS Code extensions (Dart, Flutter, Go, Docker, Proto3, Tailwind, GitLens, Thunder, Prettier, ESLint, WSL)
- [/] Install Flutter SDK (manual download required)
- [/] Install Go 1.23+ (winget install running)
- [ ] Install Docker Desktop + WSL2
- [ ] Install Android Studio + NDK

## ✅ Monorepo Scaffold
- [x] Create full directory structure (apps, packages, backend, chaincode, network, dashboard, ml, docs)
- [x] `melos.yaml` — Monorepo orchestrator config
- [x] `Makefile` — Unified build/test/deploy commands
- [x] `docker-compose.yml` — PostgreSQL 16 + TimescaleDB, Redis 7, MinIO S3
- [x] `README.md` — Architecture overview & quick start
- [x] `packages/proto/seizure.proto` — gRPC Protobuf schema (all 4 RPCs)
- [x] `backend/cmd/gateway/main.go` — Go gateway entry point
- [x] `backend/go.mod` — Go module definition
- [x] `backend/internal/repository/init.sql` — PostgreSQL + PostGIS + TimescaleDB schema
- [x] `chaincode/drug_chaincode.go` — Hyperledger Fabric smart contract (4 functions)
- [x] `chaincode/go.mod` — Chaincode Go module
- [x] `apps/mobile/lib/core/theme.dart` — Full Tactical HUD design system
- [x] `apps/mobile/lib/main.dart` — Flutter app entry with launch screen
- [x] `apps/mobile/pubspec.yaml` — All Flutter dependencies
- [x] `ml/requirements.txt` — Python ML pipeline dependencies

## 🟢 Phase 1: Foundation & Camera Intelligence (Days 1–2)
- [x] 1.1 Install Flutter SDK, create Flutter project shell
- [x] 1.2 Build `native_opencv` FFI plugin (CMake + NDK + OpenCV C++ wrapper)
- [x] 1.3 CameraX live preview (60 FPS frame streaming)
- [x] 1.4 ArUco marker detection overlay (cyan HUD brackets)
- [x] 1.5 Homography perspective warp
- [x] 1.6 Macbeth CCM color correction (CIE L\*a\*b\*)
- [x] 1.7 Biometric login screen (fingerprint + Play Integrity)
- [x] 1.8 NDPS Section 50 checklist screen (witnesses + reagent selection)
- [x] 1.9 Apply Tactical HUD dark theme across all screens

## 🟡 Phase 2: Edge AI Intelligence (Days 2–3)
- [ ] 2.1 Curate colorimetric test image dataset (5 reagent classes)
- [ ] 2.2 Augment dataset (brightness, contrast, rotation, noise)
- [ ] 2.3 Convert all images to CIE L\*a\*b\*
- [ ] 2.4 Transfer learning: MobileNetV3-Large fine-tuning
- [ ] 2.5 INT8 quantization → `mobilenet_v3_int8.tflite`
- [ ] 2.6 Integrate LiteRT into Flutter (on-device inference)
- [ ] 2.7 AI Result Screen (Amber presumptive banner)
- [ ] 2.8 Evidence Vault Screen (SHA-256 + QR + local save)

## 🔴 Phase 3: Trust Layer — Blockchain & Backend (Days 3–4)
- [ ] 3.1 Docker Desktop + WSL2 + Fabric Docker images
- [ ] 3.2 Configure 4-org Fabric test network
- [ ] 3.3 Deploy `drug_chaincode.go` on all peers
- [ ] 3.4 Deploy MinIO/IPFS evidence storage
- [ ] 3.5 Build Go Gateway (mTLS + ECDSA verify + IPFS upload + Fabric submit)
- [ ] 3.6 Implement `crypto_signer` Flutter plugin (StrongBox / SE)
- [ ] 3.7 Implement Drift + SQLCipher encrypted local DB
- [ ] 3.8 Background sync service (offline → online dispatch)
- [ ] 3.9 Set up PostGIS + TimescaleDB analytics DB

## 🔵 Phase 4: Command Portal & Demo (Days 4–5)
- [ ] 4.1 Scaffold Next.js 15 + pnpm + Tailwind (dark slate theme)
- [ ] 4.2 Executive Summary Dashboard (KPI cards)
- [ ] 4.3 Deck.gl + MapLibre geospatial heatmap
- [ ] 4.4 Courtroom Evidence Verification Portal
- [ ] 4.5 End-to-end integration test
- [ ] 4.6 Performance benchmarking
- [ ] 4.7 SIH demo preparation
