create unique index if not exists idx_topic_bills_topic_id_bill_id
  on public.topic_bills(topic_id, bill_id);
