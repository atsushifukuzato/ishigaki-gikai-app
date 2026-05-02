"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import type { DeleteTopicUpdateInput } from "../../shared/types";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { deleteTopicUpdateRecord } from "../repositories/topic-repository";

export async function deleteTopicUpdate(input: DeleteTopicUpdateInput) {
  try {
    await requireAdmin();

    const result = await deleteTopicUpdateRecord(input.id);

    if (result.error) {
      return { error: mapTopicDbError(result.error, "削除", "更新") };
    }

    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);
    return { success: true };
  } catch (error) {
    console.error("Delete topic update error:", error);
    return {
      error: getErrorMessage(error, "更新履歴の削除中にエラーが発生しました"),
    };
  }
}
