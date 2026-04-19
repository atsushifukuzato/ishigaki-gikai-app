import { beforeEach, describe, expect, it, vi } from "vitest";
import { loadHomeData } from "./load-home-data";
import { getBillsByFeaturedTags } from "./get-bills-by-featured-tags";
import { getComingSoonBills } from "./get-coming-soon-bills";
import { getFeaturedBills } from "./get-featured-bills";
import { getPreviousSessionBills } from "./get-previous-session-bills";

vi.mock("./get-featured-bills", () => ({
  getFeaturedBills: vi.fn(),
}));

vi.mock("./get-bills-by-featured-tags", () => ({
  getBillsByFeaturedTags: vi.fn(),
}));

vi.mock("./get-coming-soon-bills", () => ({
  getComingSoonBills: vi.fn(),
}));

vi.mock("./get-previous-session-bills", () => ({
  getPreviousSessionBills: vi.fn(),
}));

describe("loadHomeData", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("TOPページで先に解決したコンテキストを各loaderへそのまま渡す", async () => {
    const options = {
      difficultyLevel: "hard" as const,
      activeDietSessionId: "session-1",
      previousSessions: [
        {
          id: "previous-session-1",
          name: "令和8年3月定例会",
          slug: "r8-03",
          shugiin_url: null,
          start_date: "2026-03-01",
          end_date: "2026-03-31",
          is_active: false,
          created_at: "2026-03-01T00:00:00.000Z",
          updated_at: "2026-03-31T00:00:00.000Z",
        },
      ],
    };
    const featuredBills = [{ id: "bill-1" }];
    const billsByTag = [{ tag: { id: "tag-1" }, bills: [] }];
    const comingSoonBills = [{ id: "coming-1" }];
    const previousSessionData = {
      session: options.previousSessions[0],
      bills: [],
      totalBillCount: 0,
    };

    vi.mocked(getFeaturedBills).mockResolvedValue(featuredBills as never);
    vi.mocked(getBillsByFeaturedTags).mockResolvedValue(billsByTag as never);
    vi.mocked(getComingSoonBills).mockResolvedValue(comingSoonBills as never);
    vi.mocked(getPreviousSessionBills).mockResolvedValue([previousSessionData] as never);

    const result = await loadHomeData(options);

    expect(getFeaturedBills).toHaveBeenCalledWith(options);
    expect(getBillsByFeaturedTags).toHaveBeenCalledWith(options);
    expect(getComingSoonBills).toHaveBeenCalledWith(options);
    expect(getPreviousSessionBills).toHaveBeenCalledWith(options);
    expect(result).toEqual({
      featuredBills,
      billsByTag,
      comingSoonBills,
      previousSessionData: [previousSessionData],
    });
  });
});
