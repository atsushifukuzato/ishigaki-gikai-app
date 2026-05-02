"use client";

import type { DifficultyLevelEnum } from "@/features/bill-difficulty/shared/types";
import { ChatButton } from "./chat-button";

interface PageChatClientProps {
  currentDifficulty: DifficultyLevelEnum;
  items: Array<{
    name: string;
    summary?: string;
    tags?: string[];
    isFeatured?: boolean;
  }>;
}

export function PageChatClient({
  currentDifficulty,
  items,
}: PageChatClientProps) {
  return (
    <ChatButton
      difficultyLevel={currentDifficulty}
      pageContext={{
        type: "home",
        bills: items,
      }}
    />
  );
}
