export type StrapiMetaResponse = {
  meta: {
    pagination?: {
      page: number;
      pageSize: number;
      pageCount: number;
      total: number;
    };
  };
};

export interface MetadataResponse {
  id: number;
  Title: string;
  Description: string;
  Keywords: string;
  Slug: string;
  CanonicalURL: string;
  RobotsDirective: string;
  OpenGraphType: string;
  TwitterCardType: string;
  Locale: string;
  ContentType: string;
  PublishedTime: string;
  ModifiedTime: string;
  Author: string;
  AlternateLocales: Record<string, string>;
  MetaRobots: string;
  SocialMediaTags: Record<
    string,
    {
      name: string;
      content: string;
    }
  >;
  Thumbnail?: StrapiMedia;
  OpenGraphImage?: StrapiMedia;
}

export interface MediaFormat {
  name: string;
  hash: string;
  ext: string;
  mime: string;
  path: string | null;
  width: number;
  height: number;
  size: number;
  url: string;
  alternativeText: string | null;
}

export interface StrapiMedia {
  id: number;
  documentId: string;
  name: string;
  alternativeText: string | null;
  caption: string | null;
  width: number;
  height: number;
  formats: {
    thumbnail: MediaFormat;
    small?: MediaFormat;
    medium?: MediaFormat;
    large?: MediaFormat;
  };
  hash: string;
  ext: string;
  mime: string;
  size: number;
  url: string;
  previewUrl: string | null;
  provider: string;
  provider_metadata: null;
  createdAt: string;
  updatedAt: string;
  publishedAt: string;
}
