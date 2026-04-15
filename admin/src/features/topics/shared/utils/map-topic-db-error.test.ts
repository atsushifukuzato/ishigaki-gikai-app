import { describe, expect, it } from "vitest";
import { mapTopicDbError } from "./map-topic-db-error";

describe("mapTopicDbError", () => {
  describe("code 23505 (unique constraint violation)", () => {
    it("slug 重複の場合は slug 専用メッセージを返す", () => {
      expect(
        mapTopicDbError(
          {
            code: "23505",
            message:
              'duplicate key value violates unique constraint "topics_slug_key"',
          },
          "作成"
        )
      ).toBe("このslugはすでに使われています");
    });

    it("slug 以外の重複の場合はターゲット付きメッセージを返す", () => {
      expect(
        mapTopicDbError({ code: "23505", message: "duplicate key" }, "作成")
      ).toBe("同じ内容のトピックがすでに存在します");
    });

    it("target が 関連議案 の場合はターゲット名を含むメッセージを返す", () => {
      expect(
        mapTopicDbError(
          { code: "23505", message: "duplicate key" },
          "作成",
          "関連議案"
        )
      ).toBe("同じ内容の関連議案がすでに存在します");
    });
  });

  describe("code PGRST116 (not found)", () => {
    it("対象が見つからない場合はアクション付きメッセージを返す", () => {
      expect(mapTopicDbError({ code: "PGRST116" }, "削除")).toBe(
        "対象のトピックが見つからないため削除できませんでした"
      );
    });

    it("action と target を組み合わせたメッセージを返す", () => {
      expect(mapTopicDbError({ code: "PGRST116" }, "更新", "更新")).toBe(
        "対象の更新が見つからないため更新できませんでした"
      );
    });
  });

  describe("その他のエラーコード", () => {
    it("未知のコードの場合はフォールバックメッセージを返す", () => {
      expect(
        mapTopicDbError({ code: "42P01", message: "some db error" }, "作成")
      ).toBe("トピックの作成に失敗しました");
    });

    it("code が null の場合もフォールバックを返す", () => {
      expect(mapTopicDbError({ code: null }, "削除")).toBe(
        "トピックの削除に失敗しました"
      );
    });

    it("target が 関連議案 の場合はターゲット名を含むフォールバックを返す", () => {
      expect(mapTopicDbError({ code: "OTHER" }, "作成", "関連議案")).toBe(
        "関連議案の作成に失敗しました"
      );
    });
  });
});
