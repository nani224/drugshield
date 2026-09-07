import type { Metadata } from "next";
import "./globals.css";
import { DefenseShell } from "../components/DefenseShell";

export const metadata: Metadata = {
  title: "NNSIN — National Narcotics Seizure Intelligence Network | DrugShield",
  description:
    "Defense-grade command & control dashboard for real-time narcotics seizure intelligence, blockchain chain-of-custody verification, and corridor surveillance.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="bg-slateBg text-white antialiased selection:bg-tacticalCyan selection:text-black">
        <DefenseShell>{children}</DefenseShell>
      </body>
    </html>
  );
}
