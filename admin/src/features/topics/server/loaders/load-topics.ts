import "server-only";
import type { TopicWithBillCount } from "../../shared/types";
import { findAllTopicsWithBillCount } from "../repositories/topic-repository";

export async function loadTopics(): Promise<TopicWithBillCount[]> {
  const data = await findAllTopicsWithBillCount();

  return (
    data?.map((topic) => ({
      id: topic.id,
      slug: topic.slug,
      title: topic.title,
      description: topic.description,
      content: topic.content,
      current_status_label: topic.current_status_label,
      current_status_note: topic.current_status_note,
      current_status_updated_at: topic.current_status_updated_at,
      status: topic.status as TopicWithBillCount["status"],
      created_at: topic.created_at,
      updated_at: topic.updated_at,
      bill_count: topic.topic_bills_count?.[0]?.count ?? 0,
      related_bills:
        topic.topic_bill_relations?.flatMap((relation) =>
          relation.bills
            ? [
                {
                  id: relation.bills.id,
                  bill_id: relation.bill_id,
                  name: relation.bills.name,
                  status: relation.bills.status,
                  publish_status: relation.bills.publish_status,
                  diet_session_name: relation.bills.diet_sessions?.name ?? null,
                },
              ]
            : []
        ) ?? [],
      updates:
        topic.topic_updates?.map((update) => ({
          id: update.id,
          topic_id: update.topic_id,
          kind: update.kind as TopicWithBillCount["updates"][number]["kind"],
          title: update.title,
          summary: update.summary,
          content: update.content,
          source_label: update.source_label,
          source_url: update.source_url,
          status_label: update.status_label,
          published_at: update.published_at,
          created_at: update.created_at,
          updated_at: update.updated_at,
        })) ?? [],
    })) || []
  );
}
