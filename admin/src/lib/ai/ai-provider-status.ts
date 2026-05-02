import "server-only";

export function hasAiProviderCredentials(): boolean {
  return Boolean(process.env.OPENAI_API_KEY || process.env.AI_GATEWAY_API_KEY);
}
