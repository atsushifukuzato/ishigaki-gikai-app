-- 石垣市議会版 みらい議会
-- 第3回定例会 本文整備第6弾議案をトップのジャンル別表示に追加するSQL
--
-- 対象:
-- 1. 議案第23号 石垣市重度心身障害者（児）医療費助成に関する条例の一部を改正する条例
-- 2. 議案第24号 石垣市介護保険条例の一部を改正する条例
-- 3. 議案第25号 石垣市手数料徴収条例の一部を改正する条例
-- 4. 議案第26号 石垣市こども医療費助成条例の一部を改正する条例
--
-- 方針:
-- - トップの「注目の議案」ではなく、ジャンル別表示に出す
-- - そのため is_featured は false にそろえる
-- - featured_priority 付きタグに紐づける
--
-- タグ割り当て:
-- - 第23号 -> 健康・医療・福祉
-- - 第24号 -> 健康・医療・福祉
-- - 第25号 -> 健康・医療・福祉
-- - 第26号 -> 子育て・教育

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where name in (
  '議案第23号 石垣市重度心身障害者（児）医療費助成に関する条例の一部を改正する条例',
  '議案第24号 石垣市介護保険条例の一部を改正する条例',
  '議案第25号 石垣市手数料徴収条例の一部を改正する条例',
  '議案第26号 石垣市こども医療費助成条例の一部を改正する条例'
);

insert into public.tags (
  label,
  featured_priority,
  description
)
values
  ('健康・医療・福祉', 3, '医療、介護、障害福祉、福祉制度に関する議案')
on conflict (label) do update
set
  featured_priority = excluded.featured_priority,
  description = excluded.description,
  updated_at = now();

insert into public.bills_tags (
  bill_id,
  tag_id
)
select
  b.id,
  t.id
from (
  values
    ('議案第23号 石垣市重度心身障害者（児）医療費助成に関する条例の一部を改正する条例', '健康・医療・福祉'),
    ('議案第24号 石垣市介護保険条例の一部を改正する条例', '健康・医療・福祉'),
    ('議案第25号 石垣市手数料徴収条例の一部を改正する条例', '健康・医療・福祉'),
    ('議案第26号 石垣市こども医療費助成条例の一部を改正する条例', '子育て・教育')
) as v(bill_name, tag_label)
join public.bills b
  on b.name = v.bill_name
join public.tags t
  on t.label = v.tag_label
on conflict (bill_id, tag_id) do nothing;

commit;

-- 実行後の確認用
select
  b.name,
  b.is_featured,
  t.label as tag_label,
  t.featured_priority
from public.bills b
left join public.bills_tags bt
  on bt.bill_id = b.id
left join public.tags t
  on t.id = bt.tag_id
where b.name in (
  '議案第23号 石垣市重度心身障害者（児）医療費助成に関する条例の一部を改正する条例',
  '議案第24号 石垣市介護保険条例の一部を改正する条例',
  '議案第25号 石垣市手数料徴収条例の一部を改正する条例',
  '議案第26号 石垣市こども医療費助成条例の一部を改正する条例'
)
order by t.featured_priority nulls last, b.name, t.label;
