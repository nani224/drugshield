import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NNSIN — National Narcotics Seizure Intelligence Network | DrugShield",
  description: "Defense-grade command & control dashboard for real-time narcotics seizure intelligence, blockchain chain-of-custody verification, and corridor surveillance.",
  icons: {
    icon: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="bg-slateBg text-white antialiased selection:bg-tacticalCyan selection:text-black">
        {children}
      </body>
    </html>
  );
}
