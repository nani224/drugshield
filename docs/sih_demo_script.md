# 🛡️ DrugShield — Smart India Hackathon 2026 Presentation & Demonstration Kit
## Problem ID: SIH26231 | Theme: Blockchain & Cybersecurity

---

## 🎯 1. The 2-Minute Opening Hook (Elevator Pitch)

> **"Respected Jury Members,**
> 
> Across India, over **₹20,000 Crores** worth of narcotics are seized annually. Yet, **nearly 60% of high-profile NDPS cases collapse in court** before trial even begins.
> 
> Why? Because defense attorneys exploit three fatal vulnerabilities:
> 1. **Subjective Eyeball Testing:** Field officers judge colorimetric reagent changes by eye under yellow sodium streetlights, leading to cross-examination doubt.
> 2. **Procedural Breaches under Section 50:** Missing independent witnesses, non-gazetted officers, or uncalibrated test kits.
> 3. **The Tainted Chain of Custody:** Evidence envelopes sit in police station *malkhanas* (store rooms) for weeks. Defense lawyers routinely claim the white powder was swapped or tampered with before reaching the Central Forensic Science Laboratory (CFSL).
> 
> **Enter DrugShield:** India's first end-to-end, defense-grade digital companion for field drug testing.
> 
> DrugShield replaces human visual guesswork with **on-device computer vision and quantized edge AI**, binds the evidence to **FIPS 140-2 Level 3 hardware security keystores**, and seals every milligram on a **Hyperledger Fabric 3.0 consortium blockchain**.
> 
> In the next 5 minutes, we will show you a live raid capture on a smartphone, on-device AI classification in under 25 milliseconds with zero internet, and an instant courtroom verification under Section 65B of the Indian Evidence Act."

---

## ⏱️ 2. The 5-Minute Live Demonstration Flow

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 5-MINUTE DEMO SEQUENCE                                 │
├─────────┬───────────────────────────────────┬──────────────────────────────────────────┤
│ Minute  │ Action / Screen                   │ Narration Focus                          │
├─────────┼───────────────────────────────────┼──────────────────────────────────────────┤
│ 00:00   │ Biometric Authentication          │ Play Integrity Attestation, zero mock    │
│ 01:00   │ NDPS Section 50 Checklist         │ Mandatory witness logging, reagent batch │
│ 01:45   │ Camera HUD Optical Lock           │ ArUco homography warp + Macbeth CCM      │
│ 02:30   │ AI Presumptive Classification     │ MobileNetV3 INT8 (<25ms), Amber Alert    │
│ 03:15   │ Evidence Vault & StrongBox Seal   │ SHA-256 digest + ECDSA P-256 signature   │
│ 04:00   │ Web Command Portal                │ Live seizure stream + Corridor heatmap   │
│ 04:45   │ Courtroom Evidence Verification   │ One-click Sec 65B IEA legal certificate  │
└─────────┴───────────────────────────────────┴──────────────────────────────────────────┘
```

### Turn 1: Secure Field Login (Minute 0:00 – 1:00)
- **Show:** Launch the DrugShield mobile client (`apps/mobile`). Show the Tactical Dark OLED HUD (`#000000`).
- **Explain:** Point out that this isn't a generic SaaS app. It follows MIL-STD-1472 and WCAG AAA standards for 2:00 AM highway raids. Show fingerprint biometric authentication and Google Play Integrity hardware attestation ensuring the device is unrooted.

### Turn 2: NDPS Section 50 Statutory Checklist (Minute 1:00 – 1:45)
- **Show:** The digital Section 50 compliance checklist. 
- **Explain:** "The app will **not** allow an officer to capture evidence until statutory safeguards are checked off: presence of Gazetted Officer or Magistrate, 2 independent panch witnesses with verified mobile numbers, and reagent batch lot verification. This legally immunizes the seizure against technical acquittals."

### Turn 3: CameraX HUD & Optical Color Correction (Minute 1:45 – 2:30)
- **Show:** Point the camera at a drug test pouch with ArUco fiducials. Show the cyan brackets automatically locking when tilt $< 3^\circ$ and ambient lux $> 150$.
- **Explain:** "Under yellow highway sodium lamps, blue looks black and orange looks brown. DrugShield's C++ OpenCV engine performs **homography perspective warping** and **Macbeth CCM color normalization** in real-time ($< 12\text{ms}$), converting the optical frame into illumination-independent CIE L\*a\*b\* color space."

### Turn 4: Edge AI Inference & Presumptive Amber Alert (Minute 2:30 – 3:15)
- **Show:** Auto-capture triggers with haptic click. Presumptive AI result appears: `Cocaine HCl • 96.8% Confidence`.
- **Explain:** "Notice the alert banner is **AMBER, not Green**. In NDPS law, field colorimetric tests are strictly *presumptive*, not confirmatory. Labeling this green would cause judicial scrutiny. The model is a custom **MobileNetV3-Large INT8 quantized model running locally via Google LiteRT** in 23ms with **zero internet connection**."

### Turn 5: Hardware StrongBox Sealing & Evidence Vault (Minute 3:15 – 4:00)
- **Show:** The Evidence Vault screen displaying the uncompressed frame SHA-256 hash, encrypted QR code, and StrongBox signature.
- **Explain:** "The moment the shutter clicks, the SHA-256 hash is computed and signed inside the phone's **hardware StrongBox Keystore (FIPS 140-2 Level 3 Secure Element)**. Even if the phone is later hacked or the officer is coerced, the cryptographic proof cannot be altered or backdated."

