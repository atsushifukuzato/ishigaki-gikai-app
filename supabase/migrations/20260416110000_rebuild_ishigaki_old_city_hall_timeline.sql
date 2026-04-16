-- 旧庁舎跡地活用 Topic の「これまでの流れ」を実際の出来事ベースに再構築する
--
-- 削除対象: progress/news の「Topics初期データ」由来の説明文（3件）
-- 追加対象: 議案データ・一般質問データから導いた具体的なイベント（7件）

-- -------------------------------------------------------------------------
-- 1. 既存の抽象的な説明文を削除（progress/news のみ、council/decision は別マイグで整理済み）
-- -------------------------------------------------------------------------
delete from public.topic_updates tu
using public.topics t
where tu.topic_id = t.id
  and t.slug = 'ishigaki-old-city-hall'
  and tu.source_label = 'Topics初期データ'
  and tu.kind in ('progress', 'news');

-- -------------------------------------------------------------------------
-- 2. 実際の出来事ベースのタイムラインを投入（published_at の古い順に記載）
-- -------------------------------------------------------------------------
insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  source_label,
  source_url,
  published_at
)
select
  t.id,
  ev.kind,
  ev.title,
  ev.summary,
  ev.source_label,
  ev.source_url,
  ev.published_at
from public.topics t
cross join (
  values

    -- 2024-01: 優先交渉権者の公表（最初の大きな節目）
    (
      'news'::text,
      '旧市役所跡地活用の優先交渉権者としてYAEYAMA GATEが公表された',
      '石垣市は公募型プロポーザルにより選定した事業者グループ「YAEYAMA GATE」を、旧市役所跡地複合施設整備事業の優先交渉権者として公表しました。',
      '石垣市公表',
      null,
      '2024-01-01T00:00:00+09:00'::timestamptz
    ),

    -- 2024-03-04: 補正予算可決（SPC設立遅延・繰越の初出）
    (
      'progress'::text,
      '令和5年度補正予算で跡地利活用事業費が計上・可決された（一部繰越）',
      '令和5年度一般会計補正予算（第9号）に「旧市役所庁舎等跡地利活用事業」として約1,017万円が計上され可決。SPCの設立に時間を要したため、一部経費は翌年度へ繰り越されました。',
      '令和6年第3回定例会（2024年3月4日可決）',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html',
      '2024-03-04T00:00:00+09:00'::timestamptz
    ),

    -- 2024-03-18: 令和6年度予算可決（調査委託として継続）
    (
      'progress'::text,
      '令和6年度一般会計予算が可決され、跡地利活用事業費が継続計上された',
      '令和6年度一般会計予算に「旧市役所庁舎等跡地利活用事業」として約1,284万円（主に調査委託料）が計上され可決。前年度から継続して予算が確保されました。',
      '令和6年第3回定例会（2024年3月18日可決）',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html',
      '2024-03-18T00:00:00+09:00'::timestamptz
    ),

    -- 2025-03-17: 令和7年度予算可決（継続）
    (
      'progress'::text,
      '令和7年度一般会計予算が可決され、跡地利活用事業費が3年連続で計上された',
      '令和7年度一般会計予算に「旧市役所庁舎等跡地利活用事業」として約1,144万円（調査委託）が計上され可決。令和5・6年度に続き3年連続の計上となりました。',
      '令和7年第2回定例会（2025年3月17日可決）',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa7nen2025nen/10775.html',
      '2025-03-17T00:00:00+09:00'::timestamptz
    ),

    -- 2025-12: 着工遅延・計画見直しについて一般質問が行われた
    (
      'news'::text,
      '令和7年12月定例会で着工遅延と計画見直しについて一般質問が行われた',
      '解体完了後も着工に向けた動きが見えないことへの問いや、計画見直しの必要性について、議員から一般質問が提起されました。詳細は「議会での主な論点」セクションを参照してください。',
      '令和7年12月定例会',
      null,
      '2025-12-12T00:00:00+09:00'::timestamptz
    ),

    -- 2026-03-09: 令和7年度補正予算・繰越明許費
    (
      'progress'::text,
      '令和7年度補正予算で跡地利活用事業費が繰越明許費として計上・可決された',
      '令和7年度一般会計補正予算（第12号）に「旧市役所庁舎等跡地利活用事業」として約1,045万円が繰越明許費として計上され可決。事業が年度内に完了せず、令和8年度への引き継ぎが確認されました。',
      '令和8年第3回定例会（2026年3月9日可決）',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa8nen2026nen/11780.html',
      '2026-03-09T00:00:00+09:00'::timestamptz
    ),

    -- 2026-03: 基本協定・SPC・着工について一般質問が集中した
    (
      'news'::text,
      '令和8年第1回定例会で基本協定・SPC・事業者構成・着工時期について一般質問が集中した',
      '令和8年3月の定例会において、基本協定の締結時期、SPCの組成状況、事業者構成の変更の有無、着工が始まらない理由など、複数の議員から一般質問が相次ぎました。詳細は「議会での主な論点」セクションを参照してください。',
      '令和8年第1回定例会',
      null,
      '2026-03-14T00:00:00+09:00'::timestamptz
    )

) as ev(kind, title, summary, source_label, source_url, published_at)
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1 from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = ev.title
  );
