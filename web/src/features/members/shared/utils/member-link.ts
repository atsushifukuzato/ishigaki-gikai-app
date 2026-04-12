import type { Member, MemberLink } from "../types";

export const MEMBER_LINK_ICON_MAP = {
  website: {
    name: "公式サイト",
    iconPath: "/icons/sns/icon_web.svg",
    hasBorder: true,
  },
  x: {
    name: "X",
    iconPath: "/icons/sns/icon_x.png",
    hasBorder: false,
  },
  twitter: {
    name: "X",
    iconPath: "/icons/sns/icon_x.png",
    hasBorder: false,
  },
  facebook: {
    name: "Facebook",
    iconPath: "/icons/sns/icon_facebook.png",
    hasBorder: false,
  },
  instagram: {
    name: "Instagram",
    iconPath: "/icons/sns/icon_instagram.png",
    hasBorder: true,
  },
  threads: {
    name: "Threads",
    iconPath: "/icons/sns/icon_threads.png",
    hasBorder: true,
  },
  youtube: {
    name: "YouTube",
    iconPath: "/icons/sns/icon_youtube.png",
    hasBorder: true,
  },
  line: {
    name: "LINE",
    iconPath: "/icons/sns/icon_line.png",
    hasBorder: true,
  },
  blog: {
    name: "ブログ",
    iconPath: "/icons/sns/icon_web.svg",
    hasBorder: true,
  },
} as const;

const LINK_SERVICE_ORDER = [
  "website",
  "blog",
  "x",
  "twitter",
  "facebook",
  "instagram",
  "threads",
  "youtube",
  "line",
] as const;

function trimUrl(url: string | null | undefined): string | null {
  if (typeof url !== "string") {
    return null;
  }

  const value = url.trim();
  return value.length > 0 ? value : null;
}

function getLegacyLinks(member: Member): MemberLink[] {
  const entries = [
    { service: "website", url: trimUrl(member.website_url) },
    { service: "x", url: trimUrl(member.twitter_url) },
    { service: "facebook", url: trimUrl(member.facebook_url) },
    { service: "instagram", url: trimUrl(member.instagram_url) },
    { service: "threads", url: trimUrl(member.threads_url) },
    { service: "youtube", url: trimUrl(member.youtube_url) },
    { service: "line", url: trimUrl(member.line_url) },
  ];

  return entries.flatMap((entry, index) =>
    entry.url
      ? [
          {
            id: `legacy-${member.id}-${entry.service}`,
            member_id: member.id,
            service: entry.service,
            label: null,
            url: entry.url,
            sort_order: index,
          },
        ]
      : []
  );
}

function getLinkOrder(service: string) {
  const index = LINK_SERVICE_ORDER.indexOf(
    service as (typeof LINK_SERVICE_ORDER)[number]
  );

  return index === -1 ? LINK_SERVICE_ORDER.length : index;
}

export function getMemberLinks(member: Member): MemberLink[] {
  const merged = [...getLegacyLinks(member), ...(member.links ?? [])];
  const seen = new Set<string>();

  return merged
    .filter((link) => trimUrl(link.url))
    .sort((a, b) => {
      const serviceOrderDiff =
        getLinkOrder(a.service) - getLinkOrder(b.service);

      if (serviceOrderDiff !== 0) {
        return serviceOrderDiff;
      }

      const sortOrderDiff = (a.sort_order ?? 0) - (b.sort_order ?? 0);

      if (sortOrderDiff !== 0) {
        return sortOrderDiff;
      }

      return a.url.localeCompare(b.url, "ja");
    })
    .filter((link) => {
      const key = `${link.service}::${link.url.trim()}`;

      if (seen.has(key)) {
        return false;
      }

      seen.add(key);
      return true;
    });
}

export function getMemberLinkPresentation(service: string) {
  return (
    MEMBER_LINK_ICON_MAP[service as keyof typeof MEMBER_LINK_ICON_MAP] ??
    MEMBER_LINK_ICON_MAP.website
  );
}
