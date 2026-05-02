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
      <Card className="h-full rounded-[28px] border border-slate-200 bg-white/95 p-6 shadow-sm transition-transform transition-shadow group-hover:-translate-y-0.5 group-hover:shadow-md">
        <div className="flex h-full flex-col gap-4">
          <div className="flex items-center justify-between gap-3">
            <span className="inline-flex rounded-full bg-[#eef6e2] px-3 py-1 text-xs font-bold tracking-[0.08em] text-primary-accent">
              TOPIC
            </span>
            <span className="text-sm font-semibold text-slate-500">
              関連議案 {topic.relatedBillCount}件
            </span>
          </div>

          <div className="space-y-3">
            <h3 className="text-xl font-extrabold leading-8 tracking-[0.02em] text-slate-900">
              {topic.title}
            </h3>
            {topic.current_status_label ? (
              <p className="text-sm font-bold text-primary-accent">
                現在: {topic.current_status_label}
              </p>
            ) : null}
            <p className="line-clamp-3 text-[15px] leading-7 text-slate-600">
              {topic.description}
            </p>
          </div>
        </div>
      </Card>
    </Link>
  );
}
