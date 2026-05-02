alter table public.topics
  add column if not exists current_status_label text,
  add column if not exists current_status_note text,
  add column if not exists current_status_updated_at timestamptz;

create table if not exists public.topic_updates (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  kind text not null check (kind in ('news', 'council', 'progress', 'decision')),
  title text not null,
  summary text not null,
  content text not null default '',
  source_label text,
  source_url text,
  status_label text,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_topic_updates_topic_id_published_at
  on public.topic_updates(topic_id, published_at desc);

drop trigger if exists update_topic_updates_updated_at on public.topic_updates;
create trigger update_topic_updates_updated_at
  before update on public.topic_updates
  for each row execute function public.update_updated_at_column();

alter table public.topic_updates enable row level security;

drop policy if exists "topic_updates_public_read_active_topic" on public.topic_updates;
create policy "topic_updates_public_read_active_topic"
  on public.topic_updates
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.topics
      where topics.id = topic_updates.topic_id
        and topics.status = 'active'
    )
  );

update public.topics
set
  current_status_label = coalesce(current_status_label, '検討段階'),
  current_status_note = coalesce(
    current_status_note,
    '旧市役所跡地の活用方針について、複合施設を含む複数の可能性が検討されている段階です。'
  ),
  current_status_updated_at = coalesce(current_status_updated_at, now())
where slug = 'ishigaki-old-city-hall';

insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  content,
  status_label,
  source_label,
  published_at
)
select
  t.id,
  updates.kind,
  updates.title,
  updates.summary,
  updates.content,
  updates.status_label,
  updates.source_label,
  updates.published_at
from public.topics t
cross join (
  values
    (
      'progress',
      '複合施設としての活用案が論点になっている',
      '商業施設やホテル、水族館を含む活用案が検討対象として整理されています。',
      E'## 現状\n\n旧市役所跡地の活用について、複合施設としての整備可能性が検討されています。\n\n## この更新でわかること\n\n- 活用案はまだ検討段階にあること\n- 商業施設、ホテル、水族館など複数の機能が論点になっていること\n- 今後は議会や市の判断を追う必要があること',
      '検討段階',
      'Topics初期データ',
      '2026-04-15T09:00:00+09:00'::timestamptz
    ),
    (
      'council',
      '関連議案や予算の審議状況を追うためのトピック',
      'このテーマに関連する議案や議会での進み方を時系列で把握できるようにするための整理ページです。',
      E'## 見るポイント\n\n- 関連議案がいつ提出されたか\n- 審議や決定がどの段階にあるか\n- 市の方針や事業の進捗がどう変わるか',
      '議会動向を継続確認',
      'Topics初期データ',
      '2026-04-15T09:05:00+09:00'::timestamptz
    )
) as updates(kind, title, summary, content, status_label, source_label, published_at)
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1
    from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = updates.title
  );
