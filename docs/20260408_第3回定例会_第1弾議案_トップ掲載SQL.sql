-- 石垣市議会版 みらい議会
-- 第3回定例会・本文整備第1弾の議案をトップページ「注目の議案」に掲載する本番反映 SQL
--
-- 対象:
-- 1. 議案第22号 石垣市自治基本条例の一部を改正する条例
-- 2. 議案第27号 石垣市下水道条例の一部を改正する条例
-- 3. 議案第28号 石垣市農業集落排水処理施設の管理に関する条例の改正
-- 4. 議案第32号 映画「尖閣1945」製作業務委託契約の変更について
--
-- 方針:
-- - 既存のトップページは bills.is_featured = true の議案を「注目の議案」として表示する
-- - 既存の注目議案は維持しつつ、第1弾で本文を整えた4議案を追加で掲載する

begin;

update public.bills
set
  is_featured = true,
  updated_at = now()
where id in (
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44'
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
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44'
)
order by published_at desc nulls last, name;
