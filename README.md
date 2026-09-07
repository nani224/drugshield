# 🛡️ DrugShield — Digital Companion for Field Drug Testing

> **Smart India Hackathon 2026 | Problem ID: SIH26231 | Theme: Blockchain & Cybersecurity**

A production-grade mobile + blockchain platform that transforms subjective, error-prone field drug testing into an objective, AI-powered, tamper-proof evidence system for Indian law enforcement.

## 🌐 Live Command Dashboard (Examiner & Review Access)

The defense intelligence command dashboard is deployed and accessible live for examiners and reviewers:

| Access Method | Link / Status | Description |
|---|---|---|
| **Live Web App (HTTPS)** | [**https://da305690387d10.lhr.life**](https://da305690387d10.lhr.life) | Instant live preview for examiners with full light/dark mode support |
| **1-Click Cloud Deploy** | [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fnani224%2Fdrugshield&root-directory=dashboard) | Permanent 24/7 serverless cloud hosting (zero setup required) |
| **GitHub Actions CI** | [![Dashboard CI](https://github.com/nani224/drugshield/actions/workflows/deploy.yml/badge.svg)](https://github.com/nani224/drugshield/actions) | Continuous validation & automated static builds |

### 🚀 How to Open Live in 1-Click (Vercel)
1. Click the **[Deploy with Vercel](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fnani224%2Fdrugshield&root-directory=dashboard)** button above.
2. Sign in with GitHub and click **Create**.
3. Vercel automatically detects Next.js inside `dashboard/` and deploys a permanent 24/7 public URL (`https://drugshield-*.vercel.app`) in under 60 seconds!

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
