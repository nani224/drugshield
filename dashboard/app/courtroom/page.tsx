"use client";

import React, { useState } from "react";
import { CourtroomVerifier } from "../../components/CourtroomVerifier";
import { INITIAL_SEIZURES } from "../../mockData";
import type { SeizureRecord } from "../../types";
import { statusChipClass } from "../../lib/utils";

export default function CourtroomPage() {
  const [selected, setSelected] = useState<SeizureRecord>(INITIAL_SEIZURES[0]);

  return (
    <div className="p-6 lg:p-8 space-y-6 text-textMain">
      <div>
        <p className="text-[10px] font-mono tracking-[0.2em] text-tacticalCyan font-semibold">COURTROOM & NDPS VAULT</p>
        <h1 className="text-2xl font-bold mt-1 text-textMain">Section 50 dossier & electronic evidence desk</h1>
        <p className="text-sm text-textMuted mt-1">
          Procedural compliance, Section 65B certificates, and live Merkle proof verification for Special NDPS Courts.
        </p>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {INITIAL_SEIZURES.map((s) => (
          <button
            key={s.id}
            onClick={() => setSelected(s)}
            className={`shrink-0 rounded-lg border px-3 py-2 text-left transition-colors shadow-sm ${
              selected.id === s.id
                ? "border-tacticalCyan bg-tacticalCyan/15 text-tacticalCyan"
                : "border-surfaceBorder bg-carbon text-textSecondary hover:text-textMain hover:border-tacticalCyan/40"
            }`}
          >
            <div className="font-mono text-[10px] font-bold text-tacticalCyan">{s.firNumber}</div>
            <div className="text-xs mt-0.5 font-medium text-textMain">{s.substance}</div>
            <span className={`inline-block mt-1 text-[9px] font-mono font-semibold px-1.5 py-0.5 rounded border ${statusChipClass(s.status)}`}>
              {s.status}
            </span>
          </button>
        ))}
      </div>

      <CourtroomVerifier selectedSeizure={selected} />
    </div>
  );
}
