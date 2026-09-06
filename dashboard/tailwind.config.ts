import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        abyssal: "#000000",
        slateBg: "#0B0F17",
        carbon: "#121721",
        surfaceBorder: "#1E293B",
        tacticalCyan: "#00F0FF",
        tacticalEmerald: "#00E676",
        tacticalAmber: "#FFB300",
        tacticalCrimson: "#FF1744",
        tacticalViolet: "#A855F7",
        textMuted: "#94A3B8",
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
    },
  },
  plugins: [],
};

export default config;
