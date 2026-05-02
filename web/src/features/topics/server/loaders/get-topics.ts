import { unstable_cache } from "next/cache";
import { CACHE_TAGS } from "@/lib/cache-tags";
import type { TopicListItem } from "../../shared/types";
import { findActiveTopicsWithBillCounts } from "../repositories/topic-repository";

export async function getTopics(): Promise<TopicListItem[]> {
  return _getCachedTopics();
}

const _getCachedTopics = unstable_cache(
  async (): Promise<TopicListItem[]> => {
    try {
      return await findActiveTopicsWithBillCounts();
    } catch (error) {
      console.error("[topics] Failed to load topics:", error);
      return [];
    }
  },
  ["topics-list"],
  {
    revalidate: 600,
    tags: [CACHE_TAGS.TOPICS, CACHE_TAGS.BILLS],
  }
);
