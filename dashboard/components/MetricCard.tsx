"use client";

import React from "react";
import { LucideIcon, TrendingUp } from "lucide-react";
import { cn } from "../lib/utils";

interface MetricCardProps {
  label: string;
  value: string;
  change: string;
  subtext: string;
  icon: LucideIcon;
  accent: "cyan" | "emerald" | "amber";
  sparkline: number[];
}

const ACCENT = {
  cyan: {
    text: "text-tacticalCyan",
    border: "border-tacticalCyan/30",
    glow: "shadow-[0_0_24px_rgba(var(--tactical-cyan-rgb)/0.08)]",
    stroke: "var(--tactical-cyan)",
  },
  emerald: {
    text: "text-tacticalEmerald",
    border: "border-tacticalEmerald/30",
    glow: "shadow-[0_0_24px_rgba(var(--tactical-emerald-rgb)/0.08)]",
    stroke: "var(--tactical-emerald)",
  },
  amber: {
    text: "text-tacticalAmber",
    border: "border-tacticalAmber/30",
    glow: "shadow-[0_0_24px_rgba(var(--tactical-amber-rgb)/0.08)]",
    stroke: "var(--tactical-amber)",
  },
};

function Sparkline({ data, color }: { data: number[]; color: string }) {
  const min = Math.min(...data);
  const max = Math.max(...data);
  const span = max - min || 1;
  const w = 120;
  const h = 36;
  const pts = data
    .map((v, i) => {
      const x = (i / (data.length - 1)) * w;
      const y = h - ((v - min) / span) * (h - 4) - 2;
      return `${x},${y}`;
    })
    .join(" ");
  return (
    <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-9 mt-3" preserveAspectRatio="none">
      <polyline fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" points={pts} />
    </svg>
  );
}

export function MetricCard({ label, value, change, subtext, icon: Icon, accent, sparkline }: MetricCardProps) {
  const a = ACCENT[accent];
  return (
    <div className={cn("rounded-xl border bg-carbon p-5 shadow-tactical transition-colors", a.border, a.glow)}>
      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="text-[11px] font-mono tracking-wider text-textMuted uppercase font-semibold">{label}</div>
          <div className={cn("text-2xl font-bold font-mono mt-2 tracking-tight", a.text)}>{value}</div>
        </div>
        <div className="p-2.5 rounded-lg bg-abyssal border border-surfaceBorder shadow-inner">
          <Icon className={cn("w-4 h-4", a.text)} />
        </div>
      </div>
      <Sparkline data={sparkline} color={a.stroke} />
      <div className="mt-2 flex items-center justify-between text-[11px] font-mono">
        <span className="text-textSecondary truncate font-medium">{subtext}</span>
        <span className="flex items-center gap-1 text-tacticalEmerald shrink-0 font-bold">
          <TrendingUp className="w-3 h-3" />
          {change}
        </span>
      </div>
    </div>
  );
}
