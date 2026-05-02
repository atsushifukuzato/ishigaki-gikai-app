-- 石垣市議会版 みらい議会
-- 第3回定例会 本文整備第7弾議案をトップのジャンル別表示に追加するSQL
--
-- 対象:
-- 1. 議案第31号 沖縄県宿泊税の賦課徴収に関する事務を石垣市が処理することについて
-- 2. 議案第34号 石垣市職員の給与に関する条例の一部を改正する条例
-- 3. 議員提出議案第9号 議員の派遣について
--
-- タグ割り当て:
-- - 第31号 -> 文化・観光
-- - 第34号 -> 自治・まちづくり
-- - 議員提出議案第9号 -> 自治・まちづくり

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where name in (
  '議案第31号 沖縄県宿泊税の賦課徴収に関する事務を石垣市が処理することについて',
  '議案第34号 石垣市職員の給与に関する条例の一部を改正する条例',
  '議員提出議案第9号 議員の派遣について'
);

insert into public.bills_tags (
  bill_id,
  tag_id
)
select
  b.id,
  t.id
from (
  values
    ('議案第31号 沖縄県宿泊税の賦課徴収に関する事務を石垣市が処理することについて', '文化・観光'),
    ('議案第34号 石垣市職員の給与に関する条例の一部を改正する条例', '自治・まちづくり'),
    ('議員提出議案第9号 議員の派遣について', '自治・まちづくり')
) as v(bill_name, tag_label)
join public.bills b
  on b.name = v.bill_name
join public.tags t
  on t.label = v.tag_label
on conflict (bill_id, tag_id) do nothing;

commit;

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
  '議案第31号 沖縄県宿泊税の賦課徴収に関する事務を石垣市が処理することについて',
  '議案第34号 石垣市職員の給与に関する条例の一部を改正する条例',
  '議員提出議案第9号 議員の派遣について'
)
order by t.featured_priority nulls last, b.name, t.label;
