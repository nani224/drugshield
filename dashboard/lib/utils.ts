import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";
import type { SeizureStatus } from "../types";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatWeight(grams: number) {
  if (grams >= 1000) return `${(grams / 1000).toFixed(2)} kg`;
  return `${grams.toFixed(1)} g`;
}

export function truncateHash(value: string, lead = 10, tail = 6) {
  if (value.length <= lead + tail + 3) return value;
  return `${value.slice(0, lead)}…${value.slice(-tail)}`;
}

export function statusChipClass(status: SeizureStatus) {
  switch (status) {
    case "ON-CHAIN":
      return "bg-tacticalEmerald/10 text-tacticalEmerald border-tacticalEmerald/30";
    case "CFSL-VERIFIED":
      return "bg-tacticalCyan/10 text-tacticalCyan border-tacticalCyan/30";
    case "IN-TRANSIT":
      return "bg-tacticalAmber/10 text-tacticalAmber border-tacticalAmber/30";
    case "TAMPER-ALERT":
      return "bg-tacticalCrimson/10 text-tacticalCrimson border-tacticalCrimson/30";
  }
}

export async function copyText(value: string) {
  await navigator.clipboard.writeText(value);
}
