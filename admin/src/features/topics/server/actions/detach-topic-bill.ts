"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import { routes } from "@/lib/routes";
import {
  invalidateWebCache,
  WEB_CACHE_TAGS,
} from "@/lib/utils/cache-invalidation";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import { mapTopicDbError } from "../../shared/utils/map-topic-db-error";
import { detachTopicBillRecord } from "../repositories/topic-repository";

type DetachTopicBillActionInput = {
  topic_id: string;
  bill_id: string;
};

export async function detachTopicBill(input: DetachTopicBillActionInput) {
  try {
    await requireAdmin();

    const result = await detachTopicBillRecord(input);

    if (result.error) {
      return { error: mapTopicDbError(result.error, "削除", "関連議案") };
    }

    revalidatePath(routes.topics());
    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);

    return { error: null };
  } catch (error) {
    console.error("Detach topic bill error:", error);
    return {
      error: getErrorMessage(error, "関連議案の解除中にエラーが発生しました"),
    };
  }
}
