"use client";

import React, { useState, useEffect } from "react";
import { SeizureRecord } from "../types";
import {
  Scale,
  ShieldCheck,
  CheckCircle2,
  AlertOctagon,
  FileCheck,
  Download,
  Copy,
  Hash,
  Lock,
  Cpu,
  RefreshCw,
  FileText,
  MapPin,
  Clock,
  UserCheck,
} from "lucide-react";

interface CourtroomVerifierProps {
  selectedSeizure: SeizureRecord | null;
}

export const CourtroomVerifier: React.FC<CourtroomVerifierProps> = ({
  selectedSeizure,
}) => {
  const [inputHash, setInputHash] = useState<string>("");
  const [isVerifying, setIsVerifying] = useState<boolean>(false);
  const [verificationResult, setVerificationResult] = useState<{
    verified: boolean;
    txId: string;
    blockNumber: number;
    timestamp: string;
    officerId: string;
    signer: string;
    section50Status: string;
    notes: string;
  } | null>(null);
  const [copied, setCopied] = useState<boolean>(false);
  const [showCertModal, setShowCertModal] = useState<boolean>(false);

  // When selected seizure changes, load its hash automatically
  useEffect(() => {
    if (selectedSeizure) {
      setInputHash(selectedSeizure.sha256Hash);
      handleVerify(selectedSeizure.sha256Hash);
    }
  }, [selectedSeizure]);

  const handleVerify = (hashToVerify?: string) => {
    const targetHash = (hashToVerify || inputHash).trim().toLowerCase();
    if (!targetHash) return;

    setIsVerifying(true);

    // Simulate cryptographic verification against Hyperledger Fabric 3.0
    setTimeout(() => {
      setIsVerifying(false);
      // Valid if it matches selected seizure or matches expected length and hex characters
      const isValidHex = /^[0-9a-f]{64}$/i.test(targetHash);
      const isKnownMatch = selectedSeizure ? targetHash === selectedSeizure.sha256Hash.toLowerCase() : isValidHex;

      if (isKnownMatch && isValidHex) {
        setVerificationResult({
          verified: true,
          txId: selectedSeizure?.fabricTxId || `0x${targetHash.substring(0, 40)}`,
          blockNumber: selectedSeizure?.blockNumber || 142891,
          timestamp: selectedSeizure?.timestamp || "2026-09-06 17:58:21 IST",
          officerId: selectedSeizure?.officerId || "NCB-HQ-781",
          signer: "Android StrongBox KeyStore (ECDSA SECP256R1)",
          section50Status: "5/5 STATUTORY SAFEGUARDS COMPLIANT",
          notes: "Digital signature and uncompressed frame hash match on-chain immutable ledger record perfectly.",
        });
      } else {
        setVerificationResult({
          verified: false,
          txId: "N/A — TRANSACTION REJECTED",
          blockNumber: 0,
          timestamp: new Date().toISOString(),
          officerId: "UNKNOWN",
          signer: "INVALID / CORRUPTED",
          section50Status: "VERIFICATION FAILED",
          notes: "Cryptographic hash mismatch. The evidence manifest has been altered or tainted in violation of Section 50.",
        });
      }
    }, 600);
  };

  const handleCopyHash = () => {
    if (inputHash) {
      navigator.clipboard.writeText(inputHash);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const buffer = await file.arrayBuffer();
      const hashBuffer = await crypto.subtle.digest("SHA-256", buffer);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const calculatedHash = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
      setInputHash(calculatedHash);
      handleVerify(calculatedHash);
    } catch (err) {
      console.error("Hash calculation failed:", err);
    }
  };

  return (
    <div className="flex flex-col h-full bg-carbon border-l border-surfaceBorder overflow-y-auto">
      {/* Panel Header */}
      <div className="p-3 border-b border-surfaceBorder bg-abyssal/60 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Scale className="w-4 h-4 text-tacticalCyan" />
          <span className="font-bold text-xs tracking-wider uppercase font-mono text-white">
            COURTROOM EVIDENCE VERIFICATION
          </span>
        </div>
        <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-tacticalEmerald/10 border border-tacticalEmerald/30 text-tacticalEmerald font-semibold">
          SEC. 65B IEA COMPLIANT
        </span>
      </div>

      <div className="p-4 space-y-4 flex-1">
        {/* Verification Subtitle / Guidance */}
        <p className="text-xs text-textMuted leading-relaxed font-mono">
          Cryptographic chain-of-custody auditor for Special NDPS Courts. Drag-and-drop an evidence bundle or enter SHA-256 digital fingerprint to verify Hyperledger Fabric provenance.
        </p>

        {/* Input & Drag-Drop Zone */}
        <div className="space-y-2">
          <label className="text-[11px] font-mono text-gray-300 font-semibold flex items-center justify-between">
            <span>SHA-256 DIGITAL FINGERPRINT</span>
            {inputHash && (
              <button
                onClick={handleCopyHash}
                className="text-tacticalCyan hover:text-white flex items-center gap-1 text-[10px]"
              >
                <Copy className="w-3 h-3" />
                {copied ? "COPIED" : "COPY HASH"}
              </button>
            )}
          </label>

          <div className="relative">
            <textarea
              rows={2}
              value={inputHash}
              onChange={(e) => setInputHash(e.target.value)}
              placeholder="Paste 64-character SHA-256 evidence hash (or select a seizure from stream)..."
              className="w-full bg-abyssal border border-surfaceBorder rounded p-2 text-xs font-mono text-white placeholder-textMuted focus:outline-none focus:border-tacticalCyan resize-none"
            />
          </div>

          {/* File Picker Drag Drop Box */}
          <label className="border border-dashed border-surfaceBorder hover:border-tacticalCyan rounded-lg p-3 flex flex-col items-center justify-center cursor-pointer transition-colors bg-abyssal/40 group">
            <FileText className="w-5 h-5 text-textMuted group-hover:text-tacticalCyan mb-1" />
            <span className="text-[11px] font-mono text-gray-300 group-hover:text-white">
              Drop Photo / Video / JSON Manifest
            </span>
            <span className="text-[9px] font-mono text-textMuted">
              Calculates SHA-256 on-device via WebCrypto API
            </span>
            <input
              type="file"
              onChange={handleFileUpload}
              className="hidden"
            />
          </label>
        </div>

        {/* Action Button: Verify */}
        <button
          onClick={() => handleVerify()}
          disabled={isVerifying || !inputHash.trim()}
          className="w-full bg-tacticalCyan hover:bg-cyan-400 disabled:opacity-50 text-black font-bold text-xs font-mono py-2.5 px-4 rounded transition-all flex items-center justify-center gap-2 shadow-[0_0_15px_rgba(0,240,255,0.2)]"
        >
          {isVerifying ? (
            <>
              <RefreshCw className="w-3.5 h-3.5 animate-spin" />
              <span>CONSULTING FABRIC 3.0 RAFT CONSENSUS...</span>
            </>
          ) : (
            <>
              <ShieldCheck className="w-4 h-4" />
              <span>VERIFY BLOCKCHAIN CHAIN-OF-CUSTODY</span>
            </>
          )}
        </button>

        {/* Selected Seizure Overview Card */}
        {selectedSeizure && (
          <div className="bg-abyssal/70 border border-surfaceBorder rounded-lg p-3 space-y-2 font-mono text-xs">
            <div className="flex items-center justify-between border-b border-surfaceBorder/60 pb-1.5">
              <span className="text-tacticalCyan font-bold">{selectedSeizure.firNumber}</span>
              <span className="text-[10px] text-gray-400">{selectedSeizure.id}</span>
            </div>

            <div className="grid grid-cols-2 gap-2 text-[11px]">
              <div>
                <span className="text-textMuted block text-[10px]">SUBSTANCE:</span>
                <span className="text-white font-semibold">{selectedSeizure.substance}</span>
              </div>
              <div>
                <span className="text-textMuted block text-[10px]">WEIGHT / VOL:</span>
                <span className="text-tacticalEmerald font-semibold">
                  {selectedSeizure.weightGrams} grams
                </span>
              </div>
              <div>
                <span className="text-textMuted block text-[10px]">INVESTIGATING OFFICER:</span>
                <span className="text-gray-200">{selectedSeizure.officerId}</span>
              </div>
              <div>
                <span className="text-textMuted block text-[10px]">COLORIMETRIC REAGENT:</span>
                <span className="text-gray-200 truncate block">{selectedSeizure.reagentUsed}</span>
              </div>
            </div>
          </div>
        )}

        {/* Verification Result Card */}
        {verificationResult && (
          <div
            className={`border rounded-lg p-3.5 space-y-3 font-mono text-xs ${
              verificationResult.verified
                ? "bg-emerald-950/20 border-tacticalEmerald shadow-[0_0_20px_rgba(0,230,118,0.15)]"
                : "bg-red-950/20 border-tacticalCrimson shadow-[0_0_20px_rgba(255,23,68,0.15)]"
            }`}
          >
            {/* Status Banner */}
            <div className="flex items-center gap-2">
              {verificationResult.verified ? (
                <CheckCircle2 className="w-5 h-5 text-tacticalEmerald shrink-0" />
              ) : (
                <AlertOctagon className="w-5 h-5 text-tacticalCrimson shrink-0" />
              )}
              <div className="flex-1">
                <div
                  className={`font-bold text-xs ${
                    verificationResult.verified ? "text-tacticalEmerald" : "text-tacticalCrimson"
                  }`}
                >
                  {verificationResult.verified
                    ? "CRYPTOGRAPHIC PROVENANCE CONFIRMED"
                    : "TAMPER ALERT: HASH MISMATCH"}
                </div>
                <div className="text-[10px] text-gray-400">
                  {verificationResult.verified
                    ? "Zero discrepancies found against Hyperledger Fabric block"
                    : "Digital signature invalid or record corrupted"}
                </div>
              </div>
            </div>

            {/* Proof Details Grid */}
            <div className="space-y-1.5 pt-2 border-t border-surfaceBorder/60 text-[11px]">
              <div className="flex justify-between items-center text-textMuted">
                <span>FABRIC TX ID:</span>
                <span className="text-white font-mono truncate max-w-[170px]">
                  {verificationResult.txId}
                </span>
              </div>

              <div className="flex justify-between items-center text-textMuted">
                <span>LEDGER BLOCK:</span>
                <span className="text-tacticalCyan font-bold">
                  #{verificationResult.blockNumber}
                </span>
              </div>

              <div className="flex justify-between items-center text-textMuted">
                <span>SECURE HARDWARE:</span>
                <span className="text-tacticalAmber font-medium truncate max-w-[170px]">
                  {verificationResult.signer}
                </span>
              </div>

              <div className="flex justify-between items-center text-textMuted">
                <span>SECTION 50 AUDIT:</span>
                <span className="text-tacticalEmerald font-semibold">
                  {verificationResult.section50Status}
                </span>
              </div>
            </div>

            {/* Certificate Generation Action */}
            {verificationResult.verified && (
              <button
                onClick={() => setShowCertModal(true)}
                className="w-full mt-2 bg-carbon border border-tacticalEmerald text-tacticalEmerald hover:bg-tacticalEmerald hover:text-black font-mono font-bold text-xs py-2 px-3 rounded transition-all flex items-center justify-center gap-2"
              >
                <FileCheck className="w-3.5 h-3.5" />
                <span>GENERATE SECTION 65B CERTIFICATE</span>
              </button>
            )}
          </div>
        )}
      </div>

      {/* Modal: Section 65B Indian Evidence Act Certificate */}
      {showCertModal && (
        <div className="fixed inset-0 bg-black/85 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-carbon border border-tacticalCyan rounded-lg max-w-xl w-full p-6 space-y-4 font-mono shadow-[0_0_40px_rgba(0,240,255,0.2)]">
            <div className="flex items-center justify-between border-b border-surfaceBorder pb-3">
              <div className="flex items-center gap-2">
                <Scale className="w-5 h-5 text-tacticalCyan" />
                <span className="font-bold text-sm text-white">
                  CERTIFICATE UNDER SECTION 65B OF THE INDIAN EVIDENCE ACT, 1872
                </span>
              </div>
              <button
                onClick={() => setShowCertModal(false)}
                className="text-gray-400 hover:text-white text-xs px-2 py-1 rounded bg-surfaceBorder"
              >
                ESC
              </button>
            </div>

            <div className="text-xs text-gray-300 space-y-3 leading-relaxed max-h-[360px] overflow-y-auto p-3 bg-abyssal rounded border border-surfaceBorder">
              <p className="font-bold text-tacticalCyan">
                IN THE COURT OF THE SPECIAL JUDGE (NDPS ACT)
              </p>
              <p>
                <strong>Case Ref:</strong> {selectedSeizure?.firNumber || "NDPS/NDLS/2026/0184"}
                <br />
                <strong>Evidence ID:</strong> {selectedSeizure?.id || "SEIZ-2026-DEL-842"}
                <br />
                <strong>Timestamp of Capture:</strong> {selectedSeizure?.timestamp || "2026-09-06 17:58:21 IST"}
              </p>
              <p>
                I, System Administrator (DrugShield NNSIN Cryptographic Node #01), hereby certify that the electronic record produced herein was captured using an authorized hardware security device (FIPS 140-2 Level 3 StrongBox Keystore) running on-device edge verification algorithms.
              </p>
              <p className="bg-carbon p-2 rounded border border-surfaceBorder text-[10px]">
                <strong>CRYPTOGRAPHIC PROOF VECTOR:</strong>
                <br />
                SHA-256 Digest: {inputHash}
                <br />
                Fabric Tx: {verificationResult?.txId}
                <br />
                Block Height: #{verificationResult?.blockNumber}
                <br />
                Consensus Orderer: Raft BFT (4 Consortium Peers Signed)
              </p>
              <p>
                The optical frame was subjected to Macbeth CCM homography calibration and classified with presumptive confidence under Section 50 protocol. The digital fingerprint has remained unaltered and cryptographically sealed on the distributed ledger.
              </p>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                onClick={() => setShowCertModal(false)}
                className="px-4 py-2 rounded bg-surfaceBorder text-gray-300 hover:text-white text-xs"
              >
                Close
              </button>
              <button
                onClick={() => {
                  alert("Section 65B Legal Certificate exported successfully for judicial submission.");
                  setShowCertModal(false);
                }}
                className="px-4 py-2 rounded bg-tacticalEmerald text-black font-bold text-xs flex items-center gap-1.5 hover:bg-emerald-400"
              >
                <Download className="w-3.5 h-3.5" />
                <span>Export Official PDF / Memorandum</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
