const TAG_ICON_MAP: Record<string, string> = {
  "子育て・教育": "📚",
  "防災・安全": "🛡️",
  "文化・観光": "🌺",
  "健康・医療・福祉": "🩺",
  "暮らし・福祉": "🏠",
  "自治・まちづくり": "🏘️",
  "予算・財政": "💰",
  "安全保障・水産": "🐟",
  "平和・外交": "🕊️",
  海上安全: "🚢",
  "上下水道・インフラ": "🚰",
};

export function getTagIcon(label: string): string | null {
  return TAG_ICON_MAP[label] ?? null;
}
