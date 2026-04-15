import { ArrowLeft } from "lucide-react";
import type { Metadata, Route } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Container } from "@/components/layouts/container";
import { getDifficultyLevel } from "@/features/bill-difficulty/server/loaders/get-difficulty-level";
import { CompactBillCard } from "@/features/bills/client/components/bill-list/compact-bill-card";
import { PageChatClient } from "@/features/chat/client/components/page-chat-client";
import { TopicContent } from "@/features/topics/server/components/topic-content";
import { TopicRelatedLinks } from "@/features/topics/server/components/topic-related-links";
import { TopicStatusCard } from "@/features/topics/server/components/topic-status-card";
import { TopicUpdatesList } from "@/features/topics/server/components/topic-updates-list";
import { getTopicBySlug } from "@/features/topics/server/loaders/get-topic-by-slug";
import { routes } from "@/lib/routes";

interface TopicDetailPageProps {
  params: Promise<{
    slug: string;
  }>;
}

export async function generateMetadata({
  params,
}: TopicDetailPageProps): Promise<Metadata> {
  const { slug } = await params;
  const topic = await getTopicBySlug(slug);

  if (!topic) {
    return {
      title: "Topic が見つかりません",
    };
  }

  return {
    title: `${topic.title} | Topics | みらい議会 石垣市議会版`,
    description: topic.description,
  };
}

export default async function TopicDetailPage({
  params,
}: TopicDetailPageProps) {
  const { slug } = await params;
  const [topic, currentDifficulty] = await Promise.all([
    getTopicBySlug(slug),
    getDifficultyLevel(),
  ]);

  if (!topic) {
    notFound();
  }

  const statusUpdatedAtLabel = topic.current_status_updated_at
    ? new Date(topic.current_status_updated_at).toLocaleDateString("ja-JP")
    : null;

  return (
    <div className="container mx-auto max-w-4xl pb-32 md:pb-8">
      <div className="mb-8 bg-white rounded-b-4xl">
        <Container>
          <div className="space-y-4 px-4 pb-8 pt-4">
            <Link
              href={routes.topics() as Route}
              className="inline-flex items-center gap-2 text-sm font-medium text-slate-600 transition-opacity hover:opacity-70"
            >
              <ArrowLeft className="h-4 w-4" />
              Topics 一覧に戻る
            </Link>

            <div className="space-y-4">
              <span className="inline-flex rounded-full bg-stance-for-badge-end px-3 py-1 text-xs font-bold tracking-[0.08em] text-primary-accent">
                TOPIC
              </span>
              <div className="space-y-3">
                <h1 className="text-2xl font-bold text-slate-900">
                  {topic.title}
                </h1>
                <p className="leading-relaxed text-slate-700">
                  {topic.description}
                </p>
              </div>
            </div>
          </div>
        </Container>
      </div>

      <Container>
        <div className="flex flex-col gap-8">
          <TopicStatusCard
            label={topic.current_status_label}
            note={topic.current_status_note}
            updatedAt={topic.current_status_updated_at}
          />

          <section className="grid gap-4 md:grid-cols-3">
            <div className="rounded-2xl bg-white p-5">
              <p className="text-xs font-bold tracking-[0.08em] text-slate-400">
                UPDATES
              </p>
              <p className="mt-2 text-3xl font-extrabold text-slate-900">
                {topic.updates.length}
              </p>
              <p className="mt-1 text-sm text-slate-500">これまでの更新件数</p>
            </div>
            <div className="rounded-2xl bg-white p-5">
              <p className="text-xs font-bold tracking-[0.08em] text-slate-400">
                RELATED BILLS
              </p>
              <p className="mt-2 text-3xl font-extrabold text-slate-900">
                {topic.relatedBills.length}
              </p>
              <p className="mt-1 text-sm text-slate-500">公開済みの関連議案</p>
            </div>
            <div className="rounded-2xl bg-white p-5">
              <p className="text-xs font-bold tracking-[0.08em] text-slate-400">
                STATUS
              </p>
              <p className="mt-2 text-lg font-bold text-slate-900">
                {topic.current_status_label ?? "未設定"}
              </p>
              <p className="mt-1 text-sm text-slate-500">
                {statusUpdatedAtLabel
                  ? `${statusUpdatedAtLabel} 時点の現在地`
                  : "現在地を整理中"}
              </p>
            </div>
          </section>

          <TopicUpdatesList updates={topic.updates} />

          <TopicRelatedLinks updates={topic.updates} />

          {topic.content ? (
            <section className="space-y-4">
              <h2 className="text-[22px] font-bold text-slate-900">
                テーマの整理
              </h2>
              <div>
                <TopicContent content={topic.content} />
              </div>
            </section>
          ) : null}

          <section className="space-y-4">
            <div className="space-y-4">
              <div className="flex items-end justify-between gap-4">
                <div className="space-y-1">
                  <h2 className="text-[22px] font-bold text-slate-900">
                    関連議案一覧
                  </h2>
                  <p className="text-sm text-slate-500">
                    {topic.relatedBills.length}件の公開済み議案
                  </p>
                </div>
              </div>

              <p className="text-sm leading-7 text-slate-500">
                議案そのものの内容に加えて、提出状況や会期もあわせて確認すると、
                このテーマが議会の中でどう進んでいるか追いやすくなります。
              </p>

              {topic.relatedBills.length > 0 ? (
                <div className="space-y-4">
                  {topic.relatedBills.map((bill) => (
                    <Link
                      key={bill.id}
                      href={routes.billDetail(bill.id) as Route}
                    >
                      <CompactBillCard bill={bill} />
                    </Link>
                  ))}
                </div>
              ) : (
                <div className="rounded-2xl border border-dashed border-slate-300 px-5 py-8 text-center text-slate-500">
                  現在、このトピックに紐づく公開済み議案はありません。
                </div>
              )}
            </div>
          </section>
        </div>
      </Container>

      <PageChatClient
        currentDifficulty={currentDifficulty}
        items={[
          {
            name: topic.title,
            summary: [
              topic.description,
              topic.current_status_label
                ? `現在の状況: ${topic.current_status_label}`
                : "",
              topic.current_status_note ?? "",
            ]
              .filter(Boolean)
              .join("\n"),
            tags: ["Topics"],
          },
          ...topic.relatedBills.map((bill) => ({
            name: bill.name,
            summary: bill.bill_content?.summary,
            tags: ["関連議案"],
          })),
        ]}
      />
    </div>
  );
}
