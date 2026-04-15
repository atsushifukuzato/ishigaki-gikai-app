import { unstable_cache } from "next/cache";
import { getDifficultyLevel } from "@/features/bill-difficulty/server/loaders/get-difficulty-level";
import type { DifficultyLevelEnum } from "@/features/bill-difficulty/shared/types";
import { getAllPreviousDietSessions } from "@/features/diet-sessions/server/loaders/get-previous-diet-session";
import type { DietSession } from "@/features/diet-sessions/shared/types";
import { CACHE_TAGS } from "@/lib/cache-tags";
import type { BillWithContent } from "../../shared/types";
import {
  findPreviousSessionBills,
  findTagsByBillIds,
  findBillIdsWithPublicInterview,
  countPublishedBillsByDietSession,
  normalizeDietSession,
} from "../repositories/bill-repository";

const MAX_PREVIEW_BILLS = 5;

export type PreviousSessionBillsResult = {
  session: DietSession;
  bills: BillWithContent[];
  totalBillCount: number;
};

/**
 * アクティブな会期より古い全会期とその議案を取得（各会期プレビュー最大5件）
 * 過去会期がない場合は空配列を返す
 */
export async function getPreviousSessionBills(): Promise<
  PreviousSessionBillsResult[]
> {
  const previousSessions = await getAllPreviousDietSessions();
  if (previousSessions.length === 0) {
    return [];
  }

  const difficultyLevel = await getDifficultyLevel();

  const results = await Promise.all(
    previousSessions.map(async (session) => {
      const [bills, totalBillCount] = await Promise.all([
        _getCachedPreviousSessionBills(session.id, difficultyLevel),
        _getCachedPreviousSessionBillCount(session.id, difficultyLevel),
      ]);
      return { session, bills, totalBillCount };
    })
  );

  // 議案が0件の会期は表示しない
  return results.filter((r) => r.totalBillCount > 0);
}

const _getCachedPreviousSessionBills = unstable_cache(
  async (
    dietSessionId: string,
    difficultyLevel: DifficultyLevelEnum
  ): Promise<BillWithContent[]> => {
    const data = await findPreviousSessionBills(
      dietSessionId,
      difficultyLevel,
      MAX_PREVIEW_BILLS
    );

    if (data.length === 0) {
      return [];
    }

    // タグ情報とインタビュー状態を取得
    const billIds = data.map((item) => item.id);
    const [tagsByBillId, interviewBillIds] = await Promise.all([
      findTagsByBillIds(billIds),
      findBillIdsWithPublicInterview(billIds),
    ]);

    const billsWithContent: BillWithContent[] = data.map((item) => {
      const { bill_contents, ...bill } = item;
      return {
        ...bill,
        bill_content: Array.isArray(bill_contents)
          ? bill_contents[0]
          : undefined,
        tags: tagsByBillId.get(item.id) ?? [],
        diet_session: normalizeDietSession(item.diet_session),
        hasPublicInterview: interviewBillIds.has(item.id),
      };
    });

    return billsWithContent;
  },
  ["previous-session-bills"],
  {
    revalidate: 600, // 10分
    tags: [CACHE_TAGS.BILLS, CACHE_TAGS.INTERVIEW_CONFIGS],
  }
);

const _getCachedPreviousSessionBillCount = unstable_cache(
  async (
    dietSessionId: string,
    difficultyLevel: DifficultyLevelEnum
  ): Promise<number> => {
    return countPublishedBillsByDietSession(dietSessionId, difficultyLevel);
  },
  ["previous-session-bill-count"],
  {
    revalidate: 600,
    tags: [CACHE_TAGS.BILLS],
  }
);
