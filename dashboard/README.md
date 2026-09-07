# 🛡️ DrugShield — Command & Control Intelligence Portal

> **National Narcotics Seizure Intelligence Network (NNSIN)**  
> Defense-grade command & control dashboard for real-time narcotics seizure intelligence, blockchain chain-of-custody verification, and corridor surveillance.

---

## 🌐 Live Examiner Access

- **Public Live URL (HTTPS)**: [**https://da305690387d10.lhr.life**](https://da305690387d10.lhr.life)
- **1-Click Cloud Deploy**: [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fnani224%2Fdrugshield&root-directory=dashboard)

---

## 🏛️ Application Architecture

- **Framework**: Next.js 15 App Router (`app/`)
- **Runtime**: React 19
- **Styling**: Tailwind CSS with Dynamic CSS Variables (Dual-Mode Design System)
- **Data Visualization**: Recharts (12-Month Volume Area/Line, Substance Donut, AI Accuracy Bars, Corridor Velocity, Diurnal Heatmap)
- **Geospatial Surveillance**: SVG Radar & India Supply Line Heatmap
- **Cryptographic Audit**: Hyperledger Fabric 3.0 Merkle Root Verifier + Section 65B Certificate Preview

---

## 📑 Core Views

1. **Command Cockpit (`/`)**: Executive KPIs, Corridor Heatmap snapshot, Priority Interdictions, and slide-over Evidence Dossier.
2. **Immutable Registry (`/registry`)**: Full-width seizure ledger, filter pills, AI confidence rings, and on-chain hashes.
3. **Forensic Analytics (`/analytics`)**: 5 interactive charts across volume, value, taxonomy, AI concordance, and patrol timing.
4. **Corridor Radar (`/corridors`)**: Geospatial supply-line watch, risk rating matrix cards, and checkpoint telemetry.
5. **Judicial Verifier (`/courtroom`)**: NDPS Section 50 procedural compliance checklist, Merkle root verification, and Section 65B Electronic Certificate preview.

---

## 🌓 Flexible Dual-Theme System

- **Dark Mode**: Cyber-defense abyssal dark (`#0B0F17`, `#121721`) with neon accents (`#00F0FF`, `#00E676`, `#FFB300`).
- **Light Mode**: High-contrast enterprise slate (`#F4F6F9`, `#FFFFFF`) with deep WCAG AAA dark text (`#0F172A`, `#334155`) and accessible tactical accents (`#0284C7`, `#059669`).
- **Zero-Flicker Hydration**: Anti-flicker `<head>` script and `localStorage` persistence.

---

## 🛠️ Local Development

```bash
cd dashboard
npm install
npm run dev
# Open http://localhost:3000
```

To build production bundle:
```bash
npm run build
npm start
```
