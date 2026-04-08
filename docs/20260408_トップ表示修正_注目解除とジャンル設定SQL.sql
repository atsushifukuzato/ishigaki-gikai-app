-- 石垣市議会版 みらい議会
-- トップ表示修正用 本番反映 SQL
--
-- 目的:
-- - 既存の「注目の議案」表示をなくすため、対象議案の is_featured を false にそろえる
-- - 第1弾〜第3弾までに整備した実議案へジャンルタグを付与し、トップのジャンル別表示に出るようにする
-- - 既存のトップ用タグ（featured_priority 付き）は維持しつつ、不足しているタグを追加する
--
-- 対象:
-- A. 既存の注目議案 3件
-- 1. 議員提出議案第2号 尖閣諸島周辺海域における漁船用係留ブイの設置を求める意見書
-- 2. 議案第13号 令和8年度石垣市一般会計予算
-- 3. 議案第21号 石垣市犯罪被害者等支援条例
--
-- B. 第1弾〜第3弾で本文を整えた議案
-- 4. 議案第22号 石垣市自治基本条例の一部を改正する条例
-- 5. 議案第27号 石垣市下水道条例の一部を改正する条例
-- 6. 議案第28号 石垣市農業集落排水処理施設の管理に関する条例の改正
-- 7. 議案第32号 映画「尖閣1945」製作業務委託契約の変更について
-- 8. 議案第20号 令和8年度石垣市水道事業会計予算
-- 9. 議員提出議案第7号 石垣市立八重山博物館（新館）の整備に関する決議
-- 10. 議員提出議案第12号 令和8年度からの小中学校給食費の無償化を求める決議
-- 11. 議員提出議案第3号 尖閣諸島字名標柱設置のための上陸許可を求める意見書
-- 12. 議員提出議案第4号 イランへの軍事攻撃の即時停止と中東地域の平和的解決を求める意見書
-- 13. 議員提出議案第5号 長射程ミサイル配備に反対し対話と平和外交の推進を求める意見書
-- 14. 議員提出議案第10号 海上活動の安全対策及び監督体制の強化を求める意見書
--
-- 方針:
-- - seed 由来のサンプル議案は対象外
-- - 「注目の議案」セクションに出したくないため、対象14件の is_featured は false にそろえる
-- - トップ表示は featured_priority 付きタグのセクションで見せる前提に整える

begin;

update public.bills
set
  is_featured = false,
  updated_at = now()
where id in (
  '1910ab95-4010-4b17-a926-97ff781cd718',
  '6fba22ef-49f8-435e-9b81-59331fd55810',
  '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86',
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44',
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b',
  '557e41c4-9e37-46a7-b372-49a7a4f681bb',
  '5e66bfbb-9508-4e3b-afb3-8f5e1d13f015',
  '59fa4602-dc04-455f-8129-6723680efdcb',
  'be01b42a-fc94-44c6-8a4e-184ee65d0c5d'
);

insert into public.tags (
  label,
  featured_priority,
  description
)
values
  ('安全保障・水産', 1, '安全保障や海上安全、水産業に関わる議案・意見書'),
  ('予算・財政', 2, '予算、財政運営、税制に関わる議案'),
  ('暮らし・福祉', 3, '市民生活、福祉、支援制度に関わる議案'),
  ('自治・まちづくり', 4, '自治のルールや市政運営、まちづくりに関する議案'),
  ('上下水道・インフラ', 5, '水道、下水道、排水処理など生活インフラに関する議案'),
  ('文化・観光', 6, '文化施設、文化政策、観光や地域発信に関する議案'),
  ('子育て・教育', 7, '子育て支援、学校、教育環境に関する議案'),
  ('平和・外交', 8, '平和、人権、国際情勢、外交に関する議案・意見書'),
  ('海上安全', 9, '海上活動の安全対策、監督体制、事故防止に関する議案・意見書')
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
  v.bill_id,
  t.id
from (
  values
    ('1910ab95-4010-4b17-a926-97ff781cd718'::uuid, '安全保障・水産'),
    ('6fba22ef-49f8-435e-9b81-59331fd55810'::uuid, '予算・財政'),
    ('2dd64ab8-c4ef-48b6-a40a-61fa224c1f86'::uuid, '暮らし・福祉'),
    ('d925588d-9967-43a6-8294-ddcbbd641c68'::uuid, '自治・まちづくり'),
    ('256c8fb9-9f5b-4f24-a308-51c360e50afd'::uuid, '上下水道・インフラ'),
    ('32bbb420-6951-4d55-be2f-21675bcea341'::uuid, '上下水道・インフラ'),
    ('8147ad18-b74f-4431-8e21-11b6105efb44'::uuid, '文化・観光'),
    ('69776933-266d-4622-a266-f0df02d0d2ae'::uuid, '予算・財政'),
    ('d716a2d3-ca7c-48c4-b45e-cad91a341db9'::uuid, '文化・観光'),
    ('9fd86780-cf7d-49b8-8b58-6151662e3b5b'::uuid, '子育て・教育'),
    ('557e41c4-9e37-46a7-b372-49a7a4f681bb'::uuid, '安全保障・水産'),
    ('5e66bfbb-9508-4e3b-afb3-8f5e1d13f015'::uuid, '平和・外交'),
    ('59fa4602-dc04-455f-8129-6723680efdcb'::uuid, '平和・外交'),
    ('be01b42a-fc94-44c6-8a4e-184ee65d0c5d'::uuid, '海上安全')
) as v(bill_id, tag_label)
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
where b.id in (
  '1910ab95-4010-4b17-a926-97ff781cd718',
  '6fba22ef-49f8-435e-9b81-59331fd55810',
  '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86',
  'd925588d-9967-43a6-8294-ddcbbd641c68',
  '256c8fb9-9f5b-4f24-a308-51c360e50afd',
  '32bbb420-6951-4d55-be2f-21675bcea341',
  '8147ad18-b74f-4431-8e21-11b6105efb44',
  '69776933-266d-4622-a266-f0df02d0d2ae',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b',
  '557e41c4-9e37-46a7-b372-49a7a4f681bb',
  '5e66bfbb-9508-4e3b-afb3-8f5e1d13f015',
  '59fa4602-dc04-455f-8129-6723680efdcb',
  'be01b42a-fc94-44c6-8a4e-184ee65d0c5d'
)
order by t.featured_priority nulls last, b.name, t.label;
