"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import type { DeleteTopicInput } from "../../shared/types";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { deleteTopicRecord } from "../repositories/topic-repository";

export async function deleteTopic(input: DeleteTopicInput) {
  try {
    await requireAdmin();

    const result = await deleteTopicRecord(input.id);

    if (result.error) {
      return { error: mapTopicDbError(result.error, "削除") };
    }

    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);

    return { success: true };
  } catch (error) {
    console.error("Delete topic error:", error);
    return {
      error: getErrorMessage(error, "トピックの削除中にエラーが発生しました"),
    };
  }
}
