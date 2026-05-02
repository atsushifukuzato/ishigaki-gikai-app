import { getBills } from "@/features/bills/server/loaders/get-bills";
import { TopicForm } from "@/features/topics/client/components/topic-form";
import { TopicList } from "@/features/topics/server/components/topic-list";
import { loadTopics } from "@/features/topics/server/loaders/load-topics";

export default async function TopicsPage() {
  const [topics, bills] = await Promise.all([loadTopics(), getBills()]);
  const billOptions = bills.map((bill) => ({
    id: bill.id,
    name: bill.name,
    status: bill.status,
    publish_status: bill.publish_status,
    diet_session_name: bill.diet_sessions?.name ?? null,
  }));

  return (
    <div className="container mx-auto py-8">
      <h1 className="mb-8 text-2xl font-bold">Topics管理</h1>

      <section className="mb-8 rounded-lg border bg-white p-6">
        <h2 className="mb-4 text-lg font-semibold">トピックを追加</h2>
        <TopicForm />
      </section>

      <section className="rounded-lg border bg-white p-6">
        <TopicList topics={topics} billOptions={billOptions} />
      </section>
    </div>
  );
}
