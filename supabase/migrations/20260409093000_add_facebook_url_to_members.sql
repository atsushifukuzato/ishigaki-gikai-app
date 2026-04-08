do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'members'
  ) then
    alter table public.members
    add column if not exists facebook_url text;

    comment on column public.members.facebook_url is '議員のFacebookプロフィールURL';
  end if;
end
$$;
