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

  const { data, error } = await supabase
    .from("members")
    .select(
      "name, name_kana, party, party_group, election_count, birth_date, address, image_url"
    )
    .order("name_kana", { ascending: true, nullsFirst: false })
    .order("name", { ascending: true });

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

  return data ?? [];
}
