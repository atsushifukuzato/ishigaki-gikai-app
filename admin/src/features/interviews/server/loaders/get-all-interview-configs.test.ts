import { describe, expect, it } from "vitest";
import type { BillWithDietSession } from "@/features/bills/shared/types";
import type { InterviewConfigWithBill } from "@/features/interview-config/server/repositories/interview-config-repository";
import { filterBillsWithoutInterviewConfigs } from "./get-all-interview-configs";

function createBill(
  overrides: Partial<BillWithDietSession>
): BillWithDietSession {
  return {
    id: "bill-1",
    created_at: "2026-01-01T00:00:00.000Z",
    updated_at: "2026-01-01T00:00:00.000Z",
    name: "テスト議案",
    status: "introduced",
    published_at: null,
    publish_status: "published",
    status_order: 0,
    publish_status_order: 0,
    originating_house: "HR",
    is_featured: false,
    share_thumbnail_url: null,
    diet_session_id: null,
    document_type: "bill",
    status_note: null,
    thumbnail_url: null,
    shugiin_url: null,
    diet_sessions: null,
    ...overrides,
  };
}

function createConfig(
  overrides: Partial<InterviewConfigWithBill>
): InterviewConfigWithBill {
  return {
    id: "config-1",
    bill_id: "bill-1",
    name: "2026/04/14 作成",
    status: "closed",
    mode: "loop",
    themes: null,
    knowledge_source: null,
    created_at: "2026-01-01T00:00:00.000Z",
    updated_at: "2026-01-01T00:00:00.000Z",
    chat_model: null,
    estimated_duration: null,
    bill: { id: "bill-1", name: "テスト議案" },
    ...overrides,
  };
}

describe("filterBillsWithoutInterviewConfigs", () => {
  it("returns only bill documents without configs", () => {
    const bills = [
      createBill({ id: "bill-1", name: "設定済み議案" }),
      createBill({ id: "bill-2", name: "未設定議案" }),
      createBill({
        id: "report-1",
        name: "報告資料",
        document_type: "report",
      }),
    ];
    const configs = [createConfig({ bill_id: "bill-1", bill: bills[0] })];

    expect(filterBillsWithoutInterviewConfigs(bills, configs)).toEqual([
      bills[1],
    ]);
  });
});
