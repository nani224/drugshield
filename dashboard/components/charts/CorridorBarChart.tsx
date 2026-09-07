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
          <CartesianGrid stroke="#1E293B" strokeDasharray="3 3" />
          <XAxis type="number" stroke="#94A3B8" tick={{ fontSize: 11 }} unit="%" />
          <YAxis
            type="category"
            dataKey="name"
            width={168}
            stroke="#94A3B8"
            tick={{ fontSize: 10 }}
          />
          <Tooltip
            formatter={(value) => [`${value}% interdiction`, "Rate"]}
            contentStyle={{ background: "#121721", border: "1px solid #1E293B", fontSize: 12 }}
          />
          <Bar dataKey="interdictionRate" fill="#00F0FF" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
