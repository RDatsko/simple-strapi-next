import fs from "fs";
import path from "path";
import { notFound } from "next/navigation";
import { generateMetadata as generateSEOMetadata } from "@/lib/utils";

const baseUrl = process.env.NEXT_PUBLIC_STRAPI_API_URL || "http://127.0.0.1:1339/api";
const token = process.env.NEXT_PUBLIC_STRAPI_TOKEN;

const logFile = path.join(process.cwd(), "__strapi-fetch.log");

/**
 * Convert a slug like "/campus/abc" → "campus_abc"
 * or "/" → "index"
 */
function slugToFileName(slug: string): string {
  if (slug === "/") return "index";
  return slug.replace(/^\/|\/$/g, "").replace(/\//g, "_");
}

/**
 * Dynamically load the `.tsx` file and extract its `page` export.
 */
async function getPageExport(slug: string): Promise<string | null> {
  const fileName = slugToFileName(slug);
  const filePath = path.join(process.cwd(), "src/app/pages", `${fileName}.tsx`);

  if (!fs.existsSync(filePath)) {
    console.warn(`⚠️ No page file found for slug: ${slug}`);
fs.writeFileSync(logFile, `⚠️ No page file found for slug: ${slug}\n`);
    return null;
  }

  try {
    // ✅ Use dynamic import relative to the project root alias
    const mod = await import(`../app/pages/${fileName}.tsx`);
    return mod.page || null;
  } catch (err) {
    console.error(`❌ Failed to import page file for slug ${slug}:`, err);
fs.writeFileSync(logFile, `❌ Failed to import page file for slug ${slug}:`);
    return null;
  }
}


export async function fetchFromStrapi(slug: string, query?: string) {
  if (slug.startsWith("/.well-known")) {
    throw new Error("Ignored special .well-known request");
  }
  
  // Remove locale prefix (e.g., /en or /jp)
  slug = slug.replace(/^\/(en|jp)(?=\/|$)/, "");
  if (slug === "") slug = "/";

  // 🔍 Get Strapi endpoint dynamically from corresponding file
  const endpoint = await getPageExport(slug);
  if (!endpoint) {
    fs.writeFileSync(logFile, `❌ No endpoint found for slug: ${slug}\n`);
console.error(`❌ No endpoint found for slug: ${slug}\n`);
    throw new Error(`No page export found for ${slug}`);
  }

  // Build final URL
  const finalUrl = `${baseUrl}${endpoint}${query ? `?${query}` : ""}`;

  // Logging
  fs.writeFileSync(logFile, `🌐 Fetching from: ${finalUrl}\n`);
  fs.appendFileSync(logFile, `Slug: ${slug}\n`);
  fs.appendFileSync(logFile, `==================================================\n`);

  try {
    const res = await fetch(finalUrl, {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      cache: "no-store",
    });

    if (!res.ok) {
      const text = await res.text();
      fs.appendFileSync(logFile, `❌ Fetch failed: ${res.status}\n${text}\n`);
      throw new Error(`❌ Strapi fetch failed: ${res.status} ${res.statusText}\n${text}`);
    }

    const data = await res.json();
    fs.appendFileSync(logFile, `✅ Success: ${JSON.stringify(data, null, 2)}\n`);
// console.log(`\n\n🌐 Fetching from:\n${finalUrl}\n\n${JSON.stringify(data, null, 2)}`);

    return { data, endpoint };
  } catch (err) {
    console.error("🚨 Error fetching from Strapi:", err);
    throw err;
  }
}
