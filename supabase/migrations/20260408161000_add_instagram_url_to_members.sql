alter table public.members
add column if not exists instagram_url text;

comment on column public.members.instagram_url is '議員のInstagramプロフィールURL';
