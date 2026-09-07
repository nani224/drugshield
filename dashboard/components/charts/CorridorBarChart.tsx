"use client";

import React from "react";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { CORRIDOR_PERFORMANCE } from "../../mockData";

export function CorridorBarChart() {
  return (
    <div className="h-[340px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          layout="vertical"
          data={CORRIDOR_PERFORMANCE}
          margin={{ top: 8, right: 16, left: 8, bottom: 0 }}
        >
          <CartesianGrid stroke="var(--surface-border)" strokeDasharray="3 3" />
          <XAxis type="number" stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} unit="%" />
          <YAxis
            type="category"
            dataKey="name"
            width={168}
            stroke="var(--text-muted)"
            tick={{ fontSize: 10, fill: "var(--text-secondary)" }}
          />
          <Tooltip
            formatter={(value) => [`${value}% interdiction`, "Rate"]}
            contentStyle={{
              background: "var(--surface-carbon)",
              border: "1px solid var(--surface-border)",
              borderRadius: "8px",
              color: "var(--text-main)",
              fontSize: 12,
              boxShadow: "var(--card-shadow)",
            }}
          />
          <Bar dataKey="interdictionRate" fill="var(--tactical-cyan)" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
