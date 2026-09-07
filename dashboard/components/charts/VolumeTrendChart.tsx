"use client";

import React from "react";
import {
  Area,
  CartesianGrid,
  ComposedChart,
  Line,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { MONTHLY_TRENDS } from "../../mockData";

export function VolumeTrendChart() {
  return (
    <div className="h-[320px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <ComposedChart data={MONTHLY_TRENDS} margin={{ top: 8, right: 12, left: 0, bottom: 0 }}>
          <CartesianGrid stroke="var(--surface-border)" strokeDasharray="3 3" />
          <XAxis dataKey="month" stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
          <YAxis yAxisId="kg" stroke="var(--tactical-cyan)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
          <YAxis yAxisId="cr" orientation="right" stroke="var(--tactical-amber)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
          <Tooltip
            contentStyle={{
              background: "var(--surface-carbon)",
              border: "1px solid var(--surface-border)",
              borderRadius: "8px",
              color: "var(--text-main)",
              fontSize: 12,
              boxShadow: "var(--card-shadow)",
            }}
          />
          <Area
            yAxisId="kg"
            type="monotone"
            dataKey="weightKg"
            name="Weight (kg)"
            fill="rgba(var(--tactical-cyan-rgb) / 0.18)"
            stroke="var(--tactical-cyan)"
            strokeWidth={2.5}
          />
          <Line
            yAxisId="cr"
            type="monotone"
            dataKey="streetValueCr"
            name="Street value (₹ Cr)"
            stroke="var(--tactical-amber)"
            strokeWidth={2.5}
            dot={false}
          />
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  );
}
