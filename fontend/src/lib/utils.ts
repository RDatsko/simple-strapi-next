import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";
import { MetadataResponse, StrapiMedia } from "@/services/models";
import { Metadata } from "next";
// import { SEO_DEFAULTS } from "@/services/constants";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const standardizeUrl = (url: string) => {
  if (!url) return "/";
  return url
    .replace(/\/+/g, "/") // Replace multiple slashes with a single slash globally
    .replace(/\/+$/g, "") // Remove trailing slashes only
    .replace(/\s+/g, "-") // Replace spaces with dashes
    .toLowerCase();
};

export const getImageUrl = (
  media: StrapiMedia | { data: { attributes: { url: string } } },
  preferredSize?: "thumbnail" | "small" | "medium" | "large"
) => {
  if (!media) return "";

  if ("data" in media) {
    return (
      process.env.NEXT_PUBLIC_STRAPI_URL + (media.data.attributes.url || "")
    );
  }

  // If we have formats and a preferred size is specified, try to use that format
  if ("formats" in media && preferredSize && media.formats) {
    const format = media.formats[preferredSize];
    if (format?.url) {
      return process.env.NEXT_PUBLIC_STRAPI_URL + format.url;
    }
  }

  return process.env.NEXT_PUBLIC_STRAPI_URL + (media.url || "");
};

