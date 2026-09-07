"use client";

import React from "react";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { AI_ACCURACY_DATA } from "../../mockData";

export function AccuracyMatrix() {
  return (
    <div className="h-[320px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={AI_ACCURACY_DATA} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
          <CartesianGrid stroke="var(--surface-border)" strokeDasharray="3 3" />
          <XAxis dataKey="category" stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
          <YAxis domain={[85, 100]} stroke="var(--text-muted)" tick={{ fontSize: 11, fill: "var(--text-muted)" }} />
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
          <Bar dataKey="aiConfidence" name="MobileNetV3 AI" fill="var(--tactical-cyan)" radius={[4, 4, 0, 0]} />
          <Bar dataKey="cfslConfirmation" name="CFSL GC-MS" fill="var(--tactical-emerald)" radius={[4, 4, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
