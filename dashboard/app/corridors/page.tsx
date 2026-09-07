"use client";

import React, { useState } from "react";
import { CorridorHeatmap } from "../../components/CorridorHeatmap";
import { CORRIDOR_VECTORS, HOTSPOT_NODES, CHECKPOINTS, INITIAL_SEIZURES } from "../../mockData";
import type { DrugCategory } from "../../types";

const FILTERS: Array<"ALL" | DrugCategory> = ["ALL", "Heroin", "Meth", "Cocaine", "Cannabis", "Synthetic"];

function riskClass(level: string) {
  if (level === "CRITICAL") return "bg-tacticalCrimson/10 text-tacticalCrimson border-tacticalCrimson/40 font-bold";
  if (level === "HIGH") return "bg-tacticalAmber/10 text-tacticalAmber border-tacticalAmber/40 font-bold";
  return "bg-tacticalEmerald/10 text-tacticalEmerald border-tacticalEmerald/40 font-bold";
}

function statusClass(status: string) {
  if (status === "INTERCEPTED") return "bg-tacticalCrimson/10 text-tacticalCrimson border-tacticalCrimson/40 font-bold";
  if (status === "ELEVATED") return "bg-tacticalAmber/10 text-tacticalAmber border-tacticalAmber/40 font-bold";
  return "bg-tacticalEmerald/10 text-tacticalEmerald border-tacticalEmerald/40 font-bold";
}

export default function CorridorsPage() {
  const [filter, setFilter] = useState<"ALL" | DrugCategory>("ALL");
  const cards = CORRIDOR_VECTORS.filter((c) => filter === "ALL" || c.dominantVector === filter);

  return (
    <div className="p-6 lg:p-8 space-y-6 text-textMain">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-[10px] font-mono tracking-[0.2em] text-tacticalCyan font-semibold">CORRIDOR SURVEILLANCE RADAR</p>
          <h1 className="text-2xl font-bold mt-1 text-textMain">Geospatial supply-line watch</h1>
        </div>
        <div className="flex flex-wrap gap-1">
          {FILTERS.map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-2.5 py-1 rounded text-[10px] font-mono border transition-colors ${
                filter === f
                  ? "bg-tacticalCyan text-white dark:text-black border-tacticalCyan font-semibold"
                  : "border-surfaceBorder bg-carbon text-textMuted hover:text-textMain hover:border-tacticalCyan/40"
              }`}
            >
              {f === "Heroin" ? "Heroin vectors" : f === "Meth" ? "Meth vectors" : f}
            </button>
          ))}
        </div>
      </div>

      <CorridorHeatmap
        hotspots={HOTSPOT_NODES}
        corridors={CORRIDOR_VECTORS}
        selectedSeizure={INITIAL_SEIZURES[0]}
        vectorFilter={filter}
      />

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {cards.map((c) => (
          <article key={c.id} className="rounded-xl border border-surfaceBorder bg-carbon p-5 space-y-2 shadow-tactical">
            <div className="flex items-start justify-between gap-2">
              <h3 className="font-semibold text-sm text-textMain">{c.name}</h3>
              <span className={`text-[9px] font-mono px-1.5 py-0.5 rounded border ${riskClass(c.riskLevel)}`}>
                {c.riskLevel}
              </span>
            </div>
            <p className="text-xs text-textMuted">
              {c.origin} → {c.destination}
            </p>
            <div className="grid grid-cols-3 gap-2 pt-2 text-center border-t border-surfaceBorder/60">
              <div>
                <div className="text-[10px] font-mono text-textMuted">KG / MO</div>
                <div className="font-mono text-tacticalCyan font-bold">{c.volumeKgPerMonth}</div>
              </div>
              <div>
                <div className="text-[10px] font-mono text-textMuted">SUCCESS</div>
                <div className="font-mono text-tacticalEmerald font-bold">{c.interdictionRate}%</div>
              </div>
              <div>
                <div className="text-[10px] font-mono text-textMuted">POSTS</div>
                <div className="font-mono text-tacticalAmber font-bold">{c.checkposts}</div>
              </div>
            </div>
          </article>
        ))}
      </div>

      <section className="rounded-xl border border-surfaceBorder bg-carbon overflow-x-auto shadow-tactical">
        <div className="px-4 py-3 border-b border-surfaceBorder text-sm font-mono tracking-wider text-textMain font-semibold">
          CHECKPOINT STATUS
        </div>
        <table className="w-full text-sm min-w-[720px]">
          <thead className="text-[10px] font-mono text-textMuted bg-abyssal/80">
            <tr>
              <th className="text-left px-4 py-2.5">CHECKPOINT</th>
              <th className="text-left px-4 py-2.5">CORRIDOR</th>
              <th className="text-left px-4 py-2.5">STATUS</th>
              <th className="text-left px-4 py-2.5">OFFICERS</th>
              <th className="text-left px-4 py-2.5">LAST EVENT</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-surfaceBorder/60">
            {CHECKPOINTS.map((cp) => (
              <tr key={cp.id} className="hover:bg-abyssal/40 transition-colors">
                <td className="px-4 py-2.5 font-medium text-textMain">{cp.name}</td>
                <td className="px-4 py-2.5 text-textMuted font-mono text-xs">{cp.corridor}</td>
                <td className="px-4 py-2.5">
                  <span className={`text-[10px] font-mono px-2 py-0.5 rounded border ${statusClass(cp.status)}`}>
                    {cp.status}
                  </span>
                </td>
                <td className="px-4 py-2.5 font-mono text-xs text-textMain font-semibold">{cp.officers}</td>
                <td className="px-4 py-2.5 text-xs text-textSecondary">{cp.lastEvent}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    </div>
  );
}
