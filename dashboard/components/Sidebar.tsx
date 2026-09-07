"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Shield,
  Radar,
  ClipboardList,
  LineChart,
  Globe2,
  Scale,
  ChevronLeft,
  ChevronRight,
  SatelliteDish,
  User,
  Sun,
  Moon,
} from "lucide-react";
import { cn } from "../lib/utils";
import { useShell } from "./shell-context";

const NAV = [
  { href: "/", label: "Command Cockpit", icon: Radar, badge: null as string | null },
  { href: "/registry", label: "Seizure Registry", icon: ClipboardList, badge: "14,892" },
  { href: "/analytics", label: "Narcotics Analytics", icon: LineChart, badge: "LIVE" },
  { href: "/corridors", label: "Corridor Radar", icon: Globe2, badge: "6 ACTIVE" },
  { href: "/courtroom", label: "Courtroom & NDPS Vault", icon: Scale, badge: "SEC 50" },
];

export function Sidebar() {
  const pathname = usePathname();
  const { collapsed, setCollapsed, theme, toggleTheme } = useShell();

  return (
    <aside
      className={cn(
        "sticky top-0 h-screen shrink-0 border-r border-surfaceBorder bg-carbon flex flex-col transition-all duration-300 select-none",
        collapsed ? "w-[76px]" : "w-[272px]"
      )}
    >
      <div className="p-4 border-b border-surfaceBorder flex items-center gap-3">
        <div className="relative shrink-0 w-11 h-11 rounded-md bg-abyssal border border-tacticalCyan/40 text-tacticalCyan flex items-center justify-center shadow-[0_0_16px_rgba(var(--tactical-cyan-rgb)/0.2)]">
          <Shield className="w-6 h-6" />
          <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-tacticalEmerald animate-pulse" />
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <div className="font-bold tracking-widest text-sm text-textMain">DRUGSHIELD</div>
            <div className="text-[10px] font-mono text-tacticalCyan tracking-wider font-semibold">
              NNSIN | DEFENSE INTELLIGENCE
            </div>
          </div>
        )}
      </div>

      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {NAV.map((item) => {
          const active = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              title={item.label}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors border font-medium",
                active
                  ? "bg-tacticalCyan/15 border-tacticalCyan/50 text-tacticalCyan font-semibold"
                  : "border-transparent text-textSecondary hover:text-textMain hover:bg-abyssal"
              )}
            >
              <Icon className="w-4 h-4 shrink-0" />
              {!collapsed && (
                <>
                  <span className="flex-1 truncate">{item.label}</span>
                  {item.badge && (
                    <span
                      className={cn(
                        "text-[9px] font-mono font-bold px-1.5 py-0.5 rounded border",
                        active
                          ? "border-tacticalCyan/40 text-tacticalCyan bg-abyssal"
                          : "border-surfaceBorder text-textMuted bg-abyssal"
                      )}
                    >
                      {item.badge}
                    </span>
                  )}
                </>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="p-3 border-t border-surfaceBorder space-y-3">
        {!collapsed && (
          <div className="rounded-lg border border-surfaceBorder bg-abyssal/70 p-3 text-[10px] font-mono space-y-1.5">
            <div className="flex items-center gap-1.5 text-tacticalEmerald font-bold">
              <SatelliteDish className="w-3 h-3" />
              <span>NODE STATUS</span>
            </div>
            <div className="text-textSecondary">Hyperledger Fabric 3.0: SYNCHRONIZED</div>
            <div className="text-textMuted">Peer: ncb-delhi-peer0</div>
          </div>
        )}

        {/* User Profile */}
        <div className={cn("flex items-center gap-2", collapsed && "justify-center")}>
          <div className="w-8 h-8 rounded-full bg-abyssal border border-tacticalCyan/40 flex items-center justify-center shrink-0">
            <User className="w-4 h-4 text-tacticalCyan" />
          </div>
          {!collapsed && (
            <div className="min-w-0">
              <div className="text-xs font-semibold text-textMain truncate">Director General, ANTF</div>
              <div className="text-[10px] font-mono text-tacticalAmber font-bold">OMEGA-4</div>
            </div>
          )}
        </div>

        {/* Theme Mode Toggle Button */}
        <button
          onClick={toggleTheme}
          className={cn(
            "w-full flex items-center justify-between rounded-md border border-surfaceBorder px-3 py-1.5 text-xs font-mono bg-abyssal text-textSecondary hover:text-textMain hover:border-tacticalCyan/40 transition-colors",
            collapsed && "justify-center px-0"
          )}
          title={theme === "dark" ? "Switch to Light Mode" : "Switch to Dark Mode"}
        >
          <div className="flex items-center gap-2">
            {theme === "dark" ? <Sun className="w-3.5 h-3.5 text-tacticalAmber" /> : <Moon className="w-3.5 h-3.5 text-tacticalCyan" />}
            {!collapsed && <span>{theme === "dark" ? "Light Mode" : "Dark Mode"}</span>}
          </div>
          {!collapsed && (
            <span className="text-[9px] uppercase font-bold text-tacticalCyan">
              {theme}
            </span>
          )}
        </button>

        {/* Collapse button */}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="w-full flex items-center justify-center gap-2 rounded-md border border-surfaceBorder py-1.5 text-xs text-textMuted hover:text-textMain hover:border-tacticalCyan/40 transition-colors"
        >
          {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          {!collapsed && <span>Collapse</span>}
        </button>
      </div>
    </aside>
  );
}
