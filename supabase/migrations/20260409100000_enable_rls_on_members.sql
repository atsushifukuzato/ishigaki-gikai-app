alter table public.members enable row level security;

drop policy if exists "members_public_read" on public.members;

create policy "members_public_read"
on public.members
for select
to anon, authenticated
using (true);
