do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'members'
  ) then
    alter table public.members
    add column if not exists instagram_url text;

    comment on column public.members.instagram_url is '議員のInstagramプロフィールURL';
  end if;
end
$$;
