"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import type { CreateTopicUpdateInput } from "../../shared/types";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { createTopicUpdateRecord } from "../repositories/topic-repository";

export async function createTopicUpdate(input: CreateTopicUpdateInput) {
  try {
    await requireAdmin();

    if (!input.title.trim()) {
      return { error: "更新タイトルを入力してください" };
    }
    if (!input.summary.trim()) {
      return { error: "更新要約を入力してください" };
    }

    const result = await createTopicUpdateRecord({
      topic_id: input.topic_id,
      kind: input.kind,
      title: input.title.trim(),
      summary: input.summary.trim(),
      content: input.content.trim(),
      source_label: input.source_label?.trim() || null,
      source_url: input.source_url?.trim() || null,
      status_label: input.status_label?.trim() || null,
      published_at: input.published_at,
    });

    if (result.error) {
      return { error: mapTopicDbError(result.error, "作成", "更新") };
    }

    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);
    return { data: result.data };
  } catch (error) {
    console.error("Create topic update error:", error);
    return {
      error: getErrorMessage(error, "更新履歴の作成中にエラーが発生しました"),
    };
  }
}
