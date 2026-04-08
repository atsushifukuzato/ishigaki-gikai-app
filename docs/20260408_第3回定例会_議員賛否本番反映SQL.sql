-- 石垣市議会版 みらい議会
-- 第3回定例会の議員賛否表示を本番反映する SQL
--
-- 前提:
-- - public.members が作成済みで、議員データが投入済みであること
-- - 出典は石垣市公開 PDF
--   https://www.city.ishigaki.okinawa.jp/material/files/group/33/R8_dai3_sanseisya.pdf
-- - PDF の凡例に合わせて、△ は「反対」ではなく「賛成ではない」として保持する

begin;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'bill_vote_type_enum'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.bill_vote_type_enum as enum (
      'for',
      'not_for',
      'absent',
      'left',
      'chair'
    );
  end if;
end
$$;

create table if not exists public.bill_member_votes (
  bill_id uuid not null,
  member_id uuid not null,
  seat_number integer not null,
  vote_type public.bill_vote_type_enum not null,
  source_label text,
  source_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bill_member_votes_pkey primary key (bill_id, member_id),
  constraint bill_member_votes_bill_id_fkey
    foreign key (bill_id) references public.bills(id) on delete cascade,
  constraint bill_member_votes_member_id_fkey
    foreign key (member_id) references public.members(id) on delete cascade,
  constraint bill_member_votes_seat_number_check check (seat_number >= 1)
);

create index if not exists idx_bill_member_votes_bill_id
  on public.bill_member_votes using btree (bill_id);

create index if not exists idx_bill_member_votes_vote_type
  on public.bill_member_votes using btree (vote_type);

do $$
begin
  if not exists (
    select 1
    from pg_trigger
    where tgname = 'update_bill_member_votes_updated_at'
      and tgrelid = 'public.bill_member_votes'::regclass
      and not tgisinternal
  ) then
    create trigger update_bill_member_votes_updated_at
    before update on public.bill_member_votes
    for each row execute function public.update_updated_at_column();
  end if;
end
$$;

with seat_members (seat_number, member_id) as (
  values
    (1, '76d6fcfc-f552-4272-914a-a381aa7a226b'::uuid),
    (2, 'a30c4e98-585a-43bc-b8f7-1dddbe7426bf'::uuid),
    (3, 'b4251917-a7f3-477f-be4d-abbca211cde7'::uuid),
    (4, '83c86ab6-afc9-471d-9811-714a6ac248bd'::uuid),
    (5, '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b'::uuid),
    (6, '71dfb79c-1092-47ef-8bce-37c9a8ee3b06'::uuid),
    (7, '70fa0ad2-210f-40fa-9f34-0640839a40ff'::uuid),
    (8, 'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2'::uuid),
    (9, '4db2ea1a-51ea-4f20-8ec2-ed55063c1752'::uuid),
    (10, '0374f5bb-bde4-4fc6-9cb0-598d4b58d37a'::uuid),
    (11, 'fafc35f8-8a5b-457f-b63d-a4cc1421de53'::uuid),
    (12, '936cd874-ec02-4b48-b1aa-c6b50dad6bc5'::uuid),
    (13, '9f6ee646-5814-482d-8f91-57293a905602'::uuid),
    (14, 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2'::uuid),
    (15, '1672bf78-0505-4041-b301-75a22616edc4'::uuid),
    (16, '33422421-3897-4b09-81c2-8fb91bfdebfa'::uuid),
    (17, '0faca1b2-4ed6-4b71-bff6-39cfb5edca7d'::uuid),
    (18, '2986e72e-ab8a-465f-b826-6118687ab673'::uuid),
    (19, '141916de-d2b8-406d-9457-ad7057332ff1'::uuid),
    (20, '2538eb08-aa41-41f0-8ec1-713ef7e26697'::uuid),
    (21, 'dfd899e1-26bf-4d16-b353-28a96a067a7b'::uuid),
    (22, 'dec9dc59-70e9-4372-96bd-9b26150d0646'::uuid)
),
bill_votes (
  bill_id,
  seat_votes
) as (
  values
    (
      '8147ad18-b74f-4431-8e21-11b6105efb44'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'absent', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      'd925588d-9967-43a6-8294-ddcbbd641c68'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'chair', 'not_for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '6fba22ef-49f8-435e-9b81-59331fd55810'::uuid,
      array['not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'for', 'for', 'for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '256c8fb9-9f5b-4f24-a308-51c360e50afd'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'chair', 'not_for', 'not_for', 'not_for', 'not_for']::public.bill_vote_type_enum[]
    ),
    (
      '32bbb420-6951-4d55-be2f-21675bcea341'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'chair', 'not_for', 'not_for', 'not_for', 'not_for']::public.bill_vote_type_enum[]
    ),
    (
      '69776933-266d-4622-a266-f0df02d0d2ae'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '1910ab95-4010-4b17-a926-97ff781cd718'::uuid,
      array['for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'left', 'not_for', 'for', 'for', 'for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '557e41c4-9e37-46a7-b372-49a7a4f681bb'::uuid,
      array['for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'for', 'not_for', 'not_for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '5e66bfbb-9508-4e3b-afb3-8f5e1d13f015'::uuid,
      array['for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'chair', 'not_for', 'not_for', 'for', 'not_for']::public.bill_vote_type_enum[]
    ),
    (
      '59fa4602-dc04-455f-8129-6723680efdcb'::uuid,
      array['for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'chair', 'not_for', 'not_for', 'for', 'not_for']::public.bill_vote_type_enum[]
    ),
    (
      'd716a2d3-ca7c-48c4-b45e-cad91a341db9'::uuid,
      array['not_for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      'b6cbf111-5bc9-46ae-963d-94d8b0c39cf5'::uuid,
      array['for', 'for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'not_for', 'not_for', 'for', 'not_for', 'not_for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      'be01b42a-fc94-44c6-8a4e-184ee65d0c5d'::uuid,
      array['for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'for', 'left', 'for', 'for', 'for', 'chair', 'for', 'for', 'for', 'for']::public.bill_vote_type_enum[]
    ),
    (
      '9fd86780-cf7d-49b8-8b58-6151662e3b5b'::uuid,
      array['for', 'for', 'for', 'for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'not_for', 'for', 'for', 'for', 'for', 'for', 'chair', 'not_for', 'not_for', 'not_for', 'not_for']::public.bill_vote_type_enum[]
    )
)
insert into public.bill_member_votes (
  bill_id,
  member_id,
  seat_number,
  vote_type,
  source_label,
  source_url
)
select
  bill_votes.bill_id,
  seat_members.member_id,
  seat_members.seat_number,
  bill_votes.seat_votes[seat_members.seat_number],
  '令和8年第3回定例会 議案に対する賛成者一覧（全会一致以外）',
  'https://www.city.ishigaki.okinawa.jp/material/files/group/33/R8_dai3_sanseisya.pdf'
from bill_votes
cross join seat_members
on conflict (bill_id, member_id) do update
set
  seat_number = excluded.seat_number,
  vote_type = excluded.vote_type,
  source_label = excluded.source_label,
  source_url = excluded.source_url,
  updated_at = now();

commit;

-- 実行後の確認用
select
  b.name,
  bmv.seat_number,
  m.name as member_name,
  bmv.vote_type
from public.bill_member_votes bmv
join public.bills b
  on b.id = bmv.bill_id
join public.members m
  on m.id = bmv.member_id
where b.diet_session_id = '04984cbc-59cf-4907-b02e-855cfd1b3428'
order by b.name, bmv.seat_number;
