"use client";

import React, { useEffect, useMemo, useState } from "react";
import { Activity, Radio, Search, Siren, FileBarChart, Command, Sun, Moon } from "lucide-react";
import { INITIAL_SEIZURES } from "../mockData";
import { useShell } from "./shell-context";

export function Header() {
  const { searchOpen, setSearchOpen, theme, toggleTheme } = useShell();
  const [query, setQuery] = useState("");
  const [timeStr, setTimeStr] = useState("");
  const [secondsFlash, setSecondsFlash] = useState(true);
  const [blockHeight, setBlockHeight] = useState(142891);

  useEffect(() => {
    const tick = () => {
      const now = new Date();
      const date = now.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
      const hms = now.toLocaleTimeString("en-IN", { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" });
      setTimeStr(`${date} ${hms} IST`);
      setSecondsFlash((s) => !s);
    };
    tick();
    const clock = setInterval(tick, 1000);
    const blocks = setInterval(() => setBlockHeight((n) => n + 1), 12000);
    return () => {
      clearInterval(clock);
      clearInterval(blocks);
    };
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setSearchOpen(true);
      }
      if (e.key === "Escape") setSearchOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [setSearchOpen]);

  const hits = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return INITIAL_SEIZURES.slice(0, 5);
    return INITIAL_SEIZURES.filter(
      (s) =>
        s.firNumber.toLowerCase().includes(q) ||
        s.officerName.toLowerCase().includes(q) ||
        s.officerId.toLowerCase().includes(q) ||
        s.substance.toLowerCase().includes(q) ||
        s.sha256Hash.toLowerCase().includes(q) ||
        s.id.toLowerCase().includes(q)
    ).slice(0, 8);
  }, [query]);

  return (
    <header className="sticky top-0 z-40 border-b border-surfaceBorder bg-carbon/95 backdrop-blur px-4 lg:px-6 py-3 flex flex-col xl:flex-row gap-3 xl:items-center transition-colors">
      <button
        onClick={() => setSearchOpen(true)}
        className="flex-1 min-w-0 flex items-center gap-3 rounded-lg border border-surfaceBorder bg-abyssal px-3 py-2 text-sm text-textMuted hover:border-tacticalCyan/50 transition-colors"
      >
        <Search className="w-4 h-4 text-tacticalCyan shrink-0" />
        <span className="truncate">Search FIRs, officers, drugs, SHA-256 hashes…</span>
        <span className="ml-auto hidden sm:flex items-center gap-1 text-[10px] font-mono border border-surfaceBorder rounded px-1.5 py-0.5 bg-carbon text-textSecondary">
          <Command className="w-3 h-3" />K
        </span>
      </button>

      <div className="flex flex-wrap items-center gap-2 justify-end">
        {/* Theme Toggle Button */}
        <button
          onClick={toggleTheme}
          title={theme === "dark" ? "Switch to Light Mode" : "Switch to Dark Mode"}
          className="flex items-center gap-1.5 rounded-lg border border-surfaceBorder px-3 py-2 text-xs font-mono bg-abyssal hover:border-tacticalCyan/50 transition-colors shadow-sm"
        >
          {theme === "dark" ? (
            <>
              <Sun className="w-3.5 h-3.5 text-tacticalAmber" />
              <span className="text-textSecondary">Light</span>
            </>
          ) : (
            <>
              <Moon className="w-3.5 h-3.5 text-tacticalCyan" />
              <span className="text-textSecondary">Dark</span>
            </>
          )}
        </button>

        <div className="flex items-center gap-2 font-mono text-xs border border-surfaceBorder rounded-lg px-3 py-2 bg-abyssal">
          <Radio className="w-3.5 h-3.5 text-tacticalEmerald" />
          <span className="text-textSecondary">{timeStr || "SYNCING CLOCK"}</span>
          <span className={`w-1.5 h-1.5 rounded-full ${secondsFlash ? "bg-tacticalEmerald" : "bg-tacticalEmerald/30"}`} />
        </div>

        <div className="flex items-center gap-2 font-mono text-xs border border-tacticalCyan/30 rounded-lg px-3 py-2 bg-tacticalCyan/10">
          <Activity className="w-3.5 h-3.5 text-tacticalCyan" />
          <span className="text-textMuted">Block</span>
          <span className="text-tacticalCyan font-bold">#{blockHeight.toLocaleString("en-IN")}</span>
        </div>

        <button className="inline-flex items-center gap-1.5 rounded-lg border border-surfaceBorder bg-abyssal px-3 py-2 text-xs font-mono text-textSecondary hover:text-textMain hover:border-tacticalCyan/50 transition-colors">
          <FileBarChart className="w-3.5 h-3.5 text-tacticalCyan" />
          Report
        </button>
        <button className="inline-flex items-center gap-1.5 rounded-lg border border-tacticalCrimson/40 bg-tacticalCrimson/10 px-3 py-2 text-xs font-mono text-tacticalCrimson hover:bg-tacticalCrimson/20 transition-colors">
          <Siren className="w-3.5 h-3.5" />
          Broadcast
        </button>
      </div>

      {searchOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm p-4 flex items-start justify-center pt-[12vh]">
          <div className="w-full max-w-2xl rounded-xl border border-tacticalCyan/40 bg-carbon shadow-2xl overflow-hidden">
            <div className="flex items-center gap-2 border-b border-surfaceBorder px-4 py-3 bg-abyssal/50">
              <Search className="w-4 h-4 text-tacticalCyan" />
              <input
                autoFocus
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="FIR / officer / drug / SHA-256"
                className="flex-1 bg-transparent outline-none text-sm font-mono text-textMain placeholder-textMuted"
              />
              <button
                onClick={() => setSearchOpen(false)}
                className="text-[10px] font-mono text-textMuted border border-surfaceBorder rounded px-1.5 py-0.5 bg-carbon"
              >
                ESC
              </button>
            </div>
            <div className="max-h-[360px] overflow-y-auto divide-y divide-surfaceBorder/60">
              {hits.map((s) => (
                <button
                  key={s.id}
                  onClick={() => setSearchOpen(false)}
                  className="w-full text-left px-4 py-3 hover:bg-abyssal transition-colors"
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="font-mono text-xs text-tacticalCyan font-semibold">{s.firNumber}</span>
                    <span className="text-[10px] font-mono text-textMuted">{s.id}</span>
                  </div>
                  <div className="text-sm text-textMain font-medium mt-0.5">{s.substance} · {s.officerName}</div>
                  <div className="text-[10px] font-mono text-textMuted mt-1 truncate">{s.sha256Hash}</div>
                </button>
              ))}
              {hits.length === 0 && (
                <div className="px-4 py-8 text-center text-xs font-mono text-textMuted">No ledger matches.</div>
              )}
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
