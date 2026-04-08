import "server-only";

import { openai } from "@ai-sdk/openai";
import type { LanguageModel } from "ai";

const FALLBACK_MODEL_ID = "gpt-4o-mini";

function normalizeOpenAiModelId(modelId: string): string {
  if (modelId.startsWith("openai/")) {
    return modelId.slice("openai/".length);
  }

  if (!modelId.includes("/")) {
    return modelId;
  }

  console.warn(
    `[AI] Unsupported provider model "${modelId}" on web. Falling back to ${FALLBACK_MODEL_ID}.`
  );

  return FALLBACK_MODEL_ID;
}

export function resolveWebAiModel(
  model: LanguageModel | string
): LanguageModel {
  if (typeof model !== "string") {
    return model;
  }

  return openai(normalizeOpenAiModelId(model));
}