### Turn 6: Web Command & Control Portal (`dashboard/`) (Minute 4:00 – 4:45)
- **Show:** Switch to the Next.js 15 Command Portal on the projector screen.
- **Explain:** "The Go Gateway ingests the encrypted payload and commits it to **Hyperledger Fabric 3.0** across 4 consortium organizations: NCB, State Police, Judiciary, and CFSL. 
  - Point to the **Live Seizure Stream** on the left.
  - Point to the **National 3D Corridor Heatmap** in the center, showing real-time Golden Crescent and coastal trafficking vectors connecting Amritsar, Delhi, Mumbai, Goa, and Hyderabad."

### Turn 7: Courtroom Evidence Verification Dock (Minute 4:45 – 5:00)
- **Show:** Click the seizure in the stream. Click **'VERIFY BLOCKCHAIN CHAIN-OF-CUSTODY'**. Show the green checkmark banner and click **'GENERATE SECTION 65B CERTIFICATE'**.
- **Explain:** "When the case goes to trial 18 months later, the Special Judge or defense attorney drags the evidence file into this portal. The browser computes the SHA-256 hash using the Web Crypto API, validates it against the Fabric Raft ledger, and confirms zero tampering. One click exports the official **Section 65B Indian Evidence Act certificate**."

---

## 🥊 3. Tough Jury Questions & Defense Answers

### Q1: "What if the raid happens in a remote jungle or highway border with ZERO cellular signal?"
> **Answer:** "DrugShield was architected **offline-first from day one**. 
> - The camera CV pipeline and MobileNetV3 INT8 AI run **100% on-device** via C++ and LiteRT without making any network calls.
> - The seizure record is signed immediately via the hardware StrongBox Keystore and stored in an **AES-256 encrypted SQLCipher database** on the device.
> - When the officer re-enters cellular range or connects to station Wi-Fi, our background sync daemon securely dispatches the signed transaction to the Go Gateway with mTLS."

### Q2: "Can a corrupt police officer tamper with the photo before the app hashes it?"
> **Answer:** "No. The Flutter app captures directly from the camera sensor buffer into an uncompressed YUV byte stream in memory. The image is never saved to the public Android gallery where a third-party app could modify it. Furthermore, the device signature is generated inside the hardware Secure Element with an immutable hardware monotonic counter and timestamp, preventing replay or post-facto injection."

### Q3: "Why use Hyperledger Fabric instead of a public blockchain like Ethereum or Polygon?"
> **Answer:** "Public blockchains are legally and operationally unsuitable for national defense:
> 1. **Data Privacy (Section 52 NDPS Act):** Narcotics seizures involve confidential informants, undercover officers, and sensitive ongoing operations. Hyperledger Fabric's **Private Data Collections (PDC)** ensure only authorized consortium peers (NCB, State Police, CFSL) can read sensitive metadata, while public peers only see the cryptographic commitment hash.
> 2. **Deterministic Finality:** Raft CFT ordering provides instantaneous, final block commit without forks or mining delays.
> 3. **Zero Gas Fees & Zero Volatility:** Government agencies cannot budget for fluctuating cryptocurrency gas fees."

### Q4: "Presumptive color tests are notoriously prone to false positives (e.g. soap or lidocaine reacting like cocaine). How does your AI handle this?"
> **Answer:** "Human eyes struggle because they perceive color in RGB, which is heavily distorted by ambient lighting. Our pipeline first transforms the image into **CIE L\*a\*b\* perceptual color space** using a 24-patch Macbeth reference card on the test pouch. Our dataset was trained with hard-negative distractors (paracetamol, caffeine, baking soda, lidocaine, flour). If the reagent reaction is ambiguous or below 85% confidence, DrugShield explicitly triggers an **INCONCLUSIVE: SUBMIT TO CFSL FOR GC-MS** alert rather than making a dangerous false accusation."

### Q5: "How does this comply with Indian legal admissibility standards?"
> **Answer:** "DrugShield is explicitly tailored to:
> 1. **Section 50 of the NDPS Act (Search of Persons):** Enforces mandatory logging of Gazetted Officer / Magistrate attendance and independent panch witnesses.
> 2. **Section 65B of the Indian Evidence Act (Admissibility of Electronic Records):** Automatically generates the mandatory Section 65B affidavit with hardware hash, cryptographic audit trail, and device key identifier, eliminating courtroom objections."

---

## 🏆 4. Hackathon Winning Checklist (Demonstration Readiness)
- [x] Flutter Tactical HUD Client built with zero warnings
- [x] C++ Native OpenCV ArUco + Homography perspective warper
- [x] Quantized INT8 MobileNetV3 model bundled (< 4.2 MB)
- [x] Hyperledger Fabric 3.0 4-org consortium network configured
- [x] Go Enterprise Gateway with ECDSA verification and MinIO/IPFS storage
- [x] Next.js 15 Command Portal running on Dark Slate (`#0B0F17`)
- [x] Deck.gl / Tactical geospatial corridor radar for Golden Crescent vectors
- [x] Instant Courtroom Evidence Verification Dock with Section 65B export
- [x] End-to-end integration and latency benchmarks passing all SLAs
