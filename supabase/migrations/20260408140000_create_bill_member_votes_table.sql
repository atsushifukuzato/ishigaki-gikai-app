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

comment on table public.bill_member_votes is '議案ごとの各議員の採決結果を保持するテーブル';
comment on column public.bill_member_votes.seat_number is '公開資料上の議席番号';
comment on column public.bill_member_votes.vote_type is '賛成、賛成ではない、欠席、退席、議長の別';
comment on column public.bill_member_votes.source_label is '出典ラベル';
comment on column public.bill_member_votes.source_url is '出典URL';

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
