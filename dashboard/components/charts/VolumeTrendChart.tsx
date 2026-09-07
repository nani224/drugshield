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
          <CartesianGrid stroke="#1E293B" strokeDasharray="3 3" />
          <XAxis dataKey="month" stroke="#94A3B8" tick={{ fontSize: 11 }} />
          <YAxis yAxisId="kg" stroke="#00F0FF" tick={{ fontSize: 11 }} />
          <YAxis yAxisId="cr" orientation="right" stroke="#FFB300" tick={{ fontSize: 11 }} />
          <Tooltip
            contentStyle={{ background: "#121721", border: "1px solid #1E293B", fontSize: 12 }}
          />
          <Area
            yAxisId="kg"
            type="monotone"
            dataKey="weightKg"
            name="Weight (kg)"
            fill="rgba(0,240,255,0.18)"
            stroke="#00F0FF"
            strokeWidth={2}
          />
          <Line
            yAxisId="cr"
            type="monotone"
            dataKey="streetValueCr"
            name="Street value (₹ Cr)"
            stroke="#FFB300"
            strokeWidth={2}
            dot={false}
          />
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  );
}
