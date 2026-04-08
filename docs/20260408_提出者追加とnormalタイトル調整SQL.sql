-- 石垣市議会版 みらい議会
-- 提出者追加と normal タイトル調整の本番反映 SQL
--
-- 目的:
-- - bills.proposer_member_id を追加し、議員提出議案の提出者を members に紐づける
-- - 既に整備済みの normal タイトルから「とは」を外す
--
-- 対象の提出者設定:
-- 1. 議員提出議案第1号  -> 髙良 宗矩
-- 2. 議員提出議案第2号  -> 仲嶺 忠師
-- 3. 議員提出議案第3号  -> 仲嶺 忠師
-- 4. 議員提出議案第4号  -> 井上 美智子
-- 5. 議員提出議案第5号  -> 花谷 史郎
-- 6. 議員提出議案第6号  -> 新里 裕樹
-- 7. 議員提出議案第7号  -> 長山 家康
-- 8. 議員提出議案第8号  -> 石川 勇作
-- 9. 議員提出議案第10号 -> 髙良 宗矩
-- 10. 議員提出議案第11号 -> 長山 家康
-- 11. 議員提出議案第12号 -> 内原 英聡

begin;

alter table public.bills
add column if not exists proposer_member_id uuid;

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'members'
  ) and not exists (
    select 1
    from pg_constraint
    where conname = 'bills_proposer_member_id_fkey'
  ) then
    alter table public.bills
    add constraint bills_proposer_member_id_fkey
    foreign key (proposer_member_id)
    references public.members(id)
    on delete set null;
  end if;
end
$$;

comment on column public.bills.proposer_member_id is '議員提出議案の提出者（members.id）。市長提出など提出者が議員でない場合はNULL。';

create index if not exists idx_bills_proposer_member_id
  on public.bills using btree (proposer_member_id);

update public.bills
set
  proposer_member_id = v.member_id,
  updated_at = now()
from (
  values
    ('8666d582-7990-426f-87de-7d37ed64dd29'::uuid, '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b'::uuid),
    ('1910ab95-4010-4b17-a926-97ff781cd718'::uuid, 'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2'::uuid),
    ('557e41c4-9e37-46a7-b372-49a7a4f681bb'::uuid, 'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2'::uuid),
    ('5e66bfbb-9508-4e3b-afb3-8f5e1d13f015'::uuid, '9f6ee646-5814-482d-8f91-57293a905602'::uuid),
    ('59fa4602-dc04-455f-8129-6723680efdcb'::uuid, 'a30c4e98-585a-43bc-b8f7-1dddbe7426bf'::uuid),
    ('24b3b653-b15a-4323-b20d-b448a20f3a8e'::uuid, '70fa0ad2-210f-40fa-9f34-0640839a40ff'::uuid),
    ('d716a2d3-ca7c-48c4-b45e-cad91a341db9'::uuid, 'fafc35f8-8a5b-457f-b63d-a4cc1421de53'::uuid),
    ('9d9474ee-5198-4034-9f23-74282a12b2cb'::uuid, '936cd874-ec02-4b48-b1aa-c6b50dad6bc5'::uuid),
    ('be01b42a-fc94-44c6-8a4e-184ee65d0c5d'::uuid, '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b'::uuid),
    ('6c5fe252-15a6-45ec-affb-dc159534bd4c'::uuid, 'fafc35f8-8a5b-457f-b63d-a4cc1421de53'::uuid),
    ('9fd86780-cf7d-49b8-8b58-6151662e3b5b'::uuid, 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2'::uuid)
) as v(bill_id, member_id)
where public.bills.id = v.bill_id;

update public.bill_contents
set
  title = regexp_replace(title, 'とは$', ''),
  updated_at = now()
where difficulty_level = 'normal'
  and bill_id in (
    '1910ab95-4010-4b17-a926-97ff781cd718',
    '6fba22ef-49f8-435e-9b81-59331fd55810',
    '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86',
    'd925588d-9967-43a6-8294-ddcbbd641c68',
    '8147ad18-b74f-4431-8e21-11b6105efb44',
    '256c8fb9-9f5b-4f24-a308-51c360e50afd',
    '32bbb420-6951-4d55-be2f-21675bcea341',
    '69776933-266d-4622-a266-f0df02d0d2ae',
    'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
    '9fd86780-cf7d-49b8-8b58-6151662e3b5b',
    '557e41c4-9e37-46a7-b372-49a7a4f681bb',
    '5e66bfbb-9508-4e3b-afb3-8f5e1d13f015',
    '59fa4602-dc04-455f-8129-6723680efdcb',
    'be01b42a-fc94-44c6-8a4e-184ee65d0c5d',
    '8666d582-7990-426f-87de-7d37ed64dd29',
    '24b3b653-b15a-4323-b20d-b448a20f3a8e',
    '9d9474ee-5198-4034-9f23-74282a12b2cb',
    '6c5fe252-15a6-45ec-affb-dc159534bd4c'
  )
  and title like '%とは';

commit;

-- 実行後の確認用
select
  b.name,
  m.name as proposer_name,
  bc.difficulty_level,
  bc.title
from public.bills b
left join public.members m
  on m.id = b.proposer_member_id
left join public.bill_contents bc
  on bc.bill_id = b.id
  and bc.difficulty_level = 'normal'
where b.id in (
  '8666d582-7990-426f-87de-7d37ed64dd29',
  '1910ab95-4010-4b17-a926-97ff781cd718',
  '557e41c4-9e37-46a7-b372-49a7a4f681bb',
  '5e66bfbb-9508-4e3b-afb3-8f5e1d13f015',
  '59fa4602-dc04-455f-8129-6723680efdcb',
  '24b3b653-b15a-4323-b20d-b448a20f3a8e',
  'd716a2d3-ca7c-48c4-b45e-cad91a341db9',
  '9d9474ee-5198-4034-9f23-74282a12b2cb',
  'be01b42a-fc94-44c6-8a4e-184ee65d0c5d',
  '6c5fe252-15a6-45ec-affb-dc159534bd4c',
  '9fd86780-cf7d-49b8-8b58-6151662e3b5b',
  '6fba22ef-49f8-435e-9b81-59331fd55810',
  '2dd64ab8-c4ef-48b6-a40a-61fa224c1f86'
)
order by b.name;
