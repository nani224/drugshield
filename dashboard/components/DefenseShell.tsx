"use client";

import React from "react";
import { Sidebar } from "./Sidebar";
import { Header } from "./Header";
import { ShellProvider } from "./shell-context";

function DefenseShellInner({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-slateBg text-textMain flex transition-colors duration-200">
      <Sidebar />
      <div className="flex-1 min-w-0 flex flex-col min-h-screen">
        <Header />
        <main className="flex-1 overflow-y-auto">{children}</main>
      </div>
    </div>
  );
}

export function DefenseShell({ children }: { children: React.ReactNode }) {
  return (
    <ShellProvider>
      <DefenseShellInner>{children}</DefenseShellInner>
    </ShellProvider>
  );
}
