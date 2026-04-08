-- 石垣市議会版 みらい議会
-- members テーブルへ Instagram URL を追加する本番反映 SQL
--
-- 方針:
-- - members テーブルに instagram_url カラムを追加する
-- - 実際の URL データ投入は、アカウント確認後に別途 update する

alter table public.members
add column if not exists instagram_url text;

comment on column public.members.instagram_url is '議員のInstagramプロフィールURL';

-- 実行後の確認用
select
  name,
  instagram_url
from public.members
order by name;
