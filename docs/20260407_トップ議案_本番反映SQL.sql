-- 石垣市議会版 みらい議会
-- トップ表示用 3 議案の本番反映 SQL
--
-- 対象:
-- 1. 議員提出議案第2号 尖閣諸島周辺海域における漁船用係留ブイの設置を求める意見書
-- 2. 議案第13号 令和8年度石垣市一般会計予算
-- 3. 議案第21号 石垣市犯罪被害者等支援条例
--
-- 目的:
-- - bills.is_featured を true にする
-- - bill_contents(normal) を追加または更新する
-- - featured_priority 付きタグを追加または更新する
-- - bills_tags を追加または更新する

begin;

update public.bills
set is_featured = true
where id in (
  '1910ab95-4010-4b17-a926-97ff781cd718',
  '6fba22ef-49f8-435e-9b81-59331fd55810',
  '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86'
);

insert into public.bill_contents (
  bill_id,
  difficulty_level,
  title,
  summary,
  content
)
values
  (
    '1910ab95-4010-4b17-a926-97ff781cd718',
    'normal',
    '尖閣諸島周辺海域における漁船用係留ブイの設置を求める意見書とは',
    '尖閣諸島周辺の海域で操業する漁船の安全性や作業環境の向上のため、係留ブイの設置を国などに求める意見書です。石垣市の漁業や海上安全保障の観点から必要性を訴える内容です。',
    E'この議案は、尖閣諸島周辺海域で操業する漁船が安全に活動できるよう、係留ブイの設置を求める意見書です。係留ブイが整備されれば、荒天時や緊急時の安全確保、漁業者の負担軽減、操業の安定につながることが期待されます。\n\n尖閣周辺海域は、漁業の場であると同時に、安全保障や海上保安の観点からも重要な地域です。そのため、この意見書は単なる漁業支援にとどまらず、地域の安全や国の対応を求める意味も持っています。\n\n市議会では、係留ブイ設置の必要性、国や関係機関への要請内容、地域経済や漁業者への影響などが審議のポイントになります。石垣市にとっては、地域の基幹産業である水産業と、国境離島としての現実の両方に関わる重要なテーマです。'
  ),
  (
    '6fba22ef-49f8-435e-9b81-59331fd55810',
    'normal',
    '令和8年度石垣市一般会計予算とは',
    '石垣市の令和8年度の一般会計予算を定める議案です。暮らしや福祉、教育、インフラなど、市のさまざまな事業にどのくらいお金を使うかの全体像を決めます。',
    E'この議案は、石垣市の令和8年度の一般会計予算を定めるものです。一般会計は、市民生活に関わる基本的な行政サービスを支える予算で、福祉、子育て、教育、道路や施設の維持管理、防災、観光、産業支援など幅広い分野が対象になります。\n\n予算議案では、市が1年間にどのような事業を進めるのか、そのためにどのくらいの支出を行うのか、また財源をどう確保するのかを確認することが大切です。新規事業や重点施策が含まれているか、前年度から大きく増減している分野があるかも重要なポイントです。\n\n市議会では、予算の規模だけでなく、市民生活への影響や地域課題への対応、持続可能な財政運営になっているかを審議します。市民にとっては、今後1年間の石垣市の政策の優先順位が表れる議案だといえます。'
  ),
  (
    '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86',
    'normal',
    '石垣市犯罪被害者等支援条例とは',
    '犯罪被害を受けた本人や家族などを、石垣市としてどのように支えるかを定める条例案です。相談支援や情報提供、関係機関との連携の考え方を明確にします。',
    E'この議案は、犯罪被害を受けた人やその家族、遺族などに対して、石垣市としてどのような支援を行うかの基本的な考え方を定める条例案です。\n\n犯罪被害者は、事件そのものの被害だけでなく、心身の不調、生活の変化、周囲との関係の困難など、長期にわたる負担を抱えることがあります。条例を定めることで、市として支援の必要性を明確にし、相談体制や情報提供、関係機関との連携を進めやすくなります。\n\n市議会では、条例の対象範囲、支援内容、実施体制、継続的な運用のあり方などが審議のポイントになります。市民にとっては、被害に遭ったときに地域としてどう支えるかを形にする重要な議案です。'
  )
on conflict (bill_id, difficulty_level) do update
set
  title = excluded.title,
  summary = excluded.summary,
  content = excluded.content,
  updated_at = now();

insert into public.tags (
  label,
  featured_priority,
  description
)
values
  ('安全保障・水産', 1, '石垣市の海域、安全保障、水産業に関する議案'),
  ('予算・財政', 2, '石垣市の予算編成や財政運営に関する議案'),
  ('暮らし・福祉', 3, '市民生活、支援制度、福祉に関する議案')
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
    ('2dd64ab8-c4ef-48b6-a40a-61fa224c1f86'::uuid, '暮らし・福祉')
) as v(bill_id, tag_label)
join public.tags t
  on t.label = v.tag_label
on conflict (bill_id, tag_id) do nothing;

commit;

-- 実行後の確認用
select
  b.id,
  b.name,
  b.is_featured,
  bc.difficulty_level,
  bc.title,
  t.label as tag_label,
  t.featured_priority
from public.bills b
left join public.bill_contents bc
  on bc.bill_id = b.id
  and bc.difficulty_level = 'normal'
left join public.bills_tags bt
  on bt.bill_id = b.id
left join public.tags t
  on t.id = bt.tag_id
where b.id in (
  '1910ab95-4010-4b17-a926-97ff781cd718',
  '6fba22ef-49f8-435e-9b81-59331fd55810',
  '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86'
)
order by b.name, t.featured_priority nulls last, t.label;
