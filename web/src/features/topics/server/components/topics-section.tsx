import type { Route } from "next";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { routes } from "@/lib/routes";
import type { TopicListItem } from "../../shared/types";
import { TopicCard } from "./topic-card";

interface TopicsSectionProps {
  topics: TopicListItem[];
}

export function TopicsSection({ topics }: TopicsSectionProps) {
  return (
    <section className="flex flex-col gap-6">
      <div className="flex flex-col gap-1">
        <p className="text-sm font-bold tracking-[0.08em] text-primary-accent">
          TOPICS
        </p>
        <div className="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
          <div className="space-y-2">
            <h2 className="text-[30px] font-extrabold tracking-[0.02em] text-slate-900">
              テーマごとに話題の情報を見る
            </h2>
            <p className="max-w-2xl text-[15px] leading-7 text-slate-600">
              政策テーマごとに関連する議案や背景情報を整理して確認できます。
            </p>
          </div>
          <Button
            asChild
            variant="outline"
            className="h-11 rounded-full border-slate-300 bg-white px-5 text-sm font-bold"
          >
            <Link href={routes.topics() as Route}>Topics 一覧へ</Link>
          </Button>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        {topics.map((topic) => (
          <TopicCard key={topic.id} topic={topic} />
        ))}
      </div>
    </section>
  );
}
