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
