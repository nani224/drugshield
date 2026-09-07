"use client";

import React from "react";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { DIURNAL_PATTERN } from "../../mockData";

export function DiurnalHeatmap() {
  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={DIURNAL_PATTERN} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
          <CartesianGrid stroke="var(--surface-border)" strokeDasharray="3 3" />
          <XAxis dataKey="hour" stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
          <YAxis stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
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
          <Legend wrapperStyle={{ color: "var(--text-main)", fontSize: 11 }} />
          <Bar dataKey="day" name="Day checkpoint" stackId="a" fill="var(--tactical-amber)" />
          <Bar dataKey="night" name="Night raid" stackId="a" fill="var(--tactical-violet)" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
