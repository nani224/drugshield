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
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  var saved = localStorage.getItem('drugshield_theme');
                  var theme = saved === 'light' ? 'light' : 'dark';
                  document.documentElement.classList.remove('light', 'dark');
                  document.documentElement.classList.add(theme);
                } catch (e) {
                  document.documentElement.classList.add('dark');
                }
              })();
            `,
          }}
        />
      </head>
      <body className="bg-slateBg text-textMain antialiased selection:bg-tacticalCyan selection:text-white dark:selection:text-black">
        <DefenseShell>{children}</DefenseShell>
      </body>
    </html>
  );
}
