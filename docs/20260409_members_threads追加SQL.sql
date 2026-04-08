alter table public.members
add column if not exists threads_url text;

comment on column public.members.threads_url is '議員のThreadsプロフィールURL';

select
  id,
  name,
  threads_url
from public.members
order by name_kana nulls last, name;
