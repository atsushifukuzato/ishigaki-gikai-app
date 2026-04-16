import "server-only";
import { formatUpdateDate } from "../../shared/utils/format-update-date";
import type { TopicUpdate } from "../../shared/types";

interface TopicTimelineProps {
  updates: TopicUpdate[];
}

function getKindLabel(kind: TopicUpdate["kind"]) {
  switch (kind) {
    case "progress":
      return "進捗";
    case "news":
      return "ニュース";
    default:
      return kind;
  }
}

export function TopicTimeline({ updates }: TopicTimelineProps) {
  const items = updates.filter(
    (u) => u.kind === "progress" || u.kind === "news"
  );

  if (items.length === 0) {
    return null;
  }

  return (
    <section className="space-y-5">
      <div className="space-y-1">
        <h2 className="text-[22px] font-bold text-slate-900">これまでの流れ</h2>
        <p className="text-sm text-slate-500">
          テーマに関する進捗やニュースを時系列で記録しています。
        </p>
      </div>

      <div className="divide-y divide-slate-200 rounded-2xl bg-white px-4">
        {items.map((item) => (
          <article key={item.id} className="py-5">
            <div className="space-y-2">
              <div className="flex flex-wrap items-center gap-2">
                <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-600">
                  {getKindLabel(item.kind)}
                </span>
                <span className="text-xs font-medium text-slate-400">
                  {formatUpdateDate(item.published_at)}
                </span>
              </div>

              <p className="text-sm font-bold text-slate-800">{item.title}</p>
              <p className="text-sm leading-6 text-slate-500">{item.summary}</p>

              {item.source_url ? (
                <a
                  href={item.source_url}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-block text-xs font-medium text-primary-accent underline underline-offset-4"
                >
                  {item.source_label || "関連リンク"}
                </a>
              ) : item.source_label ? (
                <p className="text-xs font-medium text-slate-400">
                  {item.source_label}
                </p>
              ) : null}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
