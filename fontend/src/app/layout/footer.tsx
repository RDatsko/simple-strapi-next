import { StrapiMedia } from "@/services/models";

export default async function Footer({
  type,
  locale,
}: {
  type: string;
  locale: string;
}) {
  const normalizedType = type?.toLowerCase() || "default";

  const FOOTER_MAP: Record<string, string> = {
    transparent: "trp4nykfpu21buj4o27122z2",
    white: "trp4nykfpu21buj4o27122z2",
    default: "trp4nykfpu21buj4o27122z2",
  };

  const queryId = FOOTER_MAP[normalizedType] || FOOTER_MAP.default;
console.log(`${process.env.NEXT_PUBLIC_STRAPI_API_URL}/layout-footers/${queryId}?pLevel&locale=${locale}`);

  try {
    const res = await fetch(
      `${process.env.NEXT_PUBLIC_STRAPI_API_URL}/layout-footers/${queryId}?pLevel&locale=${locale}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_STRAPI_TOKEN}`,
        },
        cache: "no-store",
      }
    );

    if (!res.ok) throw new Error(`HTTP error ${res.status}`);

    const json = await res.json();
    const footerData = json?.data || {};

console.log(`\n\n🌐 Fetching Footer (${normalizedType}):\n\n${JSON.stringify(footerData, null, 2)}`);

    switch (normalizedType) {
      case "affiliated":
        return <AffiliatedSchoolFooter data={footerData} />;
      default:
        return <DefaultFooter data={footerData} />;
    }
  } catch (err) {
console.error("❌ Error loading footer:", err);
    return (
      <footer className="w-full text-center py-6 border-t border-gray-200 text-sm text-gray-500 text-red-500">
        Error loading footer.
      </footer>
    );
  }
}


{
  return (
    <footer className="w-full text-center py-6 border-t border-gray-200 text-sm text-gray-500">
      <p>© {new Date().getFullYear()} Web Site. All rights reserved.</p>
    </footer>
  );
}
