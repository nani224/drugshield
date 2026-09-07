"use client";

import React, { useEffect } from "react";
import { X, Copy, Lock, MapPin, UserCheck, Hash, Camera, FlaskConical } from "lucide-react";
import type { SeizureRecord } from "../types";
import { copyText, formatWeight, statusChipClass, truncateHash } from "../lib/utils";

interface SeizureDrawerProps {
  seizure: SeizureRecord | null;
  onClose: () => void;
}

export function SeizureDrawer({ seizure, onClose }: SeizureDrawerProps) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <>
      <div
        className={`fixed inset-0 z-40 bg-black/50 transition-opacity ${seizure ? "opacity-100" : "opacity-0 pointer-events-none"}`}
        onClick={onClose}
      />
      <aside
        className={`fixed top-0 right-0 z-50 h-full w-full max-w-xl bg-carbon border-l border-surfaceBorder overflow-y-auto transition-transform duration-300 ${
          seizure ? "translate-x-0" : "translate-x-full"
        }`}
      >
        {seizure && (
          <div className="p-6 space-y-6">
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="text-[10px] font-mono text-tacticalCyan tracking-widest">EVIDENCE DOSSIER</div>
                <h2 className="text-xl font-bold mt-1">{seizure.id}</h2>
                <p className="text-sm text-textMuted font-mono mt-1">{seizure.firNumber}</p>
              </div>
              <button onClick={onClose} className="p-2 rounded-md border border-surfaceBorder hover:border-white/40">
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="flex items-center gap-2 flex-wrap">
              <span className={`text-[10px] font-mono px-2 py-1 rounded border ${statusChipClass(seizure.status)}`}>
                {seizure.status}
              </span>
              <span className="text-[10px] font-mono px-2 py-1 rounded border border-surfaceBorder text-gray-300">
                {seizure.category}
              </span>
              <span
                className="inline-flex items-center gap-1.5 text-[10px] font-mono px-2 py-1 rounded border border-surfaceBorder"
              >
                <span className="w-3 h-3 rounded-sm border border-white/20" style={{ background: seizure.colorimetricHex }} />
                {seizure.colorimetricHex}
              </span>
            </div>

            <section className="grid grid-cols-2 gap-3 text-sm">
              <Info label="Substance" value={seizure.substance} />
              <Info label="Net weight" value={formatWeight(seizure.weightGrams)} />
              <Info label="Officer" value={`${seizure.officerName} (${seizure.officerId})`} />
              <Info label="Timestamp" value={seizure.timestamp} />
              <div className="col-span-2">
                <Info
                  label="Location"
                  value={`${seizure.city} · ${seizure.checkpost}`}
                  icon={<MapPin className="w-3 h-3 text-tacticalCyan" />}
                />
                <p className="text-xs text-textMuted mt-1 font-mono">
                  {seizure.location} · {seizure.coordinates.lat.toFixed(4)}°N {seizure.coordinates.lng.toFixed(4)}°E
                </p>
              </div>
            </section>

            <section className="rounded-lg border border-surfaceBorder bg-abyssal/60 p-4 space-y-3">
              <h3 className="text-xs font-mono tracking-wider text-gray-300 flex items-center gap-2">
                <Camera className="w-4 h-4 text-tacticalCyan" />
                ARUCO CAMERA CALIBRATION
              </h3>
              <div className="grid grid-cols-2 gap-2 text-xs font-mono">
                <Info label="Marker ID" value={`#${seizure.aruco.markerId}`} />
                <Info label="Homography RMS" value={seizure.aruco.homographyRms.toFixed(2)} />
                <Info label="Focal length" value={`${seizure.aruco.focalLengthPx} px`} />
                <Info
                  label="Principal point"
                  value={`${seizure.aruco.principalPoint[0]}, ${seizure.aruco.principalPoint[1]}`}
                />
              </div>
            </section>

            <section className="rounded-lg border border-surfaceBorder bg-abyssal/60 p-4 space-y-3">
              <h3 className="text-xs font-mono tracking-wider text-gray-300 flex items-center gap-2">
                <FlaskConical className="w-4 h-4 text-tacticalViolet" />
                CIE L*a*b* COLORIMETRY
              </h3>
              <div className="grid grid-cols-3 gap-2 text-xs font-mono">
                <Info label="L*" value={seizure.cieLab.L.toFixed(1)} />
                <Info label="a*" value={seizure.cieLab.a.toFixed(1)} />
                <Info label="b*" value={seizure.cieLab.b.toFixed(1)} />
              </div>
              <p className="text-[11px] text-textMuted">{seizure.reagentUsed}</p>
            </section>

            <section className="rounded-lg border border-surfaceBorder bg-abyssal/60 p-4 space-y-2 text-xs">
              <h3 className="font-mono tracking-wider text-gray-300 flex items-center gap-2">
                <UserCheck className="w-4 h-4 text-tacticalEmerald" />
                NDPS SECTION 50
              </h3>
              <Row ok={seizure.gazettedOfficerPresent} label="Gazetted officer present" />
              <Row ok={seizure.witnessCount >= 2} label={`Independent witnesses (${seizure.witnessCount})`} />
              <Row ok={seizure.bodySearchMemoSigned} label="Body search memo signed" />
              <Row ok={seizure.reagentPhotoRecorded} label="Reagent test photo recorded" />
            </section>

            <section className="rounded-lg border border-surfaceBorder bg-abyssal/60 p-4 space-y-3 text-xs font-mono">
              <h3 className="tracking-wider text-gray-300 flex items-center gap-2">
                <Lock className="w-4 h-4 text-tacticalCyan" />
                FABRIC BLOCK DETAILS
              </h3>
              <CopyRow label="SHA-256" value={seizure.sha256Hash} />
              <CopyRow label="Tx ID" value={seizure.fabricTxId} />
              <Info label="Block height" value={`#${seizure.blockNumber}`} />
              <div>
                <div className="text-textMuted mb-1">Peer endorsements</div>
                <div className="flex flex-wrap gap-1">
                  {seizure.endorsements.map((e) => (
                    <span key={e} className="px-2 py-0.5 rounded border border-tacticalEmerald/30 text-tacticalEmerald bg-tacticalEmerald/10">
                      {e}
                    </span>
                  ))}
                </div>
              </div>
            </section>
          </div>
        )}
      </aside>
    </>
  );
}

