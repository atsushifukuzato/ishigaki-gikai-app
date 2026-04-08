alter table public.members enable row level security;

drop policy if exists "members_public_read" on public.members;

create policy "members_public_read"
on public.members
for select
to anon, authenticated
using (true);

select
  schemaname,
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename = 'members';

select
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
where schemaname = 'public'
  and tablename = 'members';
