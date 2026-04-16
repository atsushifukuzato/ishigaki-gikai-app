import "server-only";
import { formatUpdateDate } from "../../shared/utils/format-update-date";
import type { TopicUpdate } from "../../shared/types";
import { TopicUpdateMarkdown } from "./topic-update-markdown";

interface TopicDiscussionPointsProps {
  updates: TopicUpdate[];
}

// kind='question' は「議員による問い（一般質問）」として、
// kind='council' の「議会で確認された事実」と区別して表示します。
// 将来的に新しい kind を追加する場合はこの配列と getKindConfig() を更新してください。
const DISCUSSION_KINDS = ["council", "question"] as const;

type DiscussionKind = (typeof DISCUSSION_KINDS)[number];

function isDiscussionKind(kind: string): kind is DiscussionKind {
  return (DISCUSSION_KINDS as readonly string[]).includes(kind);
}

function getKindConfig(kind: DiscussionKind): {
  label: string;
  isQuestion: boolean;
} {
  switch (kind) {
    case "question":
      return { label: "一般質問", isQuestion: true };
    case "council":
      return { label: "議会", isQuestion: false };
  }
}

export function TopicDiscussionPoints({ updates }: TopicDiscussionPointsProps) {
  const points = updates.filter((u) => isDiscussionKind(u.kind));

  if (points.length === 0) {
    return null;
  }

  return (
    <section className="space-y-5">
      <div className="space-y-1">
        <h2 className="text-[22px] font-bold text-slate-900">
          議会での主な論点
        </h2>
        <p className="text-sm text-slate-500">
          議会でどのような観点からこのテーマが議論されているかを整理しています。
        </p>
      </div>

      <div className="divide-y divide-slate-200 rounded-2xl bg-white px-4">
        {points.map((point) => {
          const kindConfig = isDiscussionKind(point.kind)
            ? getKindConfig(point.kind)
            : { label: point.kind, isQuestion: false };

          return (
            <article key={point.id} className="py-6">
              <div className="space-y-3">
                <div className="flex flex-wrap items-center gap-2">
                  <span
                    className={
                      kindConfig.isQuestion
                        ? "rounded-full bg-mirai-surface-muted px-3 py-1 text-xs font-bold text-slate-500"
                        : "rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-600"
                    }
                  >
                    {kindConfig.label}
                  </span>
                  {point.status_label ? (
                    <span className="rounded-full bg-stance-for-badge-end px-3 py-1 text-xs font-bold text-primary-accent">
                      {point.status_label}
                    </span>
                  ) : null}
                  <span className="text-xs font-medium text-slate-400">
                    {formatUpdateDate(point.published_at)}
                  </span>
                </div>

                <div className="space-y-2">
                  <h3 className="text-base font-bold text-slate-900">
                    {point.title}
                  </h3>
                  <p className="text-[15px] leading-7 text-slate-600">
                    {point.summary}
                  </p>
                  {point.content ? (
                    <TopicUpdateMarkdown content={point.content} />
                  ) : null}
                </div>

                {/* 一般質問には「確定事実ではない」旨の軽い注記を表示 */}
                {kindConfig.isQuestion ? (
                  <p className="text-xs text-slate-400">
                    ※ 議員による問題提起であり、確定事項ではありません
                  </p>
                ) : null}

                {point.source_url ? (
                  <div className="text-sm">
                    <a
                      href={point.source_url}
                      target="_blank"
                      rel="noreferrer"
                      className="font-medium text-primary-accent underline underline-offset-4"
                    >
                      {point.source_label || "関連リンク"}
                    </a>
                  </div>
                ) : point.source_label ? (
                  <p className="text-xs font-medium text-slate-400">
                    {point.source_label}
                  </p>
                ) : null}
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}
