-- 石垣市議会版 みらい議会
-- Topics 機能 本番反映 SQL
--
-- 対象:
-- - topics テーブル
-- - topic_bills テーブル
-- - topics.current_status_* カラム
-- - topic_updates テーブル
-- - 初期トピック: ishigaki-old-city-hall
-- - topic_bills(topic_id, bill_id) の重複防止 index
--
-- 想定:
-- - 本番 Supabase SQL Editor で実行
-- - Archive 既存機能には触れない

begin;

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
  created_at timestamptz not null default now()
);

create index if not exists idx_topic_bills_topic_id on public.topic_bills(topic_id);
create index if not exists idx_topic_bills_bill_id on public.topic_bills(bill_id);
create unique index if not exists idx_topic_bills_topic_id_bill_id
  on public.topic_bills(topic_id, bill_id);

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

drop policy if exists "topic_bills_public_read_active_topic" on public.topic_bills;
create policy "topic_bills_public_read_active_topic"
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
  current_status_label = '方針整理を継続確認',
  current_status_note = '旧市役所跡地の活用方針は、複合施設案を含めて整理・検討が続いている段階です。関連議案や予算審議、市の説明内容を継続して追う必要があります。',
  current_status_updated_at = '2026-04-15T11:30:00+09:00'::timestamptz,
  updated_at = now()
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
    ),
    (
      'progress',
      '活用テーマとして継続的に確認する対象に位置づけ',
      '跡地活用は単発の議案では追い切れないため、議会動向と事業進捗をまとめて確認するテーマとして整理します。',
      E'## この段階で見ること\n\n- 市の活用方針がどう整理されているか\n- 関連予算や関連議案がどの時点で出てくるか\n- 事業の説明内容や計画の変化があるか',
      '継続確認',
      'Topics初期データ',
      '2026-04-15T11:10:00+09:00'::timestamptz
    ),
    (
      'council',
      '議会での論点は関連議案と説明内容を横断して確認',
      'このテーマでは、議案の可否だけでなく、委員会や本会議でどのような説明や論点整理が行われているかも重要になります。',
      E'## 見方\n\n- 提出された議案そのもの\n- 議案に付随する説明や質疑\n- 計画の前提条件や進め方の変化',
      '議会動向を確認中',
      'Topics初期データ',
      '2026-04-15T11:15:00+09:00'::timestamptz
    ),
    (
      'news',
      '市の方針や外部公表があれば同じタイムラインで確認',
      '議会外で公表された方針や進捗も、テーマ全体の理解に必要な情報として同じページに蓄積していきます。',
      E'## この更新の意味\n\n議案だけでは現在地が見えにくいテーマでは、行政発表や事業進捗も合わせて時系列で確認できるようにします。',
      '関連情報も確認対象',
      'Topics初期データ',
      '2026-04-15T11:20:00+09:00'::timestamptz
    ),
    (
      'decision',
      '現時点では方針整理を追う段階として表示',
      '現段階では最終的な決定事項を示すのではなく、何が検討中で、どの論点が残っているかを中立的に把握することを重視します。',
      E'## 現在地\n\n- 最終決定そのものを示す段階ではない\n- 方針整理や議会での議論の積み上がりを見る段階\n- 次の関連議案や市の公表内容が重要になる',
      '方針整理を継続確認',
      'Topics初期データ',
      '2026-04-15T11:30:00+09:00'::timestamptz
    )
) as updates(kind, title, summary, content, status_label, source_label, published_at)
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1
    from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = updates.title
  );

commit;

-- 実行後の確認用
select
  t.slug,
  t.title,
  t.status,
  t.current_status_label,
  count(distinct tb.bill_id) as related_bill_count,
  count(distinct tu.id) as update_count
from public.topics t
left join public.topic_bills tb
  on tb.topic_id = t.id
left join public.topic_updates tu
  on tu.topic_id = t.id
where t.slug = 'ishigaki-old-city-hall'
group by t.id, t.slug, t.title, t.status, t.current_status_label;
