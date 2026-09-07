"use client";

import React from "react";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { AI_ACCURACY_DATA } from "../../mockData";

export function AccuracyMatrix() {
  return (
    <div className="h-[320px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={AI_ACCURACY_DATA} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
          <CartesianGrid stroke="#1E293B" strokeDasharray="3 3" />
          <XAxis dataKey="category" stroke="#94A3B8" tick={{ fontSize: 11 }} />
          <YAxis domain={[85, 100]} stroke="#94A3B8" tick={{ fontSize: 11 }} />
          <Tooltip contentStyle={{ background: "#121721", border: "1px solid #1E293B", fontSize: 12 }} />
          <Legend />
          <Bar dataKey="aiConfidence" name="MobileNetV3 AI" fill="#00F0FF" radius={[4, 4, 0, 0]} />
          <Bar dataKey="cfslConfirmation" name="CFSL GC-MS" fill="#00E676" radius={[4, 4, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
