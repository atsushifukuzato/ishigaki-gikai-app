-- Phase 3: topic_updates.kind に question を追加し、
-- 一般質問を「議員による問い」として独立したレイヤーで表現できるようにする

-- -------------------------------------------------------------------------
-- 1. CHECK制約の更新（question を追加）
-- -------------------------------------------------------------------------
alter table public.topic_updates
  drop constraint if exists topic_updates_kind_check;

alter table public.topic_updates
  add constraint topic_updates_kind_check
  check (kind in ('news', 'council', 'progress', 'decision', 'question'));

-- -------------------------------------------------------------------------
-- 2. 旧庁舎跡地活用トピックの「Topics初期データ」による council / decision を削除
--    内容が実態を反映していないため、以下でより正確なデータに置き換える
-- -------------------------------------------------------------------------
delete from public.topic_updates tu
using public.topics t
where tu.topic_id = t.id
  and t.slug = 'ishigaki-old-city-hall'
  and tu.source_label = 'Topics初期データ'
  and tu.kind in ('council', 'decision');

-- -------------------------------------------------------------------------
-- 3. council: 議会で確認された事実（1件）
--    「議会でこういうことが起きている」という確認された事実として記録する
-- -------------------------------------------------------------------------
insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  content,
  source_label,
  published_at
)
select
  t.id,
  'council',
  '複数の定例会で市から進捗状況の説明が行われている',
  '令和5年度以降、各定例会において担当部局から旧市役所跡地活用の進捗が報告されており、議会として継続的に確認が行われています。',
  E'## 議会として確認されている事実\n\n- 市は旧市役所跡地の活用を引き続き推進する方針を維持\n- 優先交渉権者（YAEYAMA GATE）との協議・交渉が継続中であることが報告されている\n- 具体的な着工スケジュールは現時点で議会に示されていない',
  '令和5〜8年 各定例会',
  '2026-04-01T00:00:00+09:00'::timestamptz
from public.topics t
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1 from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = '複数の定例会で市から進捗状況の説明が行われている'
  );

-- -------------------------------------------------------------------------
-- 4. decision: YAEYAMA GATE の優先交渉権者選定・公表（1件）
--    確定した公式事実として記録する
-- -------------------------------------------------------------------------
insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  source_label,
  published_at
)
select
  t.id,
  'decision',
  'YAEYAMA GATE が旧市役所跡地活用の優先交渉権者として選定・公表された',
  '石垣市は旧市役所跡地の複合施設整備事業において、YAEYAMA GATE（企業グループ）を優先交渉権者として選定し、公表しました。',
  '石垣市公表',
  '2024-01-01T00:00:00+09:00'::timestamptz
from public.topics t
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1 from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = 'YAEYAMA GATE が旧市役所跡地活用の優先交渉権者として選定・公表された'
  );

-- -------------------------------------------------------------------------
-- 5. question: 一般質問による主な論点（5件）
--    「議員がこう問うている」という問いの記録として扱う。確定事実ではない。
-- -------------------------------------------------------------------------
insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  content,
  source_label,
  published_at
)
select
  t.id,
  q.kind,
  q.title,
  q.summary,
  q.content,
  q.source_label,
  q.published_at
from public.topics t
cross join (
  values
    (
      'question'::text,
      '基本協定の締結時期はいつになるのか',
      '友寄永三議員が一般質問で問いを提起。優先交渉権者が選定されたにもかかわらず、基本協定の締結時期が示されていないことへの問いです。',
      E'## 問いの趣旨\n\n- 優先交渉権者の選定後、基本協定締結の具体的な見通しはいつか\n- 締結が遅れている場合、その理由は何か',
      '令和8年第1回定例会・友寄永三議員',
      '2026-03-14T13:00:00+09:00'::timestamptz
    ),
    (
      'question'::text,
      '特別目的会社（SPC）は組成されているのか',
      '大道夏代議員が一般質問で問いを提起。事業主体となるSPCの組成状況と構成について、市に説明を求めました。',
      E'## 問いの趣旨\n\n- SPCの設立・組成の事実確認\n- 出資構成や参加事業者の内訳',
      '令和8年第1回定例会・大道夏代議員',
      '2026-03-14T14:00:00+09:00'::timestamptz
    ),
    (
      'question'::text,
      '事業者の構成に変更はあるのか',
      '優先交渉権者の選定後、事業グループの構成に変更が生じていないかを確認する問いが出ています。',
      E'## 問いの趣旨\n\n- 公表時点と現在の事業者構成の同一性\n- 変更があった場合の市への報告・公表の有無',
      '令和8年第1回定例会',
      '2026-03-15T10:00:00+09:00'::timestamptz
    ),
    (
      'question'::text,
      '開発着工が遅れている理由は何か',
      '石垣達也議員が一般質問で問いを提起。旧市役所の解体完了後も複合施設の着工に向けた具体的な動きが見えないことへの問いです。',
      E'## 問いの趣旨\n\n- 解体完了後も着工が進まない具体的な理由\n- 今後の着工スケジュールの見通し\n- 市として事業者に何を確認・要請しているか',
      '令和7年12月定例会・石垣達也議員',
      '2025-12-12T10:00:00+09:00'::timestamptz
    ),
    (
      'question'::text,
      '計画の見直しが必要ではないか',
      '計画策定から時間が経過し、社会情勢や市の財政状況が変化する中、事業計画の見直しの必要性について議会から問いかけがあります。',
      E'## 問いの趣旨\n\n- 現在の計画の有効性の確認\n- 計画変更・見直しの検討状況\n- 市としての立場・方針',
      '令和7年12月定例会',
      '2025-12-13T10:00:00+09:00'::timestamptz
    )
) as q(kind, title, summary, content, source_label, published_at)
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1 from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = q.title
  );
