-- 石垣市議会版 みらい議会
-- 第3回定例会 本文整備第8弾議案をトップのジャンル別表示に追加するSQL
--
-- タグ割り当て:
-- - 第14号 -> 予算・財政
-- - 第15号 -> 予算・財政
-- - 第16号 -> 予算・財政
-- - 第17号 -> 自治・まちづくり
-- - 第18号 -> 予算・財政
-- - 第19号 -> 上下水道・インフラ

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where name in (
  '議案第14号 令和8年度石垣市国民健康保険事業特別会計予算',
  '議案第15号 令和8年度石垣市後期高齢者医療特別会計予算',
  '議案第16号 令和8年度石垣市介護保険事業特別会計予算',
  '議案第17号 令和8年度石垣都市計画土地区画整理事業特別会計予算',
  '議案第18号 令和8年度石垣市港湾事業特別会計予算',
  '議案第19号 令和8年度石垣市下水道事業会計予算'
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
    ('議案第14号 令和8年度石垣市国民健康保険事業特別会計予算', '予算・財政'),
    ('議案第15号 令和8年度石垣市後期高齢者医療特別会計予算', '予算・財政'),
    ('議案第16号 令和8年度石垣市介護保険事業特別会計予算', '予算・財政'),
    ('議案第17号 令和8年度石垣都市計画土地区画整理事業特別会計予算', '自治・まちづくり'),
    ('議案第18号 令和8年度石垣市港湾事業特別会計予算', '予算・財政'),
    ('議案第19号 令和8年度石垣市下水道事業会計予算', '上下水道・インフラ')
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
  '議案第14号 令和8年度石垣市国民健康保険事業特別会計予算',
  '議案第15号 令和8年度石垣市後期高齢者医療特別会計予算',
  '議案第16号 令和8年度石垣市介護保険事業特別会計予算',
  '議案第17号 令和8年度石垣都市計画土地区画整理事業特別会計予算',
  '議案第18号 令和8年度石垣市港湾事業特別会計予算',
  '議案第19号 令和8年度石垣市下水道事業会計予算'
)
order by t.featured_priority nulls last, b.name, t.label;
