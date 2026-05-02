-- Topics table
create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  title_kana text,
  status text not null default 'draft'
    check (status in ('draft', 'review', 'published', 'archived')),
  category text,
  summary_normal text not null,
  summary_hard text not null,
  source_policy text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Topic <> Bills join table
create table if not exists public.topic_bills (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  bill_id uuid not null references public.bills(id) on delete cascade,
  related_level text not null
    check (related_level in ('high', 'medium', 'low')),
  adoption_status text not null default 'adopt'
    check (adoption_status in ('adopt', 'hold', 'skip')),
  reason_normal text not null,
  reason_hard text not null,
  source_url text not null,
  source_type text,
  is_primary boolean not null default false,
  display_order integer not null default 100,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (topic_id, bill_id)
);

create index if not exists idx_topics_slug on public.topics (slug);
create index if not exists idx_topics_status on public.topics (status);
create index if not exists idx_topic_bills_topic_id on public.topic_bills (topic_id);
create index if not exists idx_topic_bills_bill_id on public.topic_bills (bill_id);
create index if not exists idx_topic_bills_related_level on public.topic_bills (related_level);
create index if not exists idx_topic_bills_adoption_status on public.topic_bills (adoption_status);
create index if not exists idx_topic_bills_primary_order on public.topic_bills (topic_id, is_primary desc, display_order asc);

-- Optional updated_at trigger function (reuse existing one if your project already has it)
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_topics_updated_at on public.topics;
create trigger set_topics_updated_at
before update on public.topics
for each row execute function public.set_updated_at();

drop trigger if exists set_topic_bills_updated_at on public.topic_bills;
create trigger set_topic_bills_updated_at
before update on public.topic_bills
for each row execute function public.set_updated_at();
