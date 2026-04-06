create schema if not exists extensions;

create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "pgcrypto" with schema extensions;

create type public.bill_publish_status as enum (
  'draft',
  'published',
  'coming_soon'
);

create type public.bill_status_enum as enum (
  'introduced',
  'in_originating_house',
  'in_receiving_house',
  'enacted',
  'rejected',
  'preparing'
);

create type public.difficulty_level_enum as enum (
  'normal',
  'hard'
);

create type public.document_type_enum as enum (
  'bill',
  'speech',
  'report',
  'consent',
  'approval'
);

create type public.house_enum as enum (
  'HR',
  'HC'
);

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.diet_sessions (
  id uuid default gen_random_uuid() not null,
  name text not null,
  start_date date not null,
  end_date date not null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  slug text,
  shugiin_url text,
  is_active boolean default false not null,
  constraint diet_sessions_pkey primary key (id),
  constraint diet_sessions_slug_key unique (slug),
  constraint end_date_after_start_date check (end_date >= start_date)
);

comment on column public.diet_sessions.slug is 'URL用のスラッグ（例: 219-rinji, 218-jokai）';
comment on column public.diet_sessions.shugiin_url is '衆議院の国会議案情報ページURL';
comment on column public.diet_sessions.is_active is 'Whether this session is the active one displayed on the top page. Only one session can be active at a time.';

create table if not exists public.bills (
  id uuid default extensions.uuid_generate_v4() not null,
  name text not null,
  originating_house public.house_enum not null,
  status public.bill_status_enum not null,
  status_note text,
  published_at timestamptz,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  thumbnail_url text,
  publish_status public.bill_publish_status default 'draft'::public.bill_publish_status not null,
  is_featured boolean default false not null,
  share_thumbnail_url text,
  shugiin_url text,
  diet_session_id uuid,
  status_order integer generated always as (
    case status
      when 'enacted'::public.bill_status_enum then 0
      when 'rejected'::public.bill_status_enum then 1
      when 'in_receiving_house'::public.bill_status_enum then 2
      when 'in_originating_house'::public.bill_status_enum then 3
      when 'introduced'::public.bill_status_enum then 4
      when 'preparing'::public.bill_status_enum then 5
      else null::integer
    end
  ) stored,
  publish_status_order integer generated always as (
    case publish_status
      when 'draft'::public.bill_publish_status then 0
      when 'coming_soon'::public.bill_publish_status then 1
      when 'published'::public.bill_publish_status then 2
      else null::integer
    end
  ) stored,
  document_type public.document_type_enum default 'bill'::public.document_type_enum not null,
  constraint bills_pkey primary key (id),
  constraint bills_diet_session_id_fkey
    foreign key (diet_session_id) references public.diet_sessions(id) on delete set null
);

comment on table public.bills is '議案の基本情報を格納するテーブル。コンテンツはbill_contentsテーブルで管理。';
comment on column public.bills.originating_house is '発議院（HR:衆議院, HC:参議院）';
comment on column public.bills.status is '議案のステータス';
comment on column public.bills.published_at is 'サービスでの議案公開日時';
comment on column public.bills.thumbnail_url is 'URL to the bill thumbnail image stored in Supabase Storage';
comment on column public.bills.publish_status is 'Publication status: draft (private) or published (public)';
comment on column public.bills.is_featured is 'Flag to indicate if this bill is featured on the homepage';
comment on column public.bills.share_thumbnail_url is 'URL to the share/Twitter OGP image stored in Supabase Storage';
comment on column public.bills.shugiin_url is 'URL to the House of Representatives (衆議院) page for this bill';
comment on column public.bills.diet_session_id is '紐付けられた国会会期ID';
comment on column public.bills.document_type is '議会コンテンツの種別（議案、演説、報告、同意、承認）';

create table if not exists public.bill_contents (
  id uuid default extensions.uuid_generate_v4() not null,
  bill_id uuid not null,
  difficulty_level public.difficulty_level_enum not null,
  title text not null,
  summary text not null,
  content text not null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  constraint bill_contents_pkey primary key (id),
  constraint bill_contents_bill_id_difficulty_level_key unique (bill_id, difficulty_level),
  constraint bill_contents_bill_id_fkey
    foreign key (bill_id) references public.bills(id) on delete cascade
);

comment on table public.bill_contents is '議案の難易度別コンテンツを管理するテーブル';
comment on column public.bill_contents.difficulty_level is '難易度レベル（normal:ふつう, hard:難しい）';
comment on column public.bill_contents.content is 'Markdown形式の議案内容';

create table if not exists public.tags (
  id uuid default gen_random_uuid() not null,
  label text not null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  featured_priority integer,
  description text,
  constraint tags_pkey primary key (id),
  constraint tags_label_key unique (label)
);

comment on table public.tags is 'Master table for tags';
comment on column public.tags.label is 'Tag label (display name)';
comment on column public.tags.featured_priority is 'Featured表示の優先度（数値が小さいほど優先度が高い）。NULLの場合は非表示';
comment on column public.tags.description is 'Tag description text';

create table if not exists public.bills_tags (
  bill_id uuid not null,
  tag_id uuid not null,
  created_at timestamptz default now() not null,
  constraint bills_tags_pkey primary key (bill_id, tag_id),
  constraint bills_tags_bill_id_fkey
    foreign key (bill_id) references public.bills(id) on delete cascade,
  constraint bills_tags_tag_id_fkey
    foreign key (tag_id) references public.tags(id) on delete cascade
);

comment on table public.bills_tags is 'Junction table for bills and tags relationship';
comment on column public.bills_tags.bill_id is 'Bill ID';
comment on column public.bills_tags.tag_id is 'Tag ID';

create index if not exists idx_bill_contents_bill_id
  on public.bill_contents using btree (bill_id);

create index if not exists idx_bill_contents_difficulty
  on public.bill_contents using btree (difficulty_level);

create index if not exists idx_bills_diet_session_id
  on public.bills using btree (diet_session_id);

create index if not exists idx_bills_is_featured
  on public.bills using btree (is_featured)
  where is_featured = true;

create index if not exists idx_bills_originating_house
  on public.bills using btree (originating_house);

create index if not exists idx_bills_publish_status
  on public.bills using btree (publish_status);

create index if not exists idx_bills_publish_status_order
  on public.bills using btree (publish_status_order);

create index if not exists idx_bills_published_at
  on public.bills using btree (published_at desc);

create index if not exists idx_bills_status
  on public.bills using btree (status);

create index if not exists idx_bills_status_order
  on public.bills using btree (status_order);

create index if not exists idx_diet_sessions_date_range
  on public.diet_sessions using btree (start_date, end_date);

create index if not exists idx_diet_sessions_slug
  on public.diet_sessions using btree (slug);

create index if not exists idx_tags_featured_priority
  on public.tags using btree (featured_priority)
  where featured_priority is not null;

drop trigger if exists set_updated_at on public.diet_sessions;
create trigger set_updated_at
before update on public.diet_sessions
for each row execute function public.update_updated_at_column();

drop trigger if exists update_bills_updated_at on public.bills;
create trigger update_bills_updated_at
before update on public.bills
for each row execute function public.update_updated_at_column();

drop trigger if exists update_bill_contents_updated_at on public.bill_contents;
create trigger update_bill_contents_updated_at
before update on public.bill_contents
for each row execute function public.update_updated_at_column();

drop trigger if exists update_tags_updated_at on public.tags;
create trigger update_tags_updated_at
before update on public.tags
for each row execute function public.update_updated_at_column();
