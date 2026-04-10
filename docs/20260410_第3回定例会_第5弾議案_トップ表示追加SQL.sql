-- 石垣市議会版 みらい議会
-- 第3回定例会 本文整備第5弾議案をトップのジャンル別表示に追加するSQL
--
-- 対象:
-- 1. 議案第29号 石垣市奨学基金条例の一部を改正する条例
-- 2. 議案第30号 石垣市火災予防条例の一部を改正する条例
-- 3. 議案第33号 沖縄県消防通信指令施設運営協議会規約の変更について
-- 4. 議案第35号 石垣市宿泊税条例の一部を改正する条例
--
-- 方針:
-- - トップの「注目の議案」ではなく、ジャンル別表示に出す
-- - そのため is_featured は false にそろえる
-- - featured_priority 付きタグに紐づける
--
-- タグ割り当て:
-- - 第29号 -> 子育て・教育
-- - 第30号 -> 防災・安全
-- - 第33号 -> 防災・安全
-- - 第35号 -> 文化・観光

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where name in (
  '議案第29号 石垣市奨学基金条例の一部を改正する条例',
  '議案第30号 石垣市火災予防条例の一部を改正する条例',
  '議案第33号 沖縄県消防通信指令施設運営協議会規約の変更について',
  '議案第35号 石垣市宿泊税条例の一部を改正する条例'
);

insert into public.tags (
  label,
  featured_priority,
  description
)
values
  ('防災・安全', 10, '防災、消防、安全対策、危機管理に関する議案')
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
    ('議案第29号 石垣市奨学基金条例の一部を改正する条例', '子育て・教育'),
    ('議案第30号 石垣市火災予防条例の一部を改正する条例', '防災・安全'),
    ('議案第33号 沖縄県消防通信指令施設運営協議会規約の変更について', '防災・安全'),
    ('議案第35号 石垣市宿泊税条例の一部を改正する条例', '文化・観光')
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
  '議案第29号 石垣市奨学基金条例の一部を改正する条例',
  '議案第30号 石垣市火災予防条例の一部を改正する条例',
  '議案第33号 沖縄県消防通信指令施設運営協議会規約の変更について',
  '議案第35号 石垣市宿泊税条例の一部を改正する条例'
)
order by t.featured_priority nulls last, b.name, t.label;
