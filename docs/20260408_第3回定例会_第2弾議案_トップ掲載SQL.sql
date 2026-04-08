-- 石垣市議会版 みらい議会
-- 第3回定例会・本文整備第2弾の議案をトップページ「注目の議案」に掲載する本番反映 SQL
--
-- 対象:
-- 1. 議案第20号 令和8年度石垣市水道事業会計予算
-- 2. 議員提出議案第7号 石垣市立八重山博物館（新館）の整備に関する決議
-- 3. 議員提出議案第12号 令和8年度からの石垣市における小中学校給食費の無償化を求める決議
--
-- 方針:
-- - 既存のトップページは bills.is_featured = true の議案を「注目の議案」として表示する
-- - 第2弾で本文を整えた3議案を追加で掲載する

begin;

update public.bills
set
  is_featured = true,
  updated_at = now()
where id in (
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b'
);

commit;

-- 実行後の確認用
select
  id,
  name,
  is_featured,
  published_at
from public.bills
where id in (
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b'
)
order by published_at desc nulls last, name;
