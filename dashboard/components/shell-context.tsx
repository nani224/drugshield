"use client";

import React, { createContext, useContext, useEffect, useState } from "react";

export interface ShellContextValue {
  collapsed: boolean;
  setCollapsed: (v: boolean) => void;
  searchOpen: boolean;
  setSearchOpen: (v: boolean) => void;
  theme: "dark" | "light";
  toggleTheme: () => void;
  setTheme: (t: "dark" | "light") => void;
}

const ShellContext = createContext<ShellContextValue | null>(null);

export function ShellProvider({ children }: { children: React.ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [theme, setThemeState] = useState<"dark" | "light">("dark");

  useEffect(() => {
    try {
      const saved = localStorage.getItem("drugshield_theme") as "dark" | "light" | null;
      const initial = saved === "light" ? "light" : "dark";
      setThemeState(initial);
      document.documentElement.classList.remove("light", "dark");
      document.documentElement.classList.add(initial);
    } catch {
      // Default to dark
    }
  }, []);

  const setTheme = (t: "dark" | "light") => {
    setThemeState(t);
    try {
      localStorage.setItem("drugshield_theme", t);
    } catch {}
    document.documentElement.classList.remove("light", "dark");
    document.documentElement.classList.add(t);
  };

  const toggleTheme = () => {
    setTheme(theme === "dark" ? "light" : "dark");
  };

  return (
    <ShellContext.Provider
      value={{
        collapsed,
        setCollapsed,
        searchOpen,
        setSearchOpen,
        theme,
        toggleTheme,
        setTheme,
      }}
    >
      {children}
    </ShellContext.Provider>
  );
}

export function useShell() {
  const ctx = useContext(ShellContext);
  if (!ctx) throw new Error("useShell must be used within DefenseShell");
  return ctx;
}
