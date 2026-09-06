# 🛡️ DrugShield — Digital Companion for Field Drug Testing

> **Smart India Hackathon 2026 | Problem ID: SIH26231 | Theme: Blockchain & Cybersecurity**

A production-grade mobile + blockchain platform that transforms subjective, error-prone field drug testing into an objective, AI-powered, tamper-proof evidence system for Indian law enforcement.

## 🏗️ Architecture

```
Flutter Mobile App  →  OpenCV (ArUco + CCM)  →  LiteRT INT8 AI  →  Hardware ECDSA Signing
                                                                          ↓
                                                                    Go gRPC Gateway
                                                                    ↙           ↘
                                                            Private IPFS    Hyperledger Fabric 3.0
                                                                    ↘           ↙
                                                              PostgreSQL + PostGIS
                                                                          ↓
                                                              Next.js Command Portal
```

## 📦 Monorepo Structure

| Directory | Description | Tech |
|---|---|---|
| `apps/mobile/` | Field officer mobile app | Flutter 3.24 (Dart) |
| `packages/native_opencv/` | Camera calibration FFI plugin | OpenCV C++ via Dart FFI |
| `packages/crypto_signer/` | Hardware keystore signing | Android StrongBox / iOS SE |
| `packages/proto/` | Shared gRPC/Protobuf schemas | Protocol Buffers |
| `backend/` | Ingestion gateway microservice | Go 1.23 + gRPC + Gin |
| `chaincode/` | Blockchain smart contract | Go (Fabric Contract API) |
| `network/` | Fabric consortium configuration | Docker + Raft Ordering |
| `dashboard/` | Command & control web portal | Next.js 15 + Deck.gl |
| `ml/` | AI model training pipeline | Python + TensorFlow |

## 🚀 Quick Start

```bash
# 1. Install prerequisites
# Flutter SDK, Go 1.23+, Docker Desktop, Node.js 22+, Python 3.11+

# 2. Bootstrap monorepo
make setup

# 3. Start infrastructure (PostgreSQL, Redis, MinIO)
make infra-up

# 4. Start Fabric network
make fabric-up

# 5. Run mobile app
make flutter-run

# 6. Run backend gateway
make backend-run

# 7. Run dashboard
make dashboard-run
```

## 📋 Key Features

- **📸 ArUco-Guided Camera Calibration** — Perspective homography + CIE L*a*b* color correction eliminates ambient lighting bias
- **🧠 On-Device Edge AI** — INT8-quantized MobileNetV3 classifies drugs in 22ms, fully offline
- **🔗 Tamper-Proof Blockchain** — Hyperledger Fabric 3.0 consortium (NCB, State Police, CFSL, Court)
- **🔒 Hardware-Backed Signing** — ECDSA secp256r1 from Android StrongBox / Apple Secure Enclave
- **📍 Offline-First Architecture** — Works without internet; auto-syncs when connectivity is restored
- **⚖️ NDPS Act Compliant** — Guided Section 50 workflow prevents procedural acquittals

## 📄 License

Built for Smart India Hackathon 2026. All rights reserved.
