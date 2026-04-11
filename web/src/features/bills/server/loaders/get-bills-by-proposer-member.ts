import { unstable_cache } from "next/cache";
import { CACHE_TAGS } from "@/lib/cache-tags";
import type { BillWithContent } from "../../shared/types";
import { getBills } from "./get-bills";

export async function getBillsByProposerMember(
  memberId: string
): Promise<BillWithContent[]> {
  return _getCachedBillsByProposerMember(memberId);
}

const _getCachedBillsByProposerMember = unstable_cache(
  async (memberId: string): Promise<BillWithContent[]> => {
    try {
      const bills = await getBills();

      return bills
        .filter(
          (bill) =>
            (bill as { proposer_member_id?: string | null })
              .proposer_member_id === memberId
        )
        .slice(0, 6);
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
