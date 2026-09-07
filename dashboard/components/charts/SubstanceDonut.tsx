"use client";

import React from "react";
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts";
import { SUBSTANCE_DISTRIBUTION } from "../../mockData";

export function SubstanceDonut() {
  return (
    <div className="h-[280px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={SUBSTANCE_DISTRIBUTION}
            dataKey="percentage"
            nameKey="name"
            innerRadius={62}
            outerRadius={96}
            paddingAngle={3}
          >
            {SUBSTANCE_DISTRIBUTION.map((entry) => (
              <Cell key={entry.name} fill={entry.color} stroke="var(--surface-carbon)" strokeWidth={2} />
            ))}
          </Pie>
          <Tooltip
            formatter={(value, name, item) => {
              const kg = item.payload?.totalKg as number | undefined;
              return [`${value}% · ${kg ?? 0} kg`, String(name)];
            }}
            contentStyle={{
              background: "var(--surface-carbon)",
              border: "1px solid var(--surface-border)",
              borderRadius: "8px",
              color: "var(--text-main)",
              fontSize: 12,
              boxShadow: "var(--card-shadow)",
            }}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
