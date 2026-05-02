"use server";

import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import { routes } from "@/lib/routes";
import { getErrorMessage } from "@/lib/utils/get-error-message";
import { AI_MODELS } from "@/lib/ai/models";
import { findInterviewConfigsByBillId } from "@/features/interview-config/server/repositories/interview-config-repository";
import { createInterviewConfig } from "@/features/interview-config/server/actions/upsert-interview-config";
import { generateDefaultConfigName } from "@/features/interview-config/shared/utils/default-config-name";

export type CreateDraftInterviewConfigResult =
  | { success: true; data: { id: string; editPath: string } }
  | { success: false; error: string };

export async function createDraftInterviewConfig(
  billId: string
): Promise<CreateDraftInterviewConfigResult> {
  try {
    await requireAdmin();

    const existingConfigs = await findInterviewConfigsByBillId(billId);
    if (existingConfigs.length > 0) {
      const latestConfig = existingConfigs[0];

      return {
        success: false,
        error: `既にインタビュー設定があります: ${routes.billInterviewEdit(
          billId,
          latestConfig.id
        )}`,
      };
    }

    const result = await createInterviewConfig(billId, {
      name: generateDefaultConfigName(),
      status: "closed",
      mode: "loop",
      themes: [],
      knowledge_source: "",
      chat_model: AI_MODELS.gpt4o_mini,
      estimated_duration: 10,
    });

    if (!result.success) {
      return result;
    }

    return {
      success: true,
      data: {
        id: result.data.id,
        editPath: routes.billInterviewEdit(billId, result.data.id),
      },
    };
  } catch (error) {
    console.error("Create draft interview config error:", error);
    return {
      success: false,
      error: getErrorMessage(
        error,
        "下書きインタビュー設定の作成中にエラーが発生しました"
      ),
    };
  }
}
