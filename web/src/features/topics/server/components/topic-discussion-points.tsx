import "server-only";
import { formatUpdateDate } from "../../shared/utils/format-update-date";
import type { TopicUpdate } from "../../shared/types";
import { TopicUpdateMarkdown } from "./topic-update-markdown";

interface TopicDiscussionPointsProps {
  updates: TopicUpdate[];
}

// NOTE: kind='question'（一般質問）を追加する場合は、
// この配列に "question" を加えるだけで表示対象になります。
// 同時に getKindLabel() に "question" のケースを追加してください。
const DISCUSSION_KINDS: TopicUpdate["kind"][] = ["council"];

function getKindLabel(kind: TopicUpdate["kind"]) {
  switch (kind) {
    case "council":
      return "議会";
    default:
      return kind;
  }
}

export function TopicDiscussionPoints({ updates }: TopicDiscussionPointsProps) {
  const points = updates.filter((u) =>
    (DISCUSSION_KINDS as string[]).includes(u.kind)
  );

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
        {points.map((point) => (
          <article key={point.id} className="py-6">
            <div className="space-y-3">
              <div className="flex flex-wrap items-center gap-2">
                <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-600">
                  {getKindLabel(point.kind)}
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
                <p className="text-sm font-medium text-slate-500">
                  {point.source_label}
                </p>
              ) : null}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
