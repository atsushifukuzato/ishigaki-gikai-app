import { unstable_cache } from "next/cache";
import { getDifficultyLevel } from "@/features/bill-difficulty/server/loaders/get-difficulty-level";
import type { DifficultyLevelEnum } from "@/features/bill-difficulty/shared/types";
import { CACHE_TAGS } from "@/lib/cache-tags";
import type { BillWithContent } from "../../shared/types";
import {
  findPublishedBillsByProposerMember,
  normalizeDietSession,
} from "../repositories/bill-repository";

export async function getBillsByProposerMember(
  memberId: string
): Promise<BillWithContent[]> {
  const difficultyLevel = await getDifficultyLevel();
  return _getCachedBillsByProposerMember(memberId, difficultyLevel);
}

const _getCachedBillsByProposerMember = unstable_cache(
  async (
    memberId: string,
    difficultyLevel: DifficultyLevelEnum
  ): Promise<BillWithContent[]> => {
    try {
      const data = await findPublishedBillsByProposerMember(
        memberId,
        difficultyLevel
      );

      if (data.length === 0) {
        return [];
      }

      return data.slice(0, 12).map((item) => {
        const { bill_contents, ...bill } = item;
        return {
          ...bill,
          bill_content: Array.isArray(bill_contents)
            ? bill_contents[0]
            : undefined,
          tags: [],
          diet_session: normalizeDietSession(item.diet_session),
          hasPublicInterview: false,
        };
      });
    } catch (error) {
      console.error(
        "[members] Failed to load proposer bills for member:",
        memberId,
        error
      );
      return [];
    }
  },
  ["bills-by-proposer-member"],
  {
    revalidate: 600,
    tags: [CACHE_TAGS.BILLS, CACHE_TAGS.INTERVIEW_CONFIGS],
  }
);
