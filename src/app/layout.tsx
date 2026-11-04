import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Invoices",
  description: "Projects, materials, time and invoices for small trade businesses.",
  appleWebApp: { capable: true, title: "Invoices", statusBarStyle: "default" },
};

export const viewport: Viewport = {
  themeColor: "#3f6b3a",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className="bg-[#f7f7f2] text-gray-900 antialiased">{children}</body>
    </html>
  );
}