export const generateMetadata = (
  metadata?: MetadataResponse,
  fallbackTitle?: string,
  fallbackDescription?: string,
  pathname?: string,
  faviconPath?: string
): Metadata => {
  const title = metadata?.Title || fallbackTitle || SEO_DEFAULTS.DEFAULT_TITLE;
  const description =
    metadata?.Description ||
    fallbackDescription ||
    SEO_DEFAULTS.DEFAULT_DESCRIPTION;
  const keywords = metadata?.Keywords || SEO_DEFAULTS.DEFAULT_KEYWORDS;

  // Generate thumbnail images
  const thumbnails = metadata?.Thumbnail
    ? [
        {
          url: getImageUrl(metadata.Thumbnail),
          // Prefer larger format if available
          width:
            metadata.Thumbnail.formats?.large?.width ||
            metadata.Thumbnail.formats?.medium?.width ||
            metadata.Thumbnail.formats?.small?.width ||
            metadata.Thumbnail.formats?.thumbnail?.width ||
            metadata.Thumbnail.width ||
            1200,
          height:
            metadata.Thumbnail.formats?.large?.height ||
            metadata.Thumbnail.formats?.medium?.height ||
            metadata.Thumbnail.formats?.small?.height ||
            metadata.Thumbnail.formats?.thumbnail?.height ||
            metadata.Thumbnail.height ||
            630,
          alt: metadata.Thumbnail.alternativeText || title,
        },
      ]
    : [];

  // Default Open Graph image if no thumbnails provided
  const defaultImage = {
    url: `${process.env.NEXT_PUBLIC_STRAPI_URL}/uploads/ajis_og_image.jpg`,
    width: 1200,
    height: 630,
    alt: SEO_DEFAULTS.SITE_NAME,
  };

  const images = thumbnails.length > 0 ? thumbnails : [defaultImage];

  // Construct canonical URL
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL;
  const canonicalUrl =
    metadata?.CanonicalURL || (pathname ? `${baseUrl}${pathname}` : baseUrl);

  // Handle favicon and icons
  const favicon = faviconPath || "/favicon.png";
  const iconSizes = [16, 32, 48, 64, 96, 128, 192, 256, 512];

  // Convert social media tags to the correct format
  const socialTags: { [key: string]: string | number | (string | number)[] } = {
    "theme-color": SEO_DEFAULTS.THEME_COLOR,
    "msapplication-TileColor": SEO_DEFAULTS.THEME_COLOR,
    "msapplication-TileImage": favicon,
    "mobile-web-app-capable": "yes",
    "apple-mobile-web-app-status-bar-style": "default",
    "apple-mobile-web-app-title": SEO_DEFAULTS.SITE_NAME,
    "application-name": SEO_DEFAULTS.SITE_NAME,
  };

  if (metadata?.SocialMediaTags) {
    Object.entries(metadata.SocialMediaTags).forEach(([key, value]) => {
      socialTags[key] = value.content;
    });
  }

  return {
    title: {
      default: `${title} | ${SEO_DEFAULTS.SITE_NAME}`,
      template: `%s | ${SEO_DEFAULTS.SITE_NAME}`,
    },
    description,
    keywords: keywords?.split(",").map((k) => k.trim()) || [],

    // Open Graph
    openGraph: {
      title,
      description,
      url: canonicalUrl,
      siteName: SEO_DEFAULTS.SITE_NAME,
      images,
      locale: metadata?.Locale || "en_US",
      type: (metadata?.OpenGraphType || "website") as
        | "website"
        | "article"
        | "book"
        | "profile",
      ...(metadata?.PublishedTime && { publishedTime: metadata.PublishedTime }),
      ...(metadata?.ModifiedTime && { modifiedTime: metadata.ModifiedTime }),
      ...(metadata?.Author && { authors: [metadata.Author] }),
    },

    // Twitter Card
    twitter: {
      card: (metadata?.TwitterCardType || "summary_large_image") as
        | "summary"
        | "summary_large_image"
        | "app"
        | "player",
      title,
      description,
      images: images.map((img: { url: string }) => img.url),
      creator: SEO_DEFAULTS.TWITTER_HANDLE,
      site: SEO_DEFAULTS.TWITTER_HANDLE,
    },

    // Robots and indexing
    robots: {
      index: metadata?.RobotsDirective?.includes("index") ?? true,
      follow: metadata?.RobotsDirective?.includes("follow") ?? true,
      ...(metadata?.MetaRobots && { other: metadata.MetaRobots }),
      googleBot: {
        index: metadata?.RobotsDirective?.includes("index") ?? true,
        follow: metadata?.RobotsDirective?.includes("follow") ?? true,
        "max-video-preview": -1,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },

    // Canonical URL and alternates
    alternates: {
      canonical: canonicalUrl,
      ...(metadata?.AlternateLocales && {
        languages: metadata.AlternateLocales,
      }),
    },

    // Icons and favicon
    icons: {
      icon: [
        { url: favicon, sizes: "32x32", type: "image/png" },
        ...iconSizes.map((size) => ({
          url: favicon,
          sizes: `${size}x${size}`,
          type: "image/png",
        })),
      ],
      shortcut: favicon,
      apple: [
        { url: favicon, sizes: "180x180", type: "image/png" },
        { url: favicon, sizes: "152x152", type: "image/png" },
        { url: favicon, sizes: "144x144", type: "image/png" },
        { url: favicon, sizes: "120x120", type: "image/png" },
        { url: favicon, sizes: "114x114", type: "image/png" },
        { url: favicon, sizes: "76x76", type: "image/png" },
        { url: favicon, sizes: "72x72", type: "image/png" },
        { url: favicon, sizes: "60x60", type: "image/png" },
        { url: favicon, sizes: "57x57", type: "image/png" },
      ],
      other: [
        {
          rel: "mask-icon",
          url: favicon,
          color: SEO_DEFAULTS.THEME_COLOR,
        },
      ],
    },

    // Additional meta tags
    other: socialTags,

    // Content type and dates
    ...(metadata?.ContentType && { type: metadata.ContentType }),
    ...(metadata?.PublishedTime && { publishedTime: metadata.PublishedTime }),
    ...(metadata?.ModifiedTime && { modifiedTime: metadata.ModifiedTime }),
    ...(metadata?.Author && { authors: [{ name: metadata.Author }] }),
  };
};

// Helper function to generate metadata for any page with Strapi metadata
export const generatePageMetadata = async (
  pageDataFetcher: () => Promise<
    { data?: { Metadata?: MetadataResponse } } | undefined
  >,
  fallbackTitle?: string,
  fallbackDescription?: string,
  pathname?: string,
  faviconPath?: string
): Promise<Metadata> => {
  try {
    const pageData = await pageDataFetcher();
    return generateMetadata(
      pageData?.data?.Metadata,
      fallbackTitle,
      fallbackDescription,
      pathname,
      faviconPath
    );
  } catch (error) {
    console.error("Failed to generate page metadata:", error);
    return generateMetadata(
      undefined,
      fallbackTitle,
      fallbackDescription,
      pathname,
      faviconPath
    );
  }
};
