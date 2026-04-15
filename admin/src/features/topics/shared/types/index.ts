import type {
  BillPublishStatus,
  BillStatus,
} from "@/features/bills/shared/types";

export type TopicStatus = "active" | "archived";
export type TopicUpdateKind = "news" | "council" | "progress" | "decision";

export type Topic = {
  id: string;
  slug: string;
  title: string;
  description: string;
  content: string;
  current_status_label: string | null;
  current_status_note: string | null;
  current_status_updated_at: string | null;
  status: TopicStatus;
  created_at: string;
  updated_at: string;
};

export type TopicUpdate = {
  id: string;
  topic_id: string;
  kind: TopicUpdateKind;
  title: string;
  summary: string;
  content: string;
  source_label: string | null;
  source_url: string | null;
  status_label: string | null;
  published_at: string;
  created_at: string;
  updated_at: string;
};

export type TopicRelatedBill = {
  id: string;
  bill_id: string;
  name: string;
  status: BillStatus;
  publish_status: BillPublishStatus;
  diet_session_name: string | null;
};

export type TopicBillOption = {
  id: string;
  name: string;
  status: BillStatus;
  publish_status: BillPublishStatus;
  diet_session_name: string | null;
};

export type TopicWithBillCount = Topic & {
  bill_count: number;
  updates: TopicUpdate[];
  related_bills: TopicRelatedBill[];
};

export type CreateTopicInput = {
  slug: string;
  title: string;
  description: string;
  content: string;
  current_status_label: string | null;
  current_status_note: string | null;
  current_status_updated_at: string | null;
  status: TopicStatus;
};

export type UpdateTopicInput = CreateTopicInput & {
  id: string;
};

export type DeleteTopicInput = {
  id: string;
};

export type CreateTopicUpdateInput = {
  topic_id: string;
  kind: TopicUpdateKind;
  title: string;
  summary: string;
  content: string;
  source_label: string | null;
  source_url: string | null;
  status_label: string | null;
  published_at: string;
};

export type UpdateTopicUpdateInput = CreateTopicUpdateInput & {
  id: string;
};

export type DeleteTopicUpdateInput = {
  id: string;
};

export type AttachTopicBillInput = {
  topic_id: string;
  bill_id: string;
};

export type DetachTopicBillInput = {
  topic_id: string;
  bill_id: string;
};
