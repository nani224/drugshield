"use client";

import React from "react";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { DIURNAL_PATTERN } from "../../mockData";

export function DiurnalHeatmap() {
  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={DIURNAL_PATTERN} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
          <CartesianGrid stroke="#1E293B" strokeDasharray="3 3" />
          <XAxis dataKey="hour" stroke="#94A3B8" tick={{ fontSize: 11 }} />
          <YAxis stroke="#94A3B8" tick={{ fontSize: 11 }} />
          <Tooltip contentStyle={{ background: "#121721", border: "1px solid #1E293B", fontSize: 12 }} />
          <Legend />
          <Bar dataKey="day" name="Day checkpoint" stackId="a" fill="#FFB300" />
          <Bar dataKey="night" name="Night raid" stackId="a" fill="#A855F7" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
