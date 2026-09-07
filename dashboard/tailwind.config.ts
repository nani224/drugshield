import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        abyssal: "rgb(var(--surface-abyssal-rgb) / <alpha-value>)",
        slateBg: "rgb(var(--bg-slate-rgb) / <alpha-value>)",
        carbon: "rgb(var(--surface-carbon-rgb) / <alpha-value>)",
        surfaceBorder: "rgb(var(--surface-border-rgb) / <alpha-value>)",
        tacticalCyan: "rgb(var(--tactical-cyan-rgb) / <alpha-value>)",
        tacticalEmerald: "rgb(var(--tactical-emerald-rgb) / <alpha-value>)",
        tacticalAmber: "rgb(var(--tactical-amber-rgb) / <alpha-value>)",
        tacticalCrimson: "rgb(var(--tactical-crimson-rgb) / <alpha-value>)",
        tacticalViolet: "rgb(var(--tactical-violet-rgb) / <alpha-value>)",
        textMain: "var(--text-main)",
        textSecondary: "var(--text-secondary)",
        textMuted: "var(--text-muted)",
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
        mono: ["Geist Mono", "JetBrains Mono", "monospace"],
      },
      animation: {
        pulseSlow: "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        scanline: "scanline 8s linear infinite",
      },
      keyframes: {
        scanline: {
          "0%": { transform: "translateY(-100%)" },
          "100%": { transform: "translateY(1000%)" },
        },
      },
      boxShadow: {
        tactical: "var(--card-shadow)",
      },
    },
  },
  plugins: [],
};

export default config;
