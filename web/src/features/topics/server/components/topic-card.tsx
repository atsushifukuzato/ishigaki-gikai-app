import type { Route } from "next";
import Link from "next/link";
import { Card } from "@/components/ui/card";
import { routes } from "@/lib/routes";
import type { TopicListItem } from "../../shared/types";

interface TopicCardProps {
  topic: TopicListItem;
}

export function TopicCard({ topic }: TopicCardProps) {
  return (
    <Link
      href={routes.topicDetail(topic.slug) as Route}
      className="group block"
    >
      <Card className="rounded-2xl border-[0.5px] border-mirai-text-placeholder bg-white shadow-none transition-colors group-hover:bg-muted/50">
        <div className="flex items-center p-4 gap-4">
          <div className="flex-1 flex flex-col gap-2">
            <div className="flex items-center gap-2">
              <span className="inline-flex rounded-full bg-stance-for-badge-end px-3 py-1 text-xs font-bold tracking-[0.08em] text-primary-accent">
                TOPIC
              </span>
              {topic.current_status_label ? (
                <span className="text-xs font-bold text-primary-accent">
                  {topic.current_status_label}
                </span>
              ) : null}
            </div>
            <h3 className="text-2xl/8 font-semibold tracking-normal line-clamp-2 text-slate-900">
              {topic.title}
            </h3>
            <p className="line-clamp-2 text-xs leading-6 text-slate-500">
              {topic.description}
            </p>
          </div>
          <div className="shrink-0 text-right">
            <p className="text-xs text-slate-400">関連議案</p>
            <p className="text-lg font-extrabold text-slate-900">
              {topic.relatedBillCount}
              <span className="text-xs font-medium text-slate-400">件</span>
            </p>
          </div>
        </div>
      </Card>
    </Link>
  );
}
