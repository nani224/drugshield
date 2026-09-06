"use client";

import React, { useState } from "react";
import { SeizureRecord, DrugCategory } from "../types";
import { Search, Filter, ShieldCheck, Clock, MapPin, Hash, UserCheck } from "lucide-react";

interface SeizureStreamProps {
  seizures: SeizureRecord[];
  selectedSeizure: SeizureRecord | null;
  onSelectSeizure: (seizure: SeizureRecord) => void;
}

export const SeizureStream: React.FC<SeizureStreamProps> = ({
  seizures,
  selectedSeizure,
  onSelectSeizure,
}) => {
  const [activeCategory, setActiveCategory] = useState<string>("ALL");
  const [searchQuery, setSearchQuery] = useState<string>("");

  const categories = ["ALL", "Cocaine", "Meth", "Heroin", "Cannabis", "Synthetic"];

  const filteredSeizures = seizures.filter((s) => {
    const matchesCategory =
      activeCategory === "ALL" || s.category.toLowerCase() === activeCategory.toLowerCase();
    const query = searchQuery.toLowerCase().trim();
    const matchesSearch =
      query === "" ||
      s.id.toLowerCase().includes(query) ||
      s.firNumber.toLowerCase().includes(query) ||
      s.substance.toLowerCase().includes(query) ||
      s.location.toLowerCase().includes(query) ||
      s.officerId.toLowerCase().includes(query);

    return matchesCategory && matchesSearch;
  });

  const getStatusBadge = (status: SeizureRecord["status"]) => {
    switch (status) {
      case "ON-CHAIN":
        return (
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-tacticalEmerald/15 border border-tacticalEmerald/40 text-tacticalEmerald font-semibold flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-tacticalEmerald" />
            ON-CHAIN
          </span>
        );
      case "CFSL-VERIFIED":
        return (
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-tacticalCyan/15 border border-tacticalCyan/40 text-tacticalCyan font-semibold flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-tacticalCyan" />
            CFSL-VERIFIED
          </span>
        );
      case "IN-TRANSIT":
        return (
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-tacticalAmber/15 border border-tacticalAmber/40 text-tacticalAmber font-semibold flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-tacticalAmber" />
            IN-TRANSIT
          </span>
        );
      default:
        return (
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-surfaceBorder text-gray-400">
            {status}
          </span>
        );
    }
  };

  const getSubstanceColor = (category: DrugCategory) => {
    switch (category) {
      case "Cocaine":
        return "text-tacticalCyan border-tacticalCyan/40 bg-tacticalCyan/10";
      case "Meth":
        return "text-tacticalAmber border-tacticalAmber/40 bg-tacticalAmber/10";
      case "Heroin":
        return "text-tacticalViolet border-tacticalViolet/40 bg-tacticalViolet/10";
      case "Cannabis":
        return "text-tacticalEmerald border-tacticalEmerald/40 bg-tacticalEmerald/10";
      case "Synthetic":
        return "text-orange-400 border-orange-400/40 bg-orange-400/10";
      default:
        return "text-gray-300 border-gray-600 bg-gray-800";
    }
  };

  return (
    <div className="flex flex-col h-full bg-carbon border-r border-surfaceBorder">
      {/* Panel Header */}
      <div className="p-3 border-b border-surfaceBorder flex items-center justify-between">
        <div className="flex items-center gap-2">
          <ShieldCheck className="w-4 h-4 text-tacticalCyan" />
          <span className="font-bold text-xs tracking-wider uppercase text-white font-mono">
            LIVE SEIZURE STREAM
          </span>
        </div>
        <span className="text-[11px] font-mono text-tacticalCyan bg-tacticalCyan/10 border border-tacticalCyan/30 px-1.5 py-0.5 rounded">
          {filteredSeizures.length} ACTIVE
        </span>
      </div>

      {/* Search Input */}
      <div className="p-2 border-b border-surfaceBorder bg-abyssal/40">
        <div className="relative">
          <Search className="w-3.5 h-3.5 absolute left-2.5 top-2.5 text-textMuted" />
          <input
            type="text"
            placeholder="Search FIR, Officer ID, Location..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-carbon border border-surfaceBorder rounded pl-8 pr-3 py-1.5 text-xs text-white placeholder-textMuted focus:outline-none focus:border-tacticalCyan font-mono"
          />
        </div>

        {/* Category Pill Filters */}
        <div className="flex items-center gap-1 mt-2 overflow-x-auto pb-1 text-[10px] font-mono scrollbar-none">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setActiveCategory(cat)}
              className={`px-2 py-1 rounded transition-colors whitespace-nowrap uppercase ${
                activeCategory.toLowerCase() === cat.toLowerCase()
                  ? "bg-tacticalCyan text-black font-bold"
                  : "bg-carbon border border-surfaceBorder text-gray-400 hover:text-white"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Scrollable Seizure List */}
      <div className="flex-1 overflow-y-auto divide-y divide-surfaceBorder/60 p-2 space-y-2">
        {filteredSeizures.length === 0 ? (
          <div className="text-center py-12 text-textMuted text-xs font-mono">
            No matching seizures found in current corridor telemetry.
          </div>
        ) : (
          filteredSeizures.map((item) => {
            const isSelected = selectedSeizure?.id === item.id;
            return (
              <div
                key={item.id}
                onClick={() => onSelectSeizure(item)}
                className={`p-3 rounded-lg border transition-all cursor-pointer ${
                  isSelected
                    ? "bg-slateBg border-tacticalCyan shadow-[0_0_12px_rgba(0,240,255,0.15)]"
                    : "bg-abyssal/70 border-surfaceBorder/80 hover:border-gray-500 hover:bg-abyssal"
                }`}
              >
                {/* Header: ID, Status, Category badge */}
                <div className="flex items-center justify-between gap-2 mb-1.5">
                  <span className="font-mono text-xs font-bold text-white tracking-wide">
                    {item.id}
                  </span>
                  {getStatusBadge(item.status)}
                </div>

                {/* Substance Name & Weight */}
                <div className="flex items-center justify-between gap-2 mb-1">
                  <span className="text-xs font-semibold text-gray-200 truncate">
                    {item.substance}
                  </span>
                  <span className="text-xs font-mono font-bold text-tacticalEmerald shrink-0">
                    {item.weightGrams >= 1000
                      ? `${(item.weightGrams / 1000).toFixed(2)} kg`
                      : `${item.weightGrams} g`}
                  </span>
                </div>

                {/* Sub-tag: Reagent Confidence */}
                <div className="flex items-center gap-2 mb-2">
                  <span
                    className={`text-[9px] font-mono px-1.5 py-0.5 rounded border uppercase font-medium ${getSubstanceColor(
                      item.category
                    )}`}
                  >
                    {item.category} • {item.confidence}% Match
                  </span>
                  <span className="text-[10px] text-textMuted font-mono truncate">
                    {item.firNumber}
                  </span>
                </div>

                {/* Location & Officer info */}
                <div className="space-y-1 text-[11px] text-gray-400 font-mono">
                  <div className="flex items-center gap-1.5 truncate">
                    <MapPin className="w-3 h-3 text-tacticalCyan shrink-0" />
                    <span className="truncate">{item.location}</span>
                  </div>

                  <div className="flex items-center justify-between text-[10px]">
                    <div className="flex items-center gap-1 truncate text-gray-400">
                      <UserCheck className="w-3 h-3 text-textMuted" />
                      <span>{item.officerId}</span>
                    </div>
                    <div className="flex items-center gap-1 text-textMuted">
                      <Clock className="w-3 h-3" />
                      <span>{item.timestamp.split(" ")[1]}</span>
                    </div>
                  </div>
                </div>

                {/* Hash pill */}
                <div className="mt-2 pt-2 border-t border-surfaceBorder/40 flex items-center justify-between text-[10px] font-mono text-textMuted">
                  <span className="flex items-center gap-1">
                    <Hash className="w-2.5 h-2.5 text-tacticalCyan" />
                    <span>SHA-256:</span>
                  </span>
                  <span className="text-gray-300 font-semibold truncate max-w-[140px]">
                    {item.sha256Hash.substring(0, 10)}...{item.sha256Hash.substring(58)}
                  </span>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
