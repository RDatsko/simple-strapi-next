import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  images: {
    remotePatterns: [
      {
        hostname: "127.0.0.1",
        protocol: "http",
        port: "1339",
      },
      {
        hostname: "localhost",
        protocol: "http",
        port: "1339",
      },
    ],
  },
  // Allow self-signed certificates in development
  serverExternalPackages: [],
  // Add proper caching configuration
  experimental: {
    serverActions: {
      allowedOrigins: [
        "localhost:1339",
        "localhost:3000",
      ],
    },
  },
};

export default nextConfig;
