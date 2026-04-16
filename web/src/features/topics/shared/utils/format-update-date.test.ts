import { describe, expect, it } from "vitest";
import { formatUpdateDate } from "./format-update-date";

describe("formatUpdateDate", () => {
  it("ISO日時文字列を日本語日付に変換する", () => {
    const result = formatUpdateDate("2026-04-15T00:00:00.000Z");
    expect(result).toMatch(/^2026年\d{1,2}月\d{1,2}日$/);
  });

  it("無効な日付はそのまま返す", () => {
    expect(formatUpdateDate("invalid-date")).toBe("invalid-date");
  });

  it("空文字はそのまま返す", () => {
    expect(formatUpdateDate("not-a-date-string")).toBe("not-a-date-string");
  });

  it("年・月・日を含む形式で返す", () => {
    const result = formatUpdateDate("2026-01-05T00:00:00.000Z");
    expect(result).toContain("2026年");
    expect(result).toContain("月");
    expect(result).toContain("日");
  });
});
