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
import { attachTopicBillRecord } from "../repositories/topic-repository";

type AttachTopicBillActionInput = {
  topic_id: string;
  bill_id: string;
};

export async function attachTopicBill(input: AttachTopicBillActionInput) {
  try {
    await requireAdmin();

    const result = await attachTopicBillRecord(input);

    if (result.error) {
      return { error: mapTopicDbError(result.error, "作成", "関連議案") };
    }

    revalidatePath(routes.topics());
    await invalidateWebCache([WEB_CACHE_TAGS.TOPICS]);

    return { error: null };
  } catch (error) {
    console.error("Attach topic bill error:", error);
    return {
      error: getErrorMessage(error, "関連議案の追加中にエラーが発生しました"),
    };
  }
}
