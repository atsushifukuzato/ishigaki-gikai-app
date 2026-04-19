import type { DifficultyLevelEnum } from "@/features/bill-difficulty/shared/types";
import type { DietSession } from "@/features/diet-sessions/shared/types";
import { getBillsByFeaturedTags } from "@/features/bills/server/loaders/get-bills-by-featured-tags";
import { getComingSoonBills } from "./get-coming-soon-bills";
import { getFeaturedBills } from "./get-featured-bills";
import { getPreviousSessionBills } from "./get-previous-session-bills";

type LoadHomeDataOptions = {
  difficultyLevel?: DifficultyLevelEnum;
  activeDietSessionId?: string | null;
  previousSessions?: DietSession[];
};

/**
 * トップページ用のデータを並列取得する
 * BFF (Backend For Frontend) パターン
 */
export async function loadHomeData(options: LoadHomeDataOptions = {}) {
  const [featuredBills, billsByTag, comingSoonBills, previousSessionData] =
    await Promise.all([
      getFeaturedBills(options),
      getBillsByFeaturedTags(options),
      getComingSoonBills(options),
      getPreviousSessionBills(options),
    ]);

  return {
    billsByTag,
    featuredBills,
    comingSoonBills,
    previousSessionData,
  };
}
