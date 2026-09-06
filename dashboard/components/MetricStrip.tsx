"use client";

import React from "react";
import { PackageSearch, Crosshair, ShieldCheck, MapPin, TrendingUp, CheckCircle2 } from "lucide-react";

export const MetricStrip: React.FC = () => {
  const metrics = [
    {
      id: "total-seizures",
      label: "TOTAL SEIZURES RECORDED",
      value: "14,892",
      change: "+12.4% MoM",
      subtext: "₹482.5 Cr Street Value Disrupted",
      icon: PackageSearch,
      accentColor: "text-tacticalCyan",
      borderColor: "border-tacticalCyan/30",
      glowColor: "border-glow-cyan",
      badge: "LIVE RECORD",
    },
    {
      id: "presumptive-accuracy",
      label: "PRESUMPTIVE ACCURACY RATE",
      value: "98.4%",
      change: "CFSL Confirmed",
      subtext: "MobileNetV3 INT8 On-Device (<25ms)",
      icon: Crosshair,
      accentColor: "text-tacticalEmerald",
      borderColor: "border-tacticalEmerald/30",
      glowColor: "border-glow-emerald",
      badge: "AI VISION",
    },
    {
      id: "blockchain-integrity",
      label: "BLOCKCHAIN AUDIT INTEGRITY",
      value: "100.0%",
      change: "0 Custody Breaches",
      subtext: "Fabric 3.0 Private Data Collections",
      icon: ShieldCheck,
      accentColor: "text-tacticalEmerald",
      borderColor: "border-tacticalEmerald/30",
      glowColor: "border-glow-emerald",
      badge: "SECP256R1",
    },
    {
      id: "active-checkpoints",
      label: "ACTIVE INTERCEPTION NODES",
      value: "128 Nodes",
      change: "6 Border Corridors",
      subtext: "Golden Crescent & Coastal Vectors",
      icon: MapPin,
      accentColor: "text-tacticalAmber",
      borderColor: "border-tacticalAmber/30",
      glowColor: "border-glow-amber",
      badge: "RADAR ACTIVE",
    },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 p-4 bg-abyssal/60 border-b border-surfaceBorder">
      {metrics.map((m) => {
        const Icon = m.icon;
        return (
          <div
            key={m.id}
            className={`bg-carbon/90 border ${m.borderColor} rounded-lg p-3.5 flex flex-col justify-between relative overflow-hidden transition-all hover:border-white/30`}
          >
            {/* Top Row: Label & Badge */}
            <div className="flex items-center justify-between gap-2 mb-2">
              <span className="text-[11px] font-mono text-textMuted tracking-wider truncate">
                {m.label}
              </span>
              <span className="text-[9px] font-mono font-bold px-1.5 py-0.5 rounded bg-abyssal border border-surfaceBorder text-gray-400">
                {m.badge}
              </span>
            </div>

            {/* Middle Row: Big Metric & Icon */}
            <div className="flex items-baseline justify-between gap-2 my-1">
              <span className={`text-2xl font-bold font-mono tracking-tight ${m.accentColor}`}>
                {m.value}
              </span>
              <div className="p-1.5 rounded bg-abyssal/80 border border-surfaceBorder">
                <Icon className={`w-4 h-4 ${m.accentColor}`} />
              </div>
            </div>

            {/* Bottom Row: Trend & Subtext */}
            <div className="mt-2 pt-2 border-t border-surfaceBorder/60 flex items-center justify-between text-[11px] font-mono">
              <span className="text-gray-400 truncate">{m.subtext}</span>
              <span className="flex items-center gap-1 text-tacticalEmerald font-medium shrink-0">
                <TrendingUp className="w-3 h-3" />
                {m.change}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
};
