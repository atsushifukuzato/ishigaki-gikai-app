import "server-only";
import { formatUpdateDate } from "../../shared/utils/format-update-date";
import type { TopicUpdate } from "../../shared/types";
import { TopicUpdateMarkdown } from "./topic-update-markdown";

interface TopicDecisionsProps {
  updates: TopicUpdate[];
}

export function TopicDecisions({ updates }: TopicDecisionsProps) {
  const decisions = updates.filter((u) => u.kind === "decision");

  if (decisions.length === 0) {
    return null;
  }

  return (
    <section className="space-y-5">
      <div className="space-y-1">
        <h2 className="text-[22px] font-bold text-slate-900">決定事項</h2>
        <p className="text-sm text-slate-500">
          議会で決議・議決された事実を記録しています。
        </p>
      </div>

      <div className="divide-y divide-slate-200 rounded-2xl bg-white px-4">
        {decisions.map((decision) => (
          <article key={decision.id} className="py-6">
            <div className="space-y-3">
              <div className="flex flex-wrap items-center gap-2">
                <span className="rounded-full bg-slate-800 px-3 py-1 text-xs font-bold tracking-[0.06em] text-white">
                  決定
                </span>
                {decision.status_label ? (
                  <span className="rounded-full bg-stance-for-badge-end px-3 py-1 text-xs font-bold text-primary-accent">
                    {decision.status_label}
                  </span>
                ) : null}
                <span className="text-xs font-medium text-slate-400">
                  {formatUpdateDate(decision.published_at)}
                </span>
              </div>

              <div className="space-y-2">
                <h3 className="text-base font-bold text-slate-900">
                  {decision.title}
                </h3>
                <p className="text-[15px] leading-7 text-slate-600">
                  {decision.summary}
                </p>
                {decision.content ? (
                  <TopicUpdateMarkdown content={decision.content} />
                ) : null}
              </div>

              {decision.source_url ? (
                <div className="text-sm">
                  <a
                    href={decision.source_url}
                    target="_blank"
                    rel="noreferrer"
                    className="font-medium text-primary-accent underline underline-offset-4"
                  >
                    {decision.source_label || "関連リンク"}
                  </a>
                </div>
              ) : decision.source_label ? (
                <p className="text-sm font-medium text-slate-500">
                  {decision.source_label}
                </p>
              ) : null}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