function Info({ label, value, icon }: { label: string; value: string; icon?: React.ReactNode }) {
  return (
    <div>
      <div className="text-[10px] font-mono text-textMuted flex items-center gap-1">
        {icon}
        {label}
      </div>
      <div className="text-sm text-white mt-0.5">{value}</div>
    </div>
  );
}

function Row({ ok, label }: { ok: boolean; label: string }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-gray-300">{label}</span>
      <span className={`font-mono text-[10px] px-2 py-0.5 rounded border ${ok ? "border-tacticalEmerald/30 text-tacticalEmerald bg-tacticalEmerald/10" : "border-tacticalCrimson/30 text-tacticalCrimson bg-tacticalCrimson/10"}`}>
        {ok ? "COMPLIANT" : "DEFICIENT"}
      </span>
    </div>
  );
}

function CopyRow({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-textMuted mb-1 flex items-center gap-1">
        <Hash className="w-3 h-3" />
        {label}
      </div>
      <button
        onClick={() => copyText(value)}
        className="w-full text-left flex items-center justify-between gap-2 rounded border border-surfaceBorder bg-carbon px-2 py-1.5 hover:border-tacticalCyan/40"
      >
        <span className="truncate">{truncateHash(value, 18, 10)}</span>
        <Copy className="w-3 h-3 shrink-0 text-tacticalCyan" />
      </button>
    </div>
  );
}
