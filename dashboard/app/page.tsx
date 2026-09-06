"use client";

import React, { useState } from "react";
import { Header } from "../components/Header";
import { MetricStrip } from "../components/MetricStrip";
import { SeizureStream } from "../components/SeizureStream";
import { CorridorHeatmap } from "../components/CorridorHeatmap";
import { CourtroomVerifier } from "../components/CourtroomVerifier";
import { INITIAL_SEIZURES, HOTSPOT_NODES, CORRIDOR_VECTORS } from "../mockData";
import { SeizureRecord, HotspotNode } from "../types";

export default function DashboardPage() {
  const [seizures] = useState<SeizureRecord[]>(INITIAL_SEIZURES);
  const [selectedSeizure, setSelectedSeizure] = useState<SeizureRecord | null>(
    INITIAL_SEIZURES[0]
  );
  const [hotspots] = useState<HotspotNode[]>(HOTSPOT_NODES);
  const [corridors] = useState(CORRIDOR_VECTORS);

  const handleSelectSeizure = (seizure: SeizureRecord) => {
    setSelectedSeizure(seizure);
  };

  const handleSelectNode = (node: HotspotNode) => {
    // Optionally find a seizure matching the node
    const matchingSeizure = seizures.find(
      (s) => s.category.toLowerCase() === node.dominantSubstance.toLowerCase()
    );
    if (matchingSeizure) {
      setSelectedSeizure(matchingSeizure);
    }
  };

  return (
    <div className="flex flex-col h-screen w-screen bg-slateBg overflow-hidden select-none">
      {/* Top Header Bar */}
      <Header />

      {/* Top Executive KPI Metric Strip */}
      <MetricStrip />

      {/* Main 3-Column Situational Intelligence Cockpit */}
      <main className="flex-1 flex flex-col lg:flex-row min-h-0 overflow-hidden">
        {/* Left Column: Real-time Seizure Stream (340px) */}
        <div className="w-full lg:w-[340px] xl:w-[380px] shrink-0 h-[380px] lg:h-full border-b lg:border-b-0 border-surfaceBorder overflow-hidden">
          <SeizureStream
            seizures={seizures}
            selectedSeizure={selectedSeizure}
            onSelectSeizure={handleSelectSeizure}
          />
        </div>

        {/* Center Column: National 3D Corridor Heatmap Canvas (Flex-1) */}
        <div className="flex-1 h-[450px] lg:h-full min-w-0 border-b lg:border-b-0 border-surfaceBorder overflow-hidden">
          <CorridorHeatmap
            hotspots={hotspots}
            corridors={corridors}
            selectedSeizure={selectedSeizure}
            onSelectNode={handleSelectNode}
          />
        </div>

        {/* Right Column: Courtroom Evidence Verification Dock (360px) */}
        <div className="w-full lg:w-[360px] xl:w-[400px] shrink-0 h-[450px] lg:h-full overflow-hidden">
          <CourtroomVerifier selectedSeizure={selectedSeizure} />
        </div>
      </main>
    </div>
  );
}
