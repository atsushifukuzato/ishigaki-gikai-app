"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import type { CreateTopicInput } from "../../shared/types";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { createTopicRecord } from "../repositories/topic-repository";

export async function createTopic(input: CreateTopicInput) {
  try {
    await requireAdmin();

    if (!input.title.trim()) {
      return { error: "タイトルを入力してください" };
    }
    if (!input.slug.trim()) {
      return { error: "slugを入力してください" };
    }
    if (!input.description.trim()) {
      return { error: "概要を入力してください" };
    }

    const result = await createTopicRecord({
      slug: input.slug.trim(),
      title: input.title.trim(),
      description: input.description.trim(),
      content: input.content.trim(),
      current_status_label: input.current_status_label?.trim() || null,
      current_status_note: input.current_status_note?.trim() || null,
      current_status_updated_at:
        input.current_status_label?.trim() || input.current_status_note?.trim()
          ? (input.current_status_updated_at ?? new Date().toISOString())
          : null,
      status: input.status,
    });

    if (result.error) {
      return { error: mapTopicDbError(result.error, "作成") };
    }

    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);

    return { data: result.data };
  } catch (error) {
    console.error("Create topic error:", error);
    return {
      error: getErrorMessage(error, "トピックの作成中にエラーが発生しました"),
    };
  }
}
