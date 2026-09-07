"use client";

import React from "react";
import { VolumeTrendChart } from "../../components/charts/VolumeTrendChart";
import { SubstanceDonut } from "../../components/charts/SubstanceDonut";
import { AccuracyMatrix } from "../../components/charts/AccuracyMatrix";
import { CorridorBarChart } from "../../components/charts/CorridorBarChart";
import { DiurnalHeatmap } from "../../components/charts/DiurnalHeatmap";
import { SUBSTANCE_DISTRIBUTION } from "../../mockData";

export default function AnalyticsPage() {
  return (
    <div className="p-6 lg:p-8 space-y-8">
      <div>
        <p className="text-[10px] font-mono tracking-[0.2em] text-tacticalCyan">NARCOTICS ANALYTICS</p>
        <h1 className="text-2xl font-bold mt-1">Intelligence hub</h1>
        <p className="text-sm text-textMuted mt-1">
          Visual trends across volume, street value, substance mix, AI vs CFSL confirmation, and patrol timing.
        </p>
      </div>

      <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
        <h2 className="text-sm font-mono tracking-wider mb-1">12-MONTH SEIZURE VOLUME & STREET VALUE</h2>
        <p className="text-xs text-textMuted mb-4">Kilograms seized vs intercepted street value (₹ Crores)</p>
        <VolumeTrendChart />
      </section>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
          <h2 className="text-sm font-mono tracking-wider mb-4">SUBSTANCE DISTRIBUTION</h2>
          <SubstanceDonut />
          <div className="grid grid-cols-2 gap-2 mt-2">
            {SUBSTANCE_DISTRIBUTION.map((s) => (
              <div key={s.name} className="flex items-center gap-2 text-xs font-mono">
                <span className="w-2.5 h-2.5 rounded-full" style={{ background: s.color }} />
                <span className="text-gray-300">
                  {s.name} {s.percentage}% · {s.totalKg} kg
                </span>
              </div>
            ))}
          </div>
        </section>

        <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
          <h2 className="text-sm font-mono tracking-wider mb-1">AI VISION VS LABORATORY CONFIRMATION</h2>
          <p className="text-xs text-textMuted mb-4">MobileNetV3 presumptive vs CFSL GC-MS</p>
          <AccuracyMatrix />
        </section>
      </div>

      <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
        <h2 className="text-sm font-mono tracking-wider mb-1">BORDER CORRIDOR INTERDICTION VELOCITY</h2>
        <p className="text-xs text-textMuted mb-4">Ranked success rate by supply line</p>
        <CorridorBarChart />
      </section>

      <section className="rounded-xl border border-surfaceBorder bg-carbon p-6">
        <h2 className="text-sm font-mono tracking-wider mb-1">INTERCEPTION TIME-OF-DAY PATTERN</h2>
        <p className="text-xs text-textMuted mb-4">Night raids vs day checkpoint seizures</p>
        <DiurnalHeatmap />
      </section>
    </div>
  );
}
