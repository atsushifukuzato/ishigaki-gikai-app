-- 石垣市議会版 みらい議会
-- 第1弾・第2弾で整備した実議案のジャンル設定と注目解除の本番反映 SQL
--
-- 対象:
-- 第1弾
-- 1. 議案第22号 石垣市自治基本条例の一部を改正する条例
-- 2. 議案第27号 石垣市下水道条例の一部を改正する条例
-- 3. 議案第28号 石垣市農業集落排水処理施設の管理に関する条例の改正
-- 4. 議案第32号 映画「尖閣1945」製作業務委託契約の変更について
--
-- 第2弾
-- 5. 議案第20号 令和8年度石垣市水道事業会計予算
-- 6. 議員提出議案第7号 石垣市立八重山博物館（新館）の整備に関する決議
-- 7. 議員提出議案第12号 令和8年度からの石垣市における小中学校給食費の無償化を求める決議
--
-- 方針:
-- - 第1弾・第2弾で追加した7議案に、石垣市議会版の表示用ジャンル（tags / bills_tags）を設定する
-- - いったん第1弾・第2弾でトップ掲載用に付けた is_featured は、対象7議案すべてで false に戻す
-- - seed 由来のサンプル議案は対象外

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where id in (
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44',
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b'
);

insert into public.tags (
  label,
  featured_priority,
  description
)
values
  ('自治・まちづくり', null, '自治のルールや市政運営、まちづくりに関する議案'),
  ('上下水道・インフラ', null, '水道、下水道、排水処理など生活インフラに関する議案'),
  ('文化・観光', null, '文化施設、文化政策、観光や地域発信に関する議案'),
  ('予算・財政', null, '予算編成や財政運営に関する議案'),
  ('子育て・教育', null, '子育て支援、学校、教育環境に関する議案')
on conflict (label) do update
set
  description = excluded.description,
  updated_at = now();

insert into public.bills_tags (
  bill_id,
  tag_id
)
select
  v.bill_id,
  t.id
from (
  values
    ('d925588d-9967-43a6-8294-ddcbbd641c68'::uuid, '自治・まちづくり'),
    ('256c8fb9-9f5b-4f24-a308-51c360e50afd'::uuid, '上下水道・インフラ'),
    ('32bbb420-6951-4d55-be2f-21675bcea341'::uuid, '上下水道・インフラ'),
    ('8147ad18-b74f-4431-8e21-11b6105efb44'::uuid, '文化・観光'),
    ('69776933-266d-4622-a266-f0df02d0d2ae'::uuid, '予算・財政'),
    ('d716a2d3-ca7c-48c4-b45e-cad91a341db9'::uuid, '文化・観光'),
    ('9fd86780-cf7d-49b8-8b58-6151662e3b5b'::uuid, '子育て・教育')
) as v(bill_id, tag_label)
join public.tags t
  on t.label = v.tag_label
on conflict (bill_id, tag_id) do nothing;

commit;

-- 実行後の確認用
select
  b.name,
  b.is_featured,
  t.label as tag_label
from public.bills b
left join public.bills_tags bt
  on bt.bill_id = b.id
left join public.tags t
  on t.id = bt.tag_id
where b.id in (
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44',
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b'
)
order by b.name, t.label;
