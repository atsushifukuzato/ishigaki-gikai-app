import "server-only";

import { createClient } from "@supabase/supabase-js";
import { env } from "@/lib/env";
import type { Member } from "../../shared/types";

type MembersDatabase = {
  public: {
    Tables: {
      members: {
        Row: Member;
      };
    };
  };
};

type MemberRow = {
  name: string;
  name_kana: string | null;
  party: string | null;
  party_group: string | null;
  election_count: number | null;
  birth_date: string | null;
  address: string | null;
  image_url: string | null;
  instagram_url?: string | null;
  threads_url?: string | null;
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
        "name, name_kana, party, party_group, election_count, birth_date, address, image_url, instagram_url, threads_url"
      )
      .order("name_kana", { ascending: true, nullsFirst: false })
      .order("name", { ascending: true });

  const fallbackQuery = () =>
    supabase
      .from("members")
      .select(
        "name, name_kana, party, party_group, election_count, birth_date, address, image_url"
      )
      .order("name_kana", { ascending: true, nullsFirst: false })
      .order("name", { ascending: true });

  let { data, error } = await queryWithSocialLinks();

  const isMissingSocialLinkColumn =
    error &&
    (error.message.includes("instagram_url") ||
      error.message.includes("threads_url") ||
      error.message.includes("column members.instagram_url does not exist") ||
      error.message.includes("column members.threads_url does not exist"));

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

  return ((data ?? []) as MemberRow[]).map((member) => ({
    name: member.name,
    name_kana: member.name_kana,
    party: member.party,
    party_group: member.party_group,
    election_count: member.election_count,
    birth_date: member.birth_date,
    address: member.address,
    image_url: member.image_url,
    instagram_url:
      typeof member.instagram_url === "string" ? member.instagram_url : null,
    threads_url:
      typeof member.threads_url === "string" ? member.threads_url : null,
  }));
}
