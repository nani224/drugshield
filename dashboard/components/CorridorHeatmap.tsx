"use client";

import React, { useState } from "react";
import { HotspotNode, CorridorVector, SeizureRecord, DrugCategory } from "../types";
import { Map, Layers, Radio, Shield, Navigation } from "lucide-react";

interface CorridorHeatmapProps {
  hotspots: HotspotNode[];
  corridors: CorridorVector[];
  selectedSeizure: SeizureRecord | null;
  onSelectNode?: (node: HotspotNode) => void;
  compact?: boolean;
  vectorFilter?: "ALL" | DrugCategory;
}

export const CorridorHeatmap: React.FC<CorridorHeatmapProps> = ({
  hotspots,
  corridors,
  selectedSeizure,
  onSelectNode,
  compact = false,
  vectorFilter = "ALL",
}) => {
  const [activeNode, setActiveNode] = useState<HotspotNode | null>(hotspots[0]);
  const [showVectors, setShowVectors] = useState<boolean>(true);
  const [showClusters, setShowClusters] = useState<boolean>(true);

  // Geographic projection helper for India bounds:
  // Lat: 8° N to 36° N, Lng: 68° E to 96° E
  // SVG Canvas viewBox: 0 0 800 900
  const projectCoords = (lat: number, lng: number): { x: number; y: number } => {
    const minLat = 7.0;
    const maxLat = 37.0;
    const minLng = 67.0;
    const maxLng = 98.0;

    const x = ((lng - minLng) / (maxLng - minLng)) * 740 + 30;
    const y = ((maxLat - lat) / (maxLat - minLat)) * 820 + 40;
    return { x, y };
  };

  const getSubstanceColor = (cat: string) => {
    switch (cat) {
      case "Cocaine":
        return "#00F0FF";
      case "Meth":
        return "#FFB300";
      case "Heroin":
        return "#A855F7";
      case "Cannabis":
        return "#00E676";
      case "Synthetic":
        return "#FF5722";
      default:
        return "#FFFFFF";
    }
  };

  return (
    <div className={`flex flex-col ${compact ? "min-h-[460px] h-[460px]" : "min-h-[720px] h-[calc(100vh-220px)]"} bg-slateBg relative overflow-hidden rounded-xl border border-surfaceBorder`}>
      {/* Top Map Toolbar */}
      <div className="p-3 border-b border-surfaceBorder bg-carbon/90 flex flex-wrap items-center justify-between gap-3 z-10">
        <div className="flex items-center gap-2">
          <Map className="w-4 h-4 text-tacticalCyan" />
          <span className="font-bold text-xs tracking-wider uppercase font-mono text-white">
            NATIONAL 3D TRAFFICKING CORRIDOR HEATMAP
          </span>
          <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-tacticalCyan/10 border border-tacticalCyan/30 text-tacticalCyan font-semibold">
            DECK.GL / GEOSPATIAL RADAR
          </span>
        </div>

        {/* Map Layers Toggles */}
        <div className="flex items-center gap-2 font-mono text-[11px]">
          <button
            onClick={() => setShowVectors(!showVectors)}
            className={`px-2.5 py-1 rounded border transition-all flex items-center gap-1.5 ${
              showVectors
                ? "bg-tacticalCyan/20 border-tacticalCyan text-tacticalCyan font-semibold"
                : "bg-abyssal border-surfaceBorder text-gray-400"
            }`}
          >
            <Navigation className="w-3 h-3" />
            <span>FLOW VECTORS</span>
          </button>

          <button
            onClick={() => setShowClusters(!showClusters)}
            className={`px-2.5 py-1 rounded border transition-all flex items-center gap-1.5 ${
              showClusters
                ? "bg-tacticalEmerald/20 border-tacticalEmerald text-tacticalEmerald font-semibold"
                : "bg-abyssal border-surfaceBorder text-gray-400"
            }`}
          >
            <Layers className="w-3 h-3" />
            <span>HOTSPOT NODES</span>
          </button>
        </div>
      </div>

      {/* Main Tactical Map Viewport */}
      <div className="flex-1 relative tactical-grid flex items-center justify-center p-2 overflow-hidden select-none">
        {/* SVG Graphic Map */}
        <svg
          viewBox="0 0 800 900"
          className="w-full h-full max-h-[720px] filter drop-shadow-[0_0_20px_rgba(0,0,0,0.8)]"
        >
          <defs>
            {/* Vector flow gradients */}
            <linearGradient id="grad-crescent" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#A855F7" stopOpacity="0.9" />
              <stop offset="100%" stopColor="#00F0FF" stopOpacity="0.4" />
            </linearGradient>

            <linearGradient id="grad-coastal" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#FFB300" stopOpacity="0.9" />
              <stop offset="100%" stopColor="#00E676" stopOpacity="0.3" />
            </linearGradient>

            {/* Glowing filter */}
            <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
              <feGaussianBlur stdDeviation="3" result="blur" />
              <feComposite in="SourceGraphic" in2="blur" operator="over" />
            </filter>
          </defs>

          {/* India National Border Simplified Tactical Polygon */}
          <polygon
            points="
              220,90 280,60 320,110 370,120 400,160 460,190 530,220 
              640,240 700,280 730,340 680,390 620,400 580,360 550,420 
              530,490 490,570 430,680 390,790 350,810 320,760 300,680 
              240,550 200,480 180,410 140,360 160,280 180,210 220,150
            "
            fill="var(--map-polygon-fill)"
            stroke="var(--map-polygon-stroke)"
            strokeWidth="2.5"
            strokeDasharray="4 2"
          />

          {/* Golden Crescent Border Buffer Zone (North-West) */}
          <path
            d="M 170,160 Q 210,130 260,190"
            fill="none"
            stroke="#FF1744"
            strokeWidth="3"
            strokeDasharray="6 4"
            opacity="0.75"
          />
          <text
            x="120"
            y="145"
            fill="#FF1744"
            fontSize="10"
            fontFamily="JetBrains Mono"
            fontWeight="bold"
            letterSpacing="1"
          >
            GOLDEN CRESCENT INFLUX ZONE
          </text>

          {/* Trafficking Corridor Flow Vectors */}
          {showVectors &&
            corridors
              .filter((c) => vectorFilter === "ALL" || c.dominantVector === vectorFilter)
              .map((corridor) => {
              const start = projectCoords(corridor.originCoords[0], corridor.originCoords[1]);
              const end = projectCoords(corridor.destCoords[0], corridor.destCoords[1]);
              const midX = (start.x + end.x) / 2 + (start.y - end.y) * 0.15;
              const midY = (start.y + end.y) / 2 + (end.x - start.x) * 0.15;

              return (
                <g key={corridor.id}>
                  {/* Outer glow stroke */}
                  <path
                    d={`M ${start.x} ${start.y} Q ${midX} ${midY} ${end.x} ${end.y}`}
                    fill="none"
                    stroke="#00F0FF"
                    strokeWidth="4"
                    strokeOpacity="0.2"
                  />

                  {/* Flow vector animated line */}
                  <path
                    d={`M ${start.x} ${start.y} Q ${midX} ${midY} ${end.x} ${end.y}`}
                    fill="none"
                    stroke="url(#grad-crescent)"
                    strokeWidth="2.5"
                    strokeDasharray="8 6"
                    className="animate-pulse"
                  />

                  {/* Direction Arrow / Circle */}
                  <circle cx={end.x} cy={end.y} r="3" fill="#00F0FF" />
                </g>
              );
            })}

          {/* Hotspot Interception Nodes */}
          {showClusters &&
            hotspots.map((node) => {
              const { x, y } = projectCoords(node.coordinates.lat, node.coordinates.lng);
              const isSelected = activeNode?.id === node.id;
              const color = getSubstanceColor(node.dominantSubstance);

              return (
                <g
                  key={node.id}
                  className="cursor-pointer transition-transform hover:scale-125"
                  onClick={() => {
                    setActiveNode(node);
                    if (onSelectNode) onSelectNode(node);
                  }}
                >
                  {/* Radar pulse ripples */}
                  <circle
                    cx={x}
                    cy={y}
                    r={isSelected ? "22" : "15"}
                    fill="none"
                    stroke={color}
                    strokeWidth="1.2"
                    strokeOpacity="0.4"
                    className="animate-ping"
                  />
                  <circle
                    cx={x}
                    cy={y}
                    r={isSelected ? "14" : "9"}
                    fill="none"
                    stroke={color}
                    strokeWidth="1.5"
                    strokeOpacity="0.8"
                  />

                  {/* Core Node Dot */}
                  <circle
                    cx={x}
                    cy={y}
                    r="5"
                    fill={color}
                    filter="url(#glow)"
                  />

                  {/* Node Label Tag */}
                  <rect
                    x={x + 10}
                    y={y - 12}
                    width={node.name.length * 7 + 16}
                    height="18"
                    rx="3"
                    fill="var(--surface-carbon)"
                    stroke={isSelected ? "var(--tactical-cyan)" : "var(--surface-border)"}
                    strokeWidth="1"
                  />
                  <text
                    x={x + 15}
                    y={y + 1}
                    fill={isSelected ? "var(--tactical-cyan)" : "var(--text-main)"}
                    fontSize="9.5"
                    fontFamily="JetBrains Mono"
                    fontWeight="600"
                  >
                    {node.name}
                  </text>
                </g>
              );
            })}

          {/* Currently Selected Seizure Live GPS Transponder Pin */}
          {selectedSeizure && (
            (() => {
              const { x, y } = projectCoords(
                selectedSeizure.coordinates.lat,
                selectedSeizure.coordinates.lng
              );
              return (
                <g className="cursor-pointer">
                  {/* Heavy ping */}
                  <circle
                    cx={x}
                    cy={y}
                    r="28"
                    fill="none"
                    stroke="#FF1744"
                    strokeWidth="2"
                    strokeOpacity="0.8"
                    className="animate-ping"
                  />
                  {/* Reticle brackets */}
                  <path
                    d={`M ${x - 14} ${y - 6} L ${x - 14} ${y - 14} L ${x - 6} ${y - 14}`}
                    fill="none"
                    stroke="#00F0FF"
                    strokeWidth="2"
                  />
                  <path
                    d={`M ${x + 14} ${y - 6} L ${x + 14} ${y - 14} L ${x + 6} ${y - 14}`}
                    fill="none"
                    stroke="#00F0FF"
                    strokeWidth="2"
                  />
                  <path
                    d={`M ${x - 14} ${y + 6} L ${x - 14} ${y + 14} L ${x - 6} ${y + 14}`}
                    fill="none"
                    stroke="#00F0FF"
                    strokeWidth="2"
                  />
                  <path
                    d={`M ${x + 14} ${y + 6} L ${x + 14} ${y + 14} L ${x + 6} ${y + 14}`}
                    fill="none"
                    stroke="#00F0FF"
                    strokeWidth="2"
                  />

                  <circle cx={x} cy={y} r="4" fill="#FF1744" />

                  {/* Callout box */}
                  <g transform={`translate(${x + 18}, ${y - 25})`}>
                    <rect
                      x="0"
                      y="0"
                      width="190"
                      height="46"
                      rx="4"
                      fill="#000000"
                      stroke="#FF1744"
                      strokeWidth="1.5"
                    />
                    <text
                      x="8"
                      y="15"
                      fill="#FF1744"
                      fontSize="9"
                      fontFamily="JetBrains Mono"
                      fontWeight="bold"
                    >
                      ● LIVE SEIZURE TARGET
                    </text>
                    <text
                      x="8"
                      y="29"
                      fill="#FFFFFF"
                      fontSize="9.5"
                      fontFamily="Inter"
                      fontWeight="bold"
                    >
                      {selectedSeizure.substance.substring(0, 24)}
                    </text>
                    <text
                      x="8"
                      y="40"
                      fill="#94A3B8"
                      fontSize="8.5"
                      fontFamily="JetBrains Mono"
                    >
                      {selectedSeizure.weightGrams}g • {selectedSeizure.id}
                    </text>
                  </g>
                </g>
              );
            })()
          )}
        </svg>

        {/* Legend Overlay (Bottom Left) */}
        <div className="absolute bottom-3 left-3 bg-carbon/95 border border-surfaceBorder rounded-lg p-2.5 font-mono text-[10px] space-y-1.5 shadow-lg backdrop-blur z-10">
          <div className="font-bold text-gray-300 uppercase tracking-wider mb-1 flex items-center gap-1.5">
            <Radio className="w-3 h-3 text-tacticalCyan animate-pulse" />
            <span>SUBSTANCE TAXONOMY</span>
          </div>
          <div className="grid grid-cols-2 gap-x-3 gap-y-1">
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#00F0FF]" />
              <span className="text-gray-300">Cocaine HCl</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#FFB300]" />
              <span className="text-gray-300">Methamphetamine</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#A855F7]" />
              <span className="text-gray-300">Heroin / Opioid</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#00E676]" />
              <span className="text-gray-300">Cannabis Kush</span>
            </div>
          </div>
        </div>

        {/* Active Node Detail Inspector Overlay (Bottom Right) */}
        {activeNode && (
          <div className="absolute bottom-3 right-3 max-w-[280px] bg-carbon/95 border border-tacticalCyan/40 rounded-lg p-3 font-mono text-[11px] shadow-2xl backdrop-blur z-10">
            <div className="flex items-center justify-between gap-2 border-b border-surfaceBorder pb-1.5 mb-2">
              <div className="flex items-center gap-1.5">
                <Shield className="w-3.5 h-3.5 text-tacticalCyan" />
                <span className="font-bold text-textMain text-xs">{activeNode.name}</span>
              </div>
              <span
                className={`text-[9px] px-1.5 py-0.5 rounded font-bold uppercase ${
                  activeNode.riskLevel === "CRITICAL"
                    ? "bg-tacticalCrimson/20 border border-tacticalCrimson text-tacticalCrimson"
                    : "bg-tacticalAmber/20 border border-tacticalAmber text-tacticalAmber"
                }`}
              >
                {activeNode.riskLevel}
              </span>
            </div>

            <div className="space-y-1 text-textSecondary text-[10.5px]">
              <div className="flex justify-between">
                <span className="text-textMuted">State / Jurisdiction:</span>
                <span className="font-semibold text-textMain">{activeNode.state}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-textMuted">Primary Contraband:</span>
                <span
                  className="font-semibold"
                  style={{ color: getSubstanceColor(activeNode.dominantSubstance) }}
                >
                  {activeNode.dominantSubstance}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-textMuted">Interceptions (30D):</span>
                <span className="font-bold text-tacticalCyan">
                  {activeNode.seizureCount30d} seizures
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-textMuted">Total Volume:</span>
                <span className="font-bold text-tacticalEmerald">
                  {activeNode.totalWeightKg} kg
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-textMuted">Coordinates:</span>
                <span className="text-gray-400">
                  {activeNode.coordinates.lat.toFixed(2)}°N,{" "}
                  {activeNode.coordinates.lng.toFixed(2)}°E
                </span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
