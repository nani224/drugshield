"use client";

import React, { useState } from "react";
import { Sidebar } from "./Sidebar";
import { Header } from "./Header";
import { ShellProvider } from "./shell-context";

export function DefenseShell({ children }: { children: React.ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);

  return (
    <ShellProvider value={{ collapsed, setCollapsed, searchOpen, setSearchOpen }}>
      <div className="min-h-screen bg-slateBg text-white flex">
        <Sidebar />
        <div className="flex-1 min-w-0 flex flex-col min-h-screen">
          <Header />
          <main className="flex-1 overflow-y-auto">{children}</main>
        </div>
      </div>
    </ShellProvider>
  );
}
