alter table public.diet_sessions enable row level security;
alter table public.bills enable row level security;
alter table public.bill_contents enable row level security;
alter table public.tags enable row level security;
alter table public.bills_tags enable row level security;
alter table public.bill_member_votes enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'diet_sessions'
      and policyname = 'diet_sessions_public_read'
  ) then
    create policy "diet_sessions_public_read"
      on public.diet_sessions
      for select
      to anon, authenticated
      using (true);
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bills'
      and policyname = 'bills_public_read_published'
  ) then
    create policy "bills_public_read_published"
      on public.bills
      for select
      to anon, authenticated
      using (publish_status = 'published');
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bill_contents'
      and policyname = 'bill_contents_public_read_published'
  ) then
    create policy "bill_contents_public_read_published"
      on public.bill_contents
      for select
      to anon, authenticated
      using (
        exists (
          select 1
          from public.bills
          where bills.id = bill_contents.bill_id
            and bills.publish_status = 'published'
        )
      );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'tags'
      and policyname = 'tags_public_read'
  ) then
    create policy "tags_public_read"
      on public.tags
      for select
      to anon, authenticated
      using (true);
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bills_tags'
      and policyname = 'bills_tags_public_read_published'
  ) then
    create policy "bills_tags_public_read_published"
      on public.bills_tags
      for select
      to anon, authenticated
      using (
        exists (
          select 1
          from public.bills
          where bills.id = bills_tags.bill_id
            and bills.publish_status = 'published'
        )
      );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bill_member_votes'
      and policyname = 'bill_member_votes_public_read_published'
  ) then
    create policy "bill_member_votes_public_read_published"
      on public.bill_member_votes
      for select
      to anon, authenticated
      using (
        exists (
          select 1
          from public.bills
          where bills.id = bill_member_votes.bill_id
            and bills.publish_status = 'published'
        )
      );
  end if;
end
$$;

select
  schemaname,
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'diet_sessions',
    'bills',
    'bill_contents',
    'tags',
    'bills_tags',
    'bill_member_votes'
  )
order by tablename;

select
  tablename,
  policyname,
  roles,
  cmd
from pg_policies
where schemaname = 'public'
  and tablename in (
    'diet_sessions',
    'bills',
    'bill_contents',
    'tags',
    'bills_tags',
    'bill_member_votes'
  )
order by tablename, policyname;
