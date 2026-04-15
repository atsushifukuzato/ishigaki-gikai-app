create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null,
  content text not null default '',
  status text not null default 'active' check (status in ('active', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.topic_bills (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  bill_id uuid not null references public.bills(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (topic_id, bill_id)
);

create index if not exists idx_topics_status_updated_at
  on public.topics(status, updated_at desc);

create index if not exists idx_topic_bills_topic_id
  on public.topic_bills(topic_id);

create index if not exists idx_topic_bills_bill_id
  on public.topic_bills(bill_id);

drop trigger if exists update_topics_updated_at on public.topics;
create trigger update_topics_updated_at
  before update on public.topics
  for each row execute function public.update_updated_at_column();

alter table public.topics enable row level security;
alter table public.topic_bills enable row level security;

drop policy if exists "topics_public_read_active" on public.topics;
create policy "topics_public_read_active"
  on public.topics
  for select
  to anon, authenticated
  using (status = 'active');

drop policy if exists "topic_bills_public_read_active_published" on public.topic_bills;
create policy "topic_bills_public_read_active_published"
  on public.topic_bills
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.topics
      where topics.id = topic_bills.topic_id
        and topics.status = 'active'
    )
    and exists (
      select 1
      from public.bills
      where bills.id = topic_bills.bill_id
        and bills.publish_status = 'published'
    )
  );

insert into public.topics (
  slug,
  title,
  description,
  content,
  status
)
values (
  'ishigaki-old-city-hall',
  '石垣市庁舎跡地活用',
  '旧市役所跡地の再開発計画。商業施設やホテル、水族館などを含む複合施設として整備が検討されています。',
  E'## 概要\n\n旧市役所跡地の再開発計画。商業施設やホテル、水族館などを含む複合施設として整備が検討されています。\n\n## このトピックで扱うこと\n\n議会で扱われた関連議案や、計画の整理された情報を中立的に確認するためのトピックです。',
  'active'
)
on conflict (slug) do update
set
  title = excluded.title,
  description = excluded.description,
  content = excluded.content,
  status = excluded.status,
  updated_at = now();
