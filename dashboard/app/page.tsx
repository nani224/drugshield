"use client";

import React, { useState } from "react";
import Link from "next/link";
import { IndianRupee, Crosshair, ShieldCheck, MapPin, Search } from "lucide-react";
import { MetricCard } from "../components/MetricCard";
import { CorridorHeatmap } from "../components/CorridorHeatmap";
import { SeizureDrawer } from "../components/SeizureDrawer";
import {
  INITIAL_SEIZURES,
  HOTSPOT_NODES,
  CORRIDOR_VECTORS,
  NETWORK_EVENTS,
  KPI_SPARKLINES,
} from "../mockData";
import type { DrugCategory, SeizureRecord } from "../types";
import { formatWeight, statusChipClass } from "../lib/utils";

const REGION_FILTERS: Array<"ALL" | DrugCategory> = [
  "ALL",
  "Heroin",
  "Meth",
  "Cocaine",
  "Cannabis",
  "Synthetic",
];

export default function CommandCockpitPage() {
  const [filter, setFilter] = useState<"ALL" | DrugCategory>("ALL");
  const [selected, setSelected] = useState<SeizureRecord | null>(null);
  const recent = INITIAL_SEIZURES.slice(0, 5);

  return (
    <div className="p-6 lg:p-8 space-y-8 text-textMain">
      <div>
        <p className="text-[10px] font-mono tracking-[0.2em] text-tacticalCyan font-semibold">COMMAND COCKPIT</p>
        <h1 className="text-2xl font-bold mt-1 text-textMain">Live situational overview</h1>
        <p className="text-sm text-textMuted mt-1">
          National interdiction posture — street value, AI confirmation, custody integrity, and corridor vectors.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-6">
        <MetricCard
          label="TOTAL STREET VALUE INTERDICTED"
          value="₹482.5 Cr"
          change="+12.4% MoM"
          subtext="14,892 seizures on ledger"
          icon={IndianRupee}
          accent="cyan"
          sparkline={KPI_SPARKLINES.streetValue}
        />
        <MetricCard
          label="PRESUMPTIVE AI ACCURACY"
          value="98.4%"
          change="CFSL concordant"
          subtext="MobileNetV3 INT8 on-device"
          icon={Crosshair}
          accent="emerald"
          sparkline={KPI_SPARKLINES.accuracy}
        />
        <MetricCard
          label="BLOCKCHAIN CUSTODY INTEGRITY"
          value="100.0%"
          change="0 breaches"
          subtext="Fabric 3.0 private collections"
          icon={ShieldCheck}
          accent="emerald"
          sparkline={KPI_SPARKLINES.integrity}
        />
        <MetricCard
          label="ACTIVE CORRIDORS"
          value="6 Vectors"
          change="128 nodes"
          subtext="Golden Crescent & coastal"
          icon={MapPin}
          accent="amber"
          sparkline={KPI_SPARKLINES.corridors}
        />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-[3fr_2fr] gap-6">
        <div className="space-y-3">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <h2 className="text-sm font-mono tracking-wider text-textMain font-semibold">CORRIDOR HEATMAP SNAPSHOT</h2>
            <div className="flex flex-wrap gap-1">
              {REGION_FILTERS.map((f) => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  className={`px-2.5 py-1 rounded text-[10px] font-mono border transition-colors ${
                    filter === f
                      ? "bg-tacticalCyan text-white dark:text-black border-tacticalCyan font-semibold"
                      : "border-surfaceBorder bg-carbon text-textMuted hover:text-textMain hover:border-tacticalCyan/40"
                  }`}
                >
                  {f}
                </button>
              ))}
            </div>
          </div>
          <CorridorHeatmap
            compact
            vectorFilter={filter}
            hotspots={HOTSPOT_NODES}
            corridors={CORRIDOR_VECTORS}
            selectedSeizure={recent[0]}
          />
        </div>

        <div className="rounded-xl border border-surfaceBorder bg-carbon p-5 flex flex-col shadow-tactical">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-sm font-mono tracking-wider text-textMain font-semibold">PRIORITY SEIZURE TICKER</h2>
            <Link href="/registry" className="text-[10px] font-mono text-tacticalCyan font-semibold hover:underline">
              OPEN REGISTRY →
            </Link>
          </div>
          <div className="space-y-3 flex-1">
            {recent.map((s) => (
              <div key={s.id} className="rounded-lg border border-surfaceBorder bg-abyssal/50 p-3 hover:border-tacticalCyan/30 transition-colors">
                <div className="flex items-center justify-between gap-2">
                  <span className="font-mono text-xs font-semibold text-textMain">{s.id}</span>
                  <span className={`text-[9px] font-mono font-bold px-1.5 py-0.5 rounded border ${statusChipClass(s.status)}`}>
                    {s.status}
                  </span>
                </div>
                <div className="flex items-center gap-2 mt-1.5">
                  <span
                    className="w-3.5 h-3.5 rounded-sm border border-black/20 dark:border-white/20 shrink-0"
                    style={{ background: s.colorimetricHex }}
                    title={s.reagentUsed}
                  />
                  <span className="text-xs text-textSecondary font-medium truncate">{s.substance}</span>
                  <span className="ml-auto text-xs font-mono text-tacticalEmerald font-bold">{formatWeight(s.weightGrams)}</span>
                </div>
                <div className="flex items-center justify-between mt-2 text-[10px] font-mono text-textMuted">
                  <span>{s.timestamp.split(" ")[1]} IST</span>
                  <button
                    onClick={() => setSelected(s)}
                    className="text-tacticalCyan font-semibold hover:underline inline-flex items-center gap-1"
                  >
                    <Search className="w-3 h-3" />
                    Inspect
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <section className="rounded-xl border border-surfaceBorder bg-carbon p-6 shadow-tactical">
        <h2 className="text-sm font-mono tracking-wider mb-4 text-textMain font-semibold">RECENT NETWORK ACTIVITY</h2>
        <ul className="space-y-3">
          {NETWORK_EVENTS.map((e) => (
            <li key={e.id} className="flex items-start gap-3 text-sm border-b border-surfaceBorder/60 pb-3 last:border-0 last:pb-0">
              <span
                className={`mt-1 w-2 h-2 rounded-full shrink-0 ${
                  e.severity === "ALERT"
                    ? "bg-tacticalCrimson"
                    : e.severity === "PRIORITY"
                      ? "bg-tacticalAmber"
                      : "bg-tacticalCyan"
                }`}
              />
              <span className="font-mono text-[10px] text-textMuted w-20 shrink-0 font-medium">{e.timestamp}</span>
              <span className="text-textSecondary">{e.message}</span>
            </li>
          ))}
        </ul>
      </section>

      <SeizureDrawer seizure={selected} onClose={() => setSelected(null)} />
    </div>
  );
}
