import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Invoicing App",
    short_name: "Invoices",
    description: "Projects, materials, time and invoices for small trade businesses.",
    start_url: "/",
    display: "standalone",
    background_color: "#f7f7f2",
    theme_color: "#3f6b3a",
    icons: [{ src: "/favicon.ico", sizes: "any", type: "image/x-icon" }],
  };
}
