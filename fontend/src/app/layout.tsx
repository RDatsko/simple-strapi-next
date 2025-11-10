import { Open_Sans } from "next/font/google";

import "./globals.css";

const openSans = Open_Sans({
  subsets: ["latin"],
  weight: ["300", "400", "600", "700"],
  display: "swap",
});

export default function RootLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <html>
    <head>
    </head>
    <body className={openSans.className}>
    {children}
    </body>
    </html>
  );
}


