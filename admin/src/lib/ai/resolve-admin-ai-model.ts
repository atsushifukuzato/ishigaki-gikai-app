import "server-only";

import { createOpenAI } from "@ai-sdk/openai";
import type { LanguageModel } from "ai";

const FALLBACK_MODEL_ID = "gpt-4o-mini";
const DEFAULT_AI_GATEWAY_BASE_URL = "https://ai-gateway.vercel.sh/v1/ai";

function normalizeOpenAiModelId(modelId: string): string {
  if (modelId.startsWith("openai/")) {
    return modelId.slice("openai/".length);
  }

  if (!modelId.includes("/")) {
    return modelId;
  }

  console.warn(
    `[AI] Unsupported provider model "${modelId}" on admin. Falling back to ${FALLBACK_MODEL_ID}.`
  );

  return FALLBACK_MODEL_ID;
}

function getOpenAiProvider() {
  const openAiApiKey = process.env.OPENAI_API_KEY;
  if (openAiApiKey) {
    return createOpenAI({ apiKey: openAiApiKey });
  }

  const gatewayApiKey = process.env.AI_GATEWAY_API_KEY;
  if (gatewayApiKey) {
    return createOpenAI({
      apiKey: gatewayApiKey,
      baseURL: process.env.AI_GATEWAY_BASE_URL || DEFAULT_AI_GATEWAY_BASE_URL,
      name: "vercel-ai-gateway",
    });
  }

  throw new Error(
    "AI model could not be initialized. Set OPENAI_API_KEY or AI_GATEWAY_API_KEY."
  );
}

export function resolveAdminAiModel(
  model: LanguageModel | string
): LanguageModel {
  if (typeof model !== "string") {
    return model;
  }

  return getOpenAiProvider()(normalizeOpenAiModelId(model));
}
