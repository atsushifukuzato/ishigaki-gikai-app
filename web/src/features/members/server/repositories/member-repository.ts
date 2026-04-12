import "server-only";

import { createClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";
import type { Member, MemberLink } from "../../shared/types";

type MembersDatabase = {
  public: {
    Tables: {
      members: {
        Row: Member;
      };
      member_links: {
        Row: MemberLink;
      };
    };
  };
};

type MemberRow = {
  id: string;
  name: string;
  name_kana: string | null;
  party: string | null;
  party_group: string | null;
  election_count: number | null;
  birth_date: string | null;
  address: string | null;
  image_url: string | null;
  website_url?: string | null;
  twitter_url?: string | null;
  facebook_url?: string | null;
  instagram_url?: string | null;
  threads_url?: string | null;
  youtube_url?: string | null;
  line_url?: string | null;
};

type MemberLinkRow = {
  id: string;
  member_id: string;
  service: string;
  label: string | null;
  url: string;
  sort_order: number;
};

function getSupabaseTargetLabel(url: string) {
  try {
    const hostname = new URL(url).hostname;

    if (
      hostname === "127.0.0.1" ||
      hostname === "localhost" ||
      hostname.endsWith(".local")
    ) {
      return "local";
    }

    return "cloud";
  } catch {
    return "unknown";
  }
}

export async function getMembers(): Promise<Member[]> {
  const targetInfo = {
    url: env.supabaseUrl,
    target: getSupabaseTargetLabel(env.supabaseUrl),
  };

  console.log("[members] Supabase target:", {
    ...targetInfo,
  });

  const supabase = createClient<MembersDatabase>(
    env.supabaseUrl,
    env.supabaseAnonKey
  );

  const queryWithSocialLinks = () =>
    supabase
      .from("members")
      .select(
        "id, name, name_kana, party, party_group, election_count, birth_date, address, image_url, website_url, twitter_url, facebook_url, instagram_url, threads_url, youtube_url, line_url"
      )
      .order("name_kana", { ascending: true, nullsFirst: false })
      .order("name", { ascending: true });

  const fallbackQuery = () =>
    supabase
      .from("members")
      .select(
        "id, name, name_kana, party, party_group, election_count, birth_date, address, image_url"
      )
      .order("name_kana", { ascending: true, nullsFirst: false })
      .order("name", { ascending: true });

  let { data, error } = await queryWithSocialLinks();

  const isMissingSocialLinkColumn =
    error &&
    (error.message.includes("website_url") ||
      error.message.includes("facebook_url") ||
      error.message.includes("twitter_url") ||
      error.message.includes("instagram_url") ||
      error.message.includes("threads_url") ||
      error.message.includes("youtube_url") ||
      error.message.includes("line_url") ||
      error.message.includes("column members.website_url does not exist") ||
      error.message.includes("column members.twitter_url does not exist") ||
      error.message.includes("column members.facebook_url does not exist") ||
      error.message.includes("column members.instagram_url does not exist") ||
      error.message.includes("column members.threads_url does not exist") ||
      error.message.includes("column members.youtube_url does not exist") ||
      error.message.includes("column members.line_url does not exist"));

  if (isMissingSocialLinkColumn) {
    ({ data, error } = await fallbackQuery());
  }

  if (error) {
    console.error("[members] Failed to fetch members:", {
      ...targetInfo,
      error: error.message,
    });

    const isMissingMembersTable =
      error.message.includes("Could not find the table 'public.members'") ||
      error.message.includes('relation "public.members" does not exist');

    if (isMissingMembersTable) {
      return [];
    }

    throw new Error(
      `Failed to fetch members: ${error.message} (target=${targetInfo.target}, url=${targetInfo.url})`
    );
  }

  const { data: memberLinksData, error: memberLinksError } = await supabase
    .from("member_links")
    .select("id, member_id, service, label, url, sort_order")
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: true });

  const isMissingMemberLinksTable =
    memberLinksError &&
    (memberLinksError.message.includes("public.member_links") ||
      memberLinksError.message.includes(
        'relation "public.member_links" does not exist'
      ) ||
      memberLinksError.message.includes(
        "Could not find the table 'public.member_links'"
      ));

  if (memberLinksError && !isMissingMemberLinksTable) {
    throw new Error(
      `Failed to fetch member links: ${memberLinksError.message}`
    );
  }

  const memberLinksByMemberId = new Map<string, MemberLink[]>();

  for (const link of (memberLinksData ?? []) as MemberLinkRow[]) {
    const normalizedLink: MemberLink = {
      id: link.id,
      member_id: link.member_id,
      service: link.service,
      label: link.label,
      url: link.url,
      sort_order: link.sort_order ?? 0,
    };

    const existingLinks = memberLinksByMemberId.get(link.member_id);

    if (existingLinks) {
      existingLinks.push(normalizedLink);
      continue;
    }

    memberLinksByMemberId.set(link.member_id, [normalizedLink]);
  }

  return ((data ?? []) as MemberRow[]).map((member) => ({
    id: member.id,
    name: member.name,
    name_kana: member.name_kana,
    party: member.party,
    party_group: member.party_group,
    election_count: member.election_count,
    birth_date: member.birth_date,
    address: member.address,
    image_url: member.image_url,
    website_url:
      typeof member.website_url === "string" ? member.website_url : null,
    twitter_url:
      typeof member.twitter_url === "string" ? member.twitter_url : null,
    facebook_url:
      typeof member.facebook_url === "string" ? member.facebook_url : null,
    instagram_url:
      typeof member.instagram_url === "string" ? member.instagram_url : null,
    threads_url:
      typeof member.threads_url === "string" ? member.threads_url : null,
    youtube_url:
      typeof member.youtube_url === "string" ? member.youtube_url : null,
    line_url: typeof member.line_url === "string" ? member.line_url : null,
    links: memberLinksByMemberId.get(member.id) ?? [],
  }));
}

export async function getMemberById(memberId: string): Promise<Member | null> {
  const members = await getMembers();
  return members.find((member) => member.id === memberId) ?? null;
}
