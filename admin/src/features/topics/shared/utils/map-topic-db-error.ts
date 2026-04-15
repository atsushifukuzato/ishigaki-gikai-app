export function mapTopicDbError(
  error: { code?: string | null; message?: string | null },
  action: "作成" | "更新" | "削除",
  target: "トピック" | "更新" | "関連議案" = "トピック"
) {
  if (error.code === "23505") {
    if (error.message?.includes("slug")) {
      return "このslugはすでに使われています";
    }
    return `同じ内容の${target}がすでに存在します`;
  }

  if (error.code === "PGRST116") {
    return `対象の${target}が見つからないため${action}できませんでした`;
  }

  return `${target}の${action}に失敗しました`;
}
