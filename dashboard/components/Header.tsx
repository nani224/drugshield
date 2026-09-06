"use client";

import React, { useState, useEffect } from "react";
import { Shield, Radio, Activity, Lock, Cpu, Globe } from "lucide-react";

export const Header: React.FC = () => {
  const [timeStr, setTimeStr] = useState<string>("");
  const [blockHeight, setBlockHeight] = useState<number>(142891);

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTimeStr(
        now.toLocaleDateString("en-IN", {
          day: "2-digit",
          month: "short",
          year: "numeric",
        }) +
          " " +
          now.toLocaleTimeString("en-IN", {
            hour12: false,
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
          }) +
          " IST"
      );
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);

    // Simulate occasional block advancement
    const blockInterval = setInterval(() => {
      setBlockHeight((prev) => prev + 1);
    }, 12000);

    return () => {
      clearInterval(interval);
      clearInterval(blockInterval);
    };
  }, []);

  return (
    <header className="border-b border-surfaceBorder bg-carbon/95 backdrop-blur px-4 py-2.5 flex flex-col md:flex-row items-center justify-between gap-3 sticky top-0 z-50">
      {/* Left: Branding & Node Info */}
      <div className="flex items-center gap-3 w-full md:w-auto">
        <div className="flex items-center justify-center w-10 h-10 rounded-md bg-abyssal border border-tacticalCyan/40 text-tacticalCyan shadow-[0_0_12px_rgba(0,240,255,0.2)]">
          <Shield className="w-6 h-6" />
        </div>
        <div>
          <div className="flex items-center gap-2">
            <span className="font-bold tracking-wider text-sm text-white">
              NATIONAL NARCOTICS SEIZURE INTELLIGENCE NETWORK
            </span>
            <span className="text-[10px] uppercase font-mono px-1.5 py-0.5 rounded bg-tacticalCyan/10 border border-tacticalCyan/30 text-tacticalCyan font-semibold">
              NNSIN-DEFENSE
            </span>
          </div>
          <div className="flex items-center gap-3 text-xs text-textMuted font-mono">
            <span className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-tacticalEmerald animate-ping" />
              SECURE NODE #01 (NEW DELHI HQ)
            </span>
            <span className="text-surfaceBorder">|</span>
            <span className="text-gray-400">SIH26231 • CYBERSECURITY & BLOCKCHAIN</span>
          </div>
        </div>
      </div>

      {/* Center: System Telemetry Badges */}
      <div className="hidden lg:flex items-center gap-4 bg-abyssal/80 border border-surfaceBorder px-3 py-1.5 rounded-lg text-xs font-mono">
        <div className="flex items-center gap-1.5 text-textMuted">
          <Cpu className="w-3.5 h-3.5 text-tacticalCyan" />
          <span>LEDGER:</span>
          <span className="text-tacticalCyan font-semibold">
            #{blockHeight.toLocaleString()}
          </span>
        </div>

        <div className="h-3 w-px bg-surfaceBorder" />

        <div className="flex items-center gap-1.5 text-textMuted">
          <Activity className="w-3.5 h-3.5 text-tacticalEmerald" />
          <span>RAFT CONSENSUS:</span>
          <span className="text-tacticalEmerald font-semibold">4/4 ORGS SYNCED</span>
        </div>

        <div className="h-3 w-px bg-surfaceBorder" />

        <div className="flex items-center gap-1.5 text-textMuted">
          <Lock className="w-3.5 h-3.5 text-tacticalAmber" />
          <span>SIGNER:</span>
          <span className="text-white">STRONGBOX P-256</span>
        </div>
      </div>

      {/* Right: Clock & Operational Readiness */}
      <div className="flex items-center gap-4 w-full md:w-auto justify-between md:justify-end font-mono text-xs">
        <div className="flex items-center gap-2 bg-surfaceBorder/40 px-2.5 py-1 rounded border border-surfaceBorder text-gray-300">
          <Radio className="w-3.5 h-3.5 text-tacticalEmerald animate-pulse" />
          <span>{timeStr || "LOADING TELEMETRY..."}</span>
        </div>

        <div className="flex items-center gap-1.5 px-2 py-1 rounded bg-tacticalEmerald/10 border border-tacticalEmerald/30 text-tacticalEmerald font-bold tracking-wider text-[11px]">
          <span className="w-2 h-2 rounded-full bg-tacticalEmerald" />
          DEFCON 4 • NORMAL
        </div>
      </div>
    </header>
  );
};
