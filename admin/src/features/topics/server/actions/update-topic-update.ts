"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import type { UpdateTopicUpdateInput } from "../../shared/types";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { updateTopicUpdateRecord } from "../repositories/topic-repository";

export async function updateTopicUpdate(input: UpdateTopicUpdateInput) {
  try {
    await requireAdmin();

    if (!input.title.trim()) {
      return { error: "更新タイトルを入力してください" };
    }
    if (!input.summary.trim()) {
      return { error: "更新要約を入力してください" };
    }

    const result = await updateTopicUpdateRecord({
      ...input,
      title: input.title.trim(),
      summary: input.summary.trim(),
      content: input.content.trim(),
      source_label: input.source_label?.trim() || null,
      source_url: input.source_url?.trim() || null,
      status_label: input.status_label?.trim() || null,
    });

    if (result.error) {
      return { error: mapTopicDbError(result.error, "更新", "更新") };
    }

    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);
    return { data: result.data };
  } catch (error) {
    console.error("Update topic update error:", error);
    return {
      error: getErrorMessage(error, "更新履歴の更新中にエラーが発生しました"),
    };
  }
}
