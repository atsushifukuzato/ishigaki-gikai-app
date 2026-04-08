alter table public.members
add column if not exists facebook_url text;

comment on column public.members.facebook_url is '議員のFacebookプロフィールURL';

select
  id,
  name,
  facebook_url
from public.members
order by name_kana nulls last, name;
