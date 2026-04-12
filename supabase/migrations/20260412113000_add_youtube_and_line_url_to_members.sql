do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'members'
  ) then
    alter table public.members
      add column if not exists youtube_url text,
      add column if not exists line_url text;

    comment on column public.members.youtube_url is '議員のYouTubeチャンネルURL';
    comment on column public.members.line_url is '議員のLINE公式アカウントURL';
  end if;
end $$;

create table if not exists public.member_links (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  service text not null,
  label text,
  url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (member_id, service, url)
);

create index if not exists idx_member_links_member_id_sort_order
  on public.member_links(member_id, sort_order, created_at);

comment on table public.member_links is '議員ごとの外部リンク一覧';
comment on column public.member_links.service is 'x, facebook, instagram, threads, youtube, line, website などの種別';
comment on column public.member_links.label is '任意の表示ラベル。個人・会派・後援会などの補足に使う';
comment on column public.member_links.sort_order is '同一議員内での表示順';

alter table public.member_links enable row level security;

drop policy if exists "member_links_public_read" on public.member_links;

create policy "member_links_public_read"
on public.member_links
for select
to anon, authenticated
using (true);
