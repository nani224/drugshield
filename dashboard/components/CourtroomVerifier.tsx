"use client";

import React, { useEffect, useState } from "react";
import { SeizureRecord } from "../types";
import {
  Scale,
  ShieldCheck,
  CheckCircle2,
  AlertOctagon,
  FileCheck,
  Download,
  Copy,
  RefreshCw,
  FileText,
} from "lucide-react";

interface CourtroomVerifierProps {
  selectedSeizure: SeizureRecord | null;
}

export const CourtroomVerifier: React.FC<CourtroomVerifierProps> = ({ selectedSeizure }) => {
  const [inputHash, setInputHash] = useState("");
  const [isVerifying, setIsVerifying] = useState(false);
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
  const [copied, setCopied] = useState(false);
  const [showCertModal, setShowCertModal] = useState(false);

  useEffect(() => {
    if (selectedSeizure) {
      setInputHash(selectedSeizure.sha256Hash);
      handleVerify(selectedSeizure.sha256Hash);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedSeizure]);

  const handleVerify = (hashToVerify?: string) => {
    const raw = (hashToVerify || inputHash).trim();
    const targetHash = raw.toLowerCase().replace(/^0x/, "");
    if (!raw) return;
    setIsVerifying(true);
    setTimeout(() => {
      setIsVerifying(false);
      const isValidHex = /^[0-9a-f]{64}$/i.test(targetHash);
      const match =
        selectedSeizure &&
        (targetHash === selectedSeizure.sha256Hash.toLowerCase() ||
          selectedSeizure.fabricTxId.toLowerCase().replace(/^0x/, "").startsWith(targetHash.slice(0, 24)) ||
          targetHash === selectedSeizure.fabricTxId.toLowerCase().replace(/^0x/, "").slice(0, 64));

      if (match) {
        const s50 =
          selectedSeizure.gazettedOfficerPresent && selectedSeizure.witnessCount >= 2
            ? "STATUTORY SAFEGUARDS COMPLIANT"
            : "PARTIAL — REVIEW SECTION 50 GAPS";
        setVerificationResult({
          verified: true,
          txId: selectedSeizure.fabricTxId,
          blockNumber: selectedSeizure.blockNumber,
          timestamp: selectedSeizure.timestamp,
          officerId: selectedSeizure.officerId,
          signer: "Android StrongBox KeyStore (ECDSA SECP256R1)",
          section50Status: s50,
          notes: "Peer signatures and Merkle inclusion simulated against Fabric channel nnsin-custody.",
        });
        return;
      }

      setVerificationResult({
        verified: false,
        txId: "N/A — TRANSACTION REJECTED",
        blockNumber: 0,
        timestamp: new Date().toISOString(),
        officerId: "UNKNOWN",
        signer: isValidHex ? "UNKNOWN PEER SET" : "INVALID / CORRUPTED",
        section50Status: "VERIFICATION FAILED",
        notes: "Cryptographic hash mismatch. Evidence manifest altered or not present on the loaded channel snapshot.",
      });
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
    const buffer = await file.arrayBuffer();
    const hashBuffer = await crypto.subtle.digest("SHA-256", buffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const calculatedHash = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
    setInputHash(calculatedHash);
    handleVerify(calculatedHash);
  };

  const checks = selectedSeizure
    ? [
        { label: "Gazetted Officer Presence", ok: selectedSeizure.gazettedOfficerPresent },
        { label: "Independent Witness Statements (min. 2)", ok: selectedSeizure.witnessCount >= 2 },
        { label: "Body Search Memo Signed", ok: selectedSeizure.bodySearchMemoSigned },
        { label: "Reagent Test Photo Recorded", ok: selectedSeizure.reagentPhotoRecorded },
      ]
    : [];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-mono text-xs tracking-wider text-textMain flex items-center gap-2">
              <Scale className="w-4 h-4 text-tacticalCyan" />
              SECTION 50 NDPS PROCEDURAL COMPLIANCE
            </h3>
            <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-tacticalEmerald/10 border border-tacticalEmerald/30 text-tacticalEmerald font-bold">
              SEC. 65B IEA / SEC. 63 BSA
            </span>
          </div>
          {selectedSeizure ? (
            <div className="space-y-3">
              {checks.map((c) => (
                <div key={c.label} className="flex items-center justify-between rounded-lg border border-surfaceBorder bg-abyssal/50 px-3 py-2.5">
                  <span className="text-sm text-textSecondary font-medium">{c.label}</span>
                  <span
                    className={`text-[10px] font-mono font-bold px-2 py-1 rounded border ${
                      c.ok
                        ? "bg-tacticalEmerald/10 text-tacticalEmerald border-tacticalEmerald/30"
                        : "bg-tacticalCrimson/10 text-tacticalCrimson border-tacticalCrimson/30"
                    }`}
                  >
                    {c.ok ? "SATISFIED" : "NOT SATISFIED"}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-textMuted">Select a seizure from the registry to audit Section 50 safeguards.</p>
          )}
        </section>

        <section className="rounded-xl border border-surfaceBorder bg-carbon p-6 space-y-3">
          <h3 className="font-mono text-xs tracking-wider text-textMain">LIVE MERKLE PROOF VERIFIER</h3>
          <p className="text-xs text-textMuted font-mono">
            Paste a transaction ID or drug SHA-256 hash to simulate peer signature and block-inclusion audit.
          </p>
          <div className="flex items-center justify-between text-[11px] font-mono">
            <span className="text-textSecondary">SHA-256 / TX ID</span>
            {inputHash && (
              <button onClick={handleCopyHash} className="text-tacticalCyan flex items-center gap-1 font-semibold">
                <Copy className="w-3 h-3" />
                {copied ? "COPIED" : "COPY"}
              </button>
            )}
          </div>
          <textarea
            rows={3}
            value={inputHash}
            onChange={(e) => setInputHash(e.target.value)}
            placeholder="64-character SHA-256 or Fabric Tx ID…"
            className="w-full bg-abyssal border border-surfaceBorder rounded p-2 text-xs font-mono text-textMain placeholder-textMuted focus:outline-none focus:border-tacticalCyan resize-none"
          />
          <label className="border border-dashed border-surfaceBorder hover:border-tacticalCyan rounded-lg p-3 flex flex-col items-center cursor-pointer bg-abyssal/40">
            <FileText className="w-5 h-5 text-textMuted mb-1" />
            <span className="text-[11px] font-mono text-textSecondary">Drop photo / JSON manifest — on-device SHA-256</span>
            <input type="file" onChange={handleFileUpload} className="hidden" />
          </label>
          <button
            onClick={() => handleVerify()}
            disabled={isVerifying || !inputHash.trim()}
            className="w-full bg-tacticalCyan hover:opacity-90 disabled:opacity-50 text-white dark:text-black font-bold text-xs font-mono py-2.5 px-4 rounded flex items-center justify-center gap-2 transition-opacity"
          >
            {isVerifying ? (
              <>
                <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                CONSULTING FABRIC 3.0 RAFT CONSENSUS…
              </>
            ) : (
              <>
                <ShieldCheck className="w-4 h-4" />
                VERIFY BLOCKCHAIN CHAIN-OF-CUSTODY
              </>
            )}
          </button>

          {verificationResult && (
            <div
              className={`border rounded-lg p-4 space-y-2 text-xs font-mono ${
                verificationResult.verified
                  ? "bg-tacticalEmerald/10 border-tacticalEmerald/50 text-textMain"
                  : "bg-tacticalCrimson/10 border-tacticalCrimson/50 text-textMain"
              }`}
            >
              <div className="flex items-center gap-2">
                {verificationResult.verified ? (
                  <CheckCircle2 className="w-5 h-5 text-tacticalEmerald shrink-0" />
                ) : (
                  <AlertOctagon className="w-5 h-5 text-tacticalCrimson shrink-0" />
                )}
                <span className={verificationResult.verified ? "text-tacticalEmerald font-bold" : "text-tacticalCrimson font-bold"}>
                  {verificationResult.verified ? "MERKLE INCLUSION CONFIRMED" : "TAMPER ALERT: HASH MISMATCH"}
                </span>
              </div>
              <div className="text-textMuted">Tx: <span className="text-textMain break-all font-semibold">{verificationResult.txId}</span></div>
              <div className="text-textMuted">Block: <span className="text-tacticalCyan font-bold">#{verificationResult.blockNumber}</span></div>
              <div className="text-textMuted">Signer: <span className="text-tacticalAmber font-semibold">{verificationResult.signer}</span></div>
              <p className="text-textSecondary">{verificationResult.notes}</p>
              {verificationResult.verified && (
                <button
                  onClick={() => setShowCertModal(true)}
                  className="w-full mt-2 bg-carbon border border-tacticalEmerald text-tacticalEmerald font-mono font-bold py-2 rounded flex items-center justify-center gap-2 hover:bg-tacticalEmerald/10 transition-colors"
                >
                  <FileCheck className="w-3.5 h-3.5" />
                  GENERATE SECTION 65B CERTIFICATE
                </button>
              )}
            </div>
          )}
        </section>
      </div>

      <section className="rounded-xl border border-tacticalCyan/30 bg-carbon p-6 print:bg-white print:text-black">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-mono text-xs tracking-wider">CERTIFICATE OF ELECTRONIC EVIDENCE (SEC. 65B IEA / SEC. 63 BSA)</h3>
          <button
            onClick={() => window.print()}
            className="text-xs font-mono border border-surfaceBorder rounded px-3 py-1.5 hover:border-tacticalCyan/50"
          >
            Print preview
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-[1fr_120px] gap-6">
          <div className="text-sm text-textSecondary space-y-3 leading-relaxed font-sans">
            <p className="font-bold text-tacticalCyan font-mono">IN THE COURT OF THE SPECIAL JUDGE (NDPS ACT)</p>
            <p>
              Case Ref: <span className="text-textMain font-semibold font-mono">{selectedSeizure?.firNumber ?? "—"}</span> · Evidence ID: <span className="text-textMain font-semibold font-mono">{selectedSeizure?.id ?? "—"}</span>
              <br />
              Capture: <span className="text-textMain font-mono">{selectedSeizure?.timestamp ?? "—"}</span>
            </p>
            <p>
              Certified that the electronic record was captured on authorized FIPS 140-2 Level 3 StrongBox hardware
              and sealed on Hyperledger Fabric 3.0 (channel nnsin-custody). SHA-256 stamp below is the tamper-evident
              fingerprint of the colorimetric frame and custody JSON.
            </p>
            <p className="font-mono text-[11px] bg-abyssal border border-surfaceBorder rounded p-3 break-all text-textMain">
              SHA-256: {selectedSeizure?.sha256Hash ?? "—"}
              <br />
              Fabric Tx: {selectedSeizure?.fabricTxId ?? "—"}
              <br />
              Block: #{selectedSeizure?.blockNumber ?? "—"} · Endorsers: {selectedSeizure?.endorsements.join(", ") ?? "—"}
            </p>
          </div>
          <div className="flex flex-col items-center gap-2">
            <div className="w-[104px] h-[104px] grid grid-cols-5 grid-rows-5 gap-0.5 bg-white p-1 border border-surfaceBorder shadow-sm">
              {Array.from({ length: 25 }).map((_, i) => (
                <div
                  key={i}
                  className={(selectedSeizure?.sha256Hash.charCodeAt(i % 64) ?? 0) % 2 === 0 ? "bg-black" : "bg-white"}
                />
              ))}
            </div>
            <span className="text-[9px] font-mono text-textMuted font-semibold">QR · LEDGER STAMP</span>
          </div>
        </div>
      </section>

      {showCertModal && (
        <div className="fixed inset-0 bg-black/75 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-carbon border border-tacticalCyan rounded-lg max-w-xl w-full p-6 space-y-4 font-mono shadow-2xl text-textMain">
            <div className="flex items-center justify-between border-b border-surfaceBorder pb-3">
              <span className="font-bold text-sm text-textMain">SECTION 65B CERTIFICATE</span>
              <button onClick={() => setShowCertModal(false)} className="text-xs px-2 py-1 rounded bg-abyssal border border-surfaceBorder text-textSecondary">
                ESC
              </button>
            </div>
            <p className="text-xs text-textSecondary leading-relaxed font-sans">
              Official memorandum for {selectedSeizure?.firNumber}. Hash {inputHash.slice(0, 16)}… is ready for
              judicial submission with Raft CFT (4 consortium peers).
            </p>
            <button
              onClick={() => {
                setShowCertModal(false);
              }}
              className="px-4 py-2 rounded bg-tacticalEmerald text-white dark:text-black font-bold text-xs flex items-center gap-1.5"
            >
              <Download className="w-3.5 h-3.5" />
              Export Official Memorandum
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
