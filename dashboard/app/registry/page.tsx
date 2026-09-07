"use client";

import React, { useMemo, useState } from "react";
import { Copy, Lock, Search } from "lucide-react";
import { INITIAL_SEIZURES } from "../../mockData";
import type { DrugCategory, SeizureRecord, SeizureStatus } from "../../types";
import { copyText, formatWeight, statusChipClass, truncateHash } from "../../lib/utils";
import { SeizureDrawer } from "../../components/SeizureDrawer";

const SUBSTANCES: Array<"ALL" | DrugCategory> = ["ALL", "Cocaine", "Meth", "Heroin", "Cannabis", "Synthetic"];
const STATUSES: Array<"ALL" | SeizureStatus> = ["ALL", "ON-CHAIN", "CFSL-VERIFIED", "IN-TRANSIT", "TAMPER-ALERT"];

export default function RegistryPage() {
  const [q, setQ] = useState("");
  const [substance, setSubstance] = useState<"ALL" | DrugCategory>("ALL");
  const [status, setStatus] = useState<"ALL" | SeizureStatus>("ALL");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [selected, setSelected] = useState<SeizureRecord | null>(null);

  const rows = useMemo(() => {
    return INITIAL_SEIZURES.filter((s) => {
      const query = q.trim().toLowerCase();
      const matchQ =
        !query ||
        s.firNumber.toLowerCase().includes(query) ||
        s.officerName.toLowerCase().includes(query) ||
        s.officerId.toLowerCase().includes(query) ||
        s.id.toLowerCase().includes(query);
      const matchSub = substance === "ALL" || s.category === substance;
      const matchSt = status === "ALL" || s.status === status;
      const day = s.timestamp.slice(0, 10);
      const matchFrom = !from || day >= from;
      const matchTo = !to || day <= to;
      return matchQ && matchSub && matchSt && matchFrom && matchTo;
    });
  }, [q, substance, status, from, to]);

  return (
    <div className="p-6 lg:p-8 space-y-6">
      <div>
        <p className="text-[10px] font-mono tracking-[0.2em] text-tacticalCyan">SEIZURE REGISTRY & LEDGER</p>
        <h1 className="text-2xl font-bold mt-1">Full-width evidence data hub</h1>
      </div>

      <div className="rounded-xl border border-surfaceBorder bg-carbon p-4 space-y-3">
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-2.5 text-textMuted" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search FIR / officer / seizure ID"
            className="w-full bg-abyssal border border-surfaceBorder rounded-lg pl-10 pr-3 py-2 text-sm font-mono focus:outline-none focus:border-tacticalCyan"
          />
        </div>
        <div className="flex flex-wrap gap-2 items-center">
          {SUBSTANCES.map((s) => (
            <button
              key={s}
              onClick={() => setSubstance(s)}
              className={`px-2.5 py-1 rounded text-[10px] font-mono border ${
                substance === s ? "bg-tacticalCyan text-black border-tacticalCyan" : "border-surfaceBorder text-gray-400"
              }`}
            >
              {s}
            </button>
          ))}
          <span className="w-px h-4 bg-surfaceBorder" />
          {STATUSES.map((s) => (
            <button
              key={s}
              onClick={() => setStatus(s)}
              className={`px-2.5 py-1 rounded text-[10px] font-mono border ${
                status === s ? "bg-tacticalEmerald/20 text-tacticalEmerald border-tacticalEmerald/40" : "border-surfaceBorder text-gray-400"
              }`}
            >
              {s}
            </button>
          ))}
          <input
            type="date"
            value={from}
            onChange={(e) => setFrom(e.target.value)}
            className="ml-auto bg-abyssal border border-surfaceBorder rounded px-2 py-1 text-[11px] font-mono"
          />
          <input
            type="date"
            value={to}
            onChange={(e) => setTo(e.target.value)}
            className="bg-abyssal border border-surfaceBorder rounded px-2 py-1 text-[11px] font-mono"
          />
        </div>
      </div>

      <div className="rounded-xl border border-surfaceBorder bg-carbon overflow-x-auto">
        <table className="min-w-[1080px] w-full text-left text-sm">
          <thead className="text-[10px] font-mono tracking-wider text-textMuted border-b border-surfaceBorder bg-abyssal/80">
            <tr>
              <th className="px-4 py-3">FIR / SEIZURE ID</th>
              <th className="px-4 py-3">DATE / LOCATION</th>
              <th className="px-4 py-3">SUBSTANCE</th>
              <th className="px-4 py-3">NET WEIGHT</th>
              <th className="px-4 py-3">AI CONFIDENCE</th>
              <th className="px-4 py-3">FABRIC TX</th>
              <th className="px-4 py-3">ACTION</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((s) => (
              <tr key={s.id} className="border-b border-surfaceBorder/70 hover:bg-abyssal/40">
                <td className="px-4 py-3 align-top">
                  <div className="font-mono text-xs text-tacticalCyan">{s.firNumber}</div>
                  <button
                    onClick={() => copyText(s.id)}
                    className="mt-1 inline-flex items-center gap-1 text-[10px] font-mono text-gray-400 hover:text-white"
                  >
                    {s.id} <Copy className="w-3 h-3" />
                  </button>
                </td>
                <td className="px-4 py-3 align-top text-xs">
                  <div>{s.timestamp}</div>
                  <div className="text-textMuted mt-1">
                    {s.city} · {s.checkpost}
                  </div>
                  <div className="font-mono text-[10px] text-textMuted">
                    {s.coordinates.lat.toFixed(3)}°N {s.coordinates.lng.toFixed(3)}°E
                  </div>
                </td>
                <td className="px-4 py-3 align-top">
                  <div className="flex items-center gap-2">
                    <span
                      className="w-4 h-4 rounded-sm border border-white/20"
                      style={{ background: s.colorimetricHex }}
                      title={s.reagentUsed}
                    />
                    <div>
                      <div className="text-xs">{s.substance}</div>
                      <div className="text-[10px] font-mono text-textMuted">{s.reagentUsed}</div>
                    </div>
                  </div>
                </td>
                <td className="px-4 py-3 align-top">
                  <div className="font-mono text-xs text-tacticalEmerald">{formatWeight(s.weightGrams)}</div>
                  <div className="mt-1 h-1.5 w-24 rounded bg-abyssal overflow-hidden">
                    <div
                      className="h-full bg-tacticalCyan"
                      style={{ width: `${Math.min(100, (s.weightGrams / 8500) * 100)}%` }}
                    />
                  </div>
                </td>
                <td className="px-4 py-3 align-top">
                  <ConfidenceRing value={s.confidence} />
                </td>
                <td className="px-4 py-3 align-top">
                  <div className="flex items-center gap-1.5">
                    <Lock className="w-3.5 h-3.5 text-tacticalEmerald" />
                    <span className={`text-[9px] font-mono px-1.5 py-0.5 rounded border ${statusChipClass(s.status)}`}>
                      {s.status}
                    </span>
                  </div>
                  <button
                    onClick={() => copyText(s.fabricTxId)}
                    className="mt-1 font-mono text-[10px] text-gray-400 hover:text-tacticalCyan inline-flex items-center gap-1"
                  >
                    {truncateHash(s.fabricTxId, 12, 6)} <Copy className="w-3 h-3" />
                  </button>
                </td>
                <td className="px-4 py-3 align-top">
                  <button
                    onClick={() => setSelected(s)}
                    className="text-[11px] font-mono px-3 py-1.5 rounded border border-tacticalCyan/40 text-tacticalCyan hover:bg-tacticalCyan/10"
                  >
                    Inspect Dossier
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {rows.length === 0 && (
          <div className="p-10 text-center text-xs font-mono text-textMuted">No seizures match current filters.</div>
        )}
      </div>

      <SeizureDrawer seizure={selected} onClose={() => setSelected(null)} />
    </div>
  );
}

function ConfidenceRing({ value }: { value: number }) {
  const r = 16;
  const c = 2 * Math.PI * r;
  const offset = c - (value / 100) * c;
  return (
    <div className="flex items-center gap-2">
      <svg width="40" height="40" viewBox="0 0 40 40">
        <circle cx="20" cy="20" r={r} fill="none" stroke="#1E293B" strokeWidth="3" />
        <circle
          cx="20"
          cy="20"
          r={r}
          fill="none"
          stroke="#00E676"
          strokeWidth="3"
          strokeDasharray={c}
          strokeDashoffset={offset}
          transform="rotate(-90 20 20)"
        />
      </svg>
      <span className="font-mono text-xs">{value.toFixed(1)}%</span>
    </div>
  );
}
