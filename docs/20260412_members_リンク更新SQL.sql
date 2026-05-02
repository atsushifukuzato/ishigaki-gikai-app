begin;

alter table public.members
  add column if not exists youtube_url text,
  add column if not exists line_url text;

comment on column public.members.youtube_url is '議員のYouTubeチャンネルURL';
comment on column public.members.line_url is '議員のLINE公式アカウントURL';

create table if not exists public.member_links (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  service text not null,
  label text,
  url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (member_id, service, url)
);

create index if not exists idx_member_links_member_id_sort_order
  on public.member_links(member_id, sort_order, created_at);

alter table public.member_links enable row level security;

drop policy if exists "member_links_public_read" on public.member_links;

create policy "member_links_public_read"
on public.member_links
for select
to anon, authenticated
using (true);

update public.members
set
  website_url = 'https://hanatanishiro.perma.jp/',
  twitter_url = 'https://x.com/shiro_hanatani',
  facebook_url = 'https://www.facebook.com/shiro.hanatani',
  instagram_url = 'https://www.instagram.com/shirohanatani',
  threads_url = 'https://www.threads.com/@shirohanatani',
  youtube_url = null,
  line_url = null
where id = 'a30c4e98-585a-43bc-b8f7-1dddbe7426bf';

update public.members
set
  website_url = 'https://ameblo.jp/nachan88nacha88/',
  twitter_url = null,
  facebook_url = null,
  instagram_url = 'https://www.instagram.com/natsuyo4388',
  threads_url = 'https://www.threads.com/@natsuyo4388',
  youtube_url = null,
  line_url = null
where id = 'b4251917-a7f3-477f-be4d-abbca211cde7';

update public.members
set
  website_url = null,
  twitter_url = 'https://x.com/takara_munenori',
  facebook_url = 'https://www.facebook.com/TakaraMunenori',
  instagram_url = 'https://www.instagram.com/takara_munenori/',
  threads_url = 'https://www.threads.com/@takara_munenori',
  youtube_url = null,
  line_url = null
where id = '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/p/%E7%99%BB%E9%87%8E%E5%9F%8E-%E3%81%93%E3%81%AE%E3%81%BF-100083310469410/',
  instagram_url = 'https://www.instagram.com/konomi4649/',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '71dfb79c-1092-47ef-8bce-37c9a8ee3b06';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/yuuki.shinzato.9',
  instagram_url = 'https://www.instagram.com/yuki_shinzato_ishigakijima/',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '70fa0ad2-210f-40fa-9f34-0640839a40ff';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/tadashi.nakamine',
  instagram_url = 'https://www.instagram.com/nakaminetadashi/',
  threads_url = 'https://www.threads.com/@nakaminetadashi',
  youtube_url = null,
  line_url = null
where id = 'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2';

update public.members
set
  website_url = 'https://www.komei.or.jp/member/detail/47207158',
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/tatsuya.ishigaki.9887/',
  instagram_url = 'https://www.instagram.com/tatsuyaishigakicity/',
  threads_url = 'https://www.threads.com/@tatsuyaishigakicity',
  youtube_url = null,
  line_url = null
where id = '0374f5bb-bde4-4fc6-9cb0-598d4b58d37a';

update public.members
set
  website_url = 'https://xn--n8ji5c1j.com/',
  twitter_url = 'https://x.com/ieyasu_isg',
  facebook_url = 'https://www.facebook.com/ieyasu.ISG/',
  instagram_url = 'https://www.instagram.com/ieyasu_isg/',
  threads_url = 'https://www.threads.com/@ieyasu_isg',
  youtube_url = null,
  line_url = 'https://line.me/R/ti/p/@415pwhlw'
where id = 'fafc35f8-8a5b-457f-b63d-a4cc1421de53';

update public.members
set
  website_url = null,
  twitter_url = 'https://x.com/yuusaku_isg11',
  facebook_url = null,
  instagram_url = 'https://www.instagram.com/yuusaku_isk911/',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '936cd874-ec02-4b48-b1aa-c6b50dad6bc5';

update public.members
set
  website_url = 'https://uchihara.live/',
  twitter_url = 'https://x.com/Hidetoshi_yaima',
  facebook_url = 'https://www.facebook.com/uchihara.kouenkai2022/',
  instagram_url = 'https://www.instagram.com/yugafu_kaiha/',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/yoichi.minosoko/',
  instagram_url = 'https://www.instagram.com/minosoko_yoichi/',
  threads_url = 'https://www.threads.com/@minosoko_yoichi',
  youtube_url = null,
  line_url = null
where id = '1672bf78-0505-4041-b301-75a22616edc4';

update public.members
set
  website_url = null,
  twitter_url = 'https://x.com/miyaramisao',
  facebook_url = null,
  instagram_url = null,
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '33422421-3897-4b09-81c2-8fb91bfdebfa';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = 'https://www.facebook.com/gakiyaryuji/',
  instagram_url = 'https://www.instagram.com/gakiya__ryuji/',
  threads_url = 'https://www.threads.com/@gakiya__ryuji',
  youtube_url = null,
  line_url = null
where id = '2986e72e-ab8a-465f-b826-6118687ab673';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = null,
  instagram_url = 'https://www.instagram.com/eizotomoyose/',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '141916de-d2b8-406d-9457-ad7057332ff1';

update public.members
set
  website_url = null,
  twitter_url = null,
  facebook_url = null,
  instagram_url = 'https://www.instagram.com/chiisana.kyojin_isg',
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '2538eb08-aa41-41f0-8ec1-713ef7e26697';

update public.members
set
  website_url = 'https://www.komei.or.jp/km/ishigaki-taira-hideyuki/',
  twitter_url = 'https://x.com/taira1970',
  facebook_url = null,
  instagram_url = 'https://www.instagram.com/tairanet/',
  threads_url = 'https://www.threads.com/@tairanet',
  youtube_url = null,
  line_url = null
where id = 'dfd899e1-26bf-4d16-b353-28a96a067a7b';

update public.members
set
  website_url = null,
  twitter_url = 'https://x.com/nakamahitoshi',
  facebook_url = 'https://www.facebook.com/nakamataduko/',
  instagram_url = 'https://www.instagram.com/nakama_hitoshi/',
  threads_url = null,
  youtube_url = 'https://www.youtube.com/@hitoshinakama7842',
  line_url = null
where id = 'dec9dc59-70e9-4372-96bd-9b26150d0646';

update public.members
set
  website_url = 'https://www.jcp.or.jp/list/member/472077-01',
  twitter_url = null,
  facebook_url = null,
  instagram_url = null,
  threads_url = null,
  youtube_url = null,
  line_url = null
where id = '9f6ee646-5814-482d-8f91-57293a905602';

delete from public.member_links
where member_id in (
  'a30c4e98-585a-43bc-b8f7-1dddbe7426bf',
  'b4251917-a7f3-477f-be4d-abbca211cde7',
  '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b',
  '71dfb79c-1092-47ef-8bce-37c9a8ee3b06',
  '70fa0ad2-210f-40fa-9f34-0640839a40ff',
  'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2',
  '0374f5bb-bde4-4fc6-9cb0-598d4b58d37a',
  'fafc35f8-8a5b-457f-b63d-a4cc1421de53',
  '936cd874-ec02-4b48-b1aa-c6b50dad6bc5',
  'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2',
  '1672bf78-0505-4041-b301-75a22616edc4',
  '33422421-3897-4b09-81c2-8fb91bfdebfa',
  '2986e72e-ab8a-465f-b826-6118687ab673',
  '141916de-d2b8-406d-9457-ad7057332ff1',
  '2538eb08-aa41-41f0-8ec1-713ef7e26697',
  'dfd899e1-26bf-4d16-b353-28a96a067a7b',
  'dec9dc59-70e9-4372-96bd-9b26150d0646',
  '9f6ee646-5814-482d-8f91-57293a905602'
);

insert into public.member_links (member_id, service, label, url, sort_order)
values
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'website', '公式サイト', 'https://hanatanishiro.perma.jp/', 10),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'x', '個人X', 'https://x.com/shiro_hanatani', 20),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'facebook', '個人Facebook', 'https://www.facebook.com/shiro.hanatani', 30),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'instagram', '個人Instagram', 'https://www.instagram.com/shirohanatani', 40),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'threads', '個人Threads', 'https://www.threads.com/@shirohanatani', 50),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'instagram', '会派Instagram', 'https://www.instagram.com/yugafu_kaiha/', 60),
  ('a30c4e98-585a-43bc-b8f7-1dddbe7426bf', 'facebook', '会派Facebook', 'https://www.facebook.com/yugafu80s', 70),

  ('b4251917-a7f3-477f-be4d-abbca211cde7', 'instagram', '個人Instagram', 'https://www.instagram.com/natsuyo4388', 10),
  ('b4251917-a7f3-477f-be4d-abbca211cde7', 'threads', '個人Threads', 'https://www.threads.com/@natsuyo4388', 20),
  ('b4251917-a7f3-477f-be4d-abbca211cde7', 'website', 'Amebaブログ', 'https://ameblo.jp/nachan88nacha88/', 30),

  ('7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b', 'facebook', '個人Facebook', 'https://www.facebook.com/TakaraMunenori', 10),
  ('7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b', 'instagram', '個人Instagram', 'https://www.instagram.com/takara_munenori/', 20),
  ('7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b', 'x', '個人X', 'https://x.com/takara_munenori', 30),
  ('7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b', 'threads', '個人Threads', 'https://www.threads.com/@takara_munenori', 40),

  ('71dfb79c-1092-47ef-8bce-37c9a8ee3b06', 'instagram', '個人Instagram', 'https://www.instagram.com/konomi4649/', 10),
  ('71dfb79c-1092-47ef-8bce-37c9a8ee3b06', 'facebook', '個人Facebook', 'https://www.facebook.com/p/%E7%99%BB%E9%87%8E%E5%9F%8E-%E3%81%93%E3%81%AE%E3%81%BF-100083310469410/', 20),

  ('70fa0ad2-210f-40fa-9f34-0640839a40ff', 'facebook', '個人Facebook', 'https://www.facebook.com/yuuki.shinzato.9', 10),
  ('70fa0ad2-210f-40fa-9f34-0640839a40ff', 'instagram', '個人Instagram', 'https://www.instagram.com/yuki_shinzato_ishigakijima/', 20),

  ('c3cc242e-d8a7-4a1a-8740-1ff522ea43a2', 'facebook', '個人Facebook', 'https://www.facebook.com/tadashi.nakamine', 10),
  ('c3cc242e-d8a7-4a1a-8740-1ff522ea43a2', 'instagram', '個人Instagram', 'https://www.instagram.com/nakaminetadashi/', 20),
  ('c3cc242e-d8a7-4a1a-8740-1ff522ea43a2', 'threads', '個人Threads', 'https://www.threads.com/@nakaminetadashi', 30),

  ('0374f5bb-bde4-4fc6-9cb0-598d4b58d37a', 'instagram', '個人Instagram', 'https://www.instagram.com/tatsuyaishigakicity/', 10),
  ('0374f5bb-bde4-4fc6-9cb0-598d4b58d37a', 'threads', '個人Threads', 'https://www.threads.com/@tatsuyaishigakicity', 20),
  ('0374f5bb-bde4-4fc6-9cb0-598d4b58d37a', 'facebook', '個人Facebook', 'https://www.facebook.com/tatsuya.ishigaki.9887/', 30),
  ('0374f5bb-bde4-4fc6-9cb0-598d4b58d37a', 'website', '公式サイト', 'https://www.komei.or.jp/member/detail/47207158', 40),

  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'instagram', '個人Instagram', 'https://www.instagram.com/ieyasu_isg/', 10),
  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'threads', '個人Threads', 'https://www.threads.com/@ieyasu_isg', 20),
  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'x', '個人X', 'https://x.com/ieyasu_isg', 30),
  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'facebook', '個人Facebook', 'https://www.facebook.com/ieyasu.ISG/', 40),
  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'line', 'LINE公式', 'https://line.me/R/ti/p/@415pwhlw', 50),
  ('fafc35f8-8a5b-457f-b63d-a4cc1421de53', 'website', '公式サイト', 'https://xn--n8ji5c1j.com/', 60),

  ('936cd874-ec02-4b48-b1aa-c6b50dad6bc5', 'instagram', '個人Instagram', 'https://www.instagram.com/yuusaku_isk911/', 10),
  ('936cd874-ec02-4b48-b1aa-c6b50dad6bc5', 'x', '個人X', 'https://x.com/yuusaku_isg11', 20),

  ('dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2', 'x', '個人X', 'https://x.com/Hidetoshi_yaima', 10),
  ('dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2', 'facebook', '後援会Facebook', 'https://www.facebook.com/uchihara.kouenkai2022/', 20),
  ('dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2', 'instagram', '会派Instagram', 'https://www.instagram.com/yugafu_kaiha/', 30),
  ('dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2', 'facebook', '会派Facebook', 'https://www.facebook.com/yugafu80s', 40),
  ('dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2', 'website', '公式サイト', 'https://uchihara.live/', 50),

  ('1672bf78-0505-4041-b301-75a22616edc4', 'instagram', '個人Instagram', 'https://www.instagram.com/minosoko_yoichi/', 10),
  ('1672bf78-0505-4041-b301-75a22616edc4', 'facebook', '個人Facebook', 'https://www.facebook.com/yoichi.minosoko/', 20),
  ('1672bf78-0505-4041-b301-75a22616edc4', 'threads', '個人Threads', 'https://www.threads.com/@minosoko_yoichi', 30),

  ('33422421-3897-4b09-81c2-8fb91bfdebfa', 'x', '個人X', 'https://x.com/miyaramisao', 10),

  ('2986e72e-ab8a-465f-b826-6118687ab673', 'instagram', '個人Instagram', 'https://www.instagram.com/gakiya__ryuji/', 10),
  ('2986e72e-ab8a-465f-b826-6118687ab673', 'threads', '個人Threads', 'https://www.threads.com/@gakiya__ryuji', 20),
  ('2986e72e-ab8a-465f-b826-6118687ab673', 'facebook', '個人Facebook', 'https://www.facebook.com/gakiyaryuji/', 30),

  ('141916de-d2b8-406d-9457-ad7057332ff1', 'instagram', '個人Instagram', 'https://www.instagram.com/eizotomoyose/', 10),

  ('2538eb08-aa41-41f0-8ec1-713ef7e26697', 'instagram', '個人Instagram', 'https://www.instagram.com/chiisana.kyojin_isg', 10),

  ('dfd899e1-26bf-4d16-b353-28a96a067a7b', 'x', '個人X', 'https://x.com/taira1970', 10),
  ('dfd899e1-26bf-4d16-b353-28a96a067a7b', 'instagram', '個人Instagram', 'https://www.instagram.com/tairanet/', 20),
  ('dfd899e1-26bf-4d16-b353-28a96a067a7b', 'threads', '個人Threads', 'https://www.threads.com/@tairanet', 30),
  ('dfd899e1-26bf-4d16-b353-28a96a067a7b', 'website', '公式サイト', 'https://www.komei.or.jp/km/ishigaki-taira-hideyuki/', 40),

  ('dec9dc59-70e9-4372-96bd-9b26150d0646', 'x', '個人X', 'https://x.com/nakamahitoshi', 10),
  ('dec9dc59-70e9-4372-96bd-9b26150d0646', 'instagram', '個人Instagram', 'https://www.instagram.com/nakama_hitoshi/', 20),
  ('dec9dc59-70e9-4372-96bd-9b26150d0646', 'facebook', '個人Facebook', 'https://www.facebook.com/nakamataduko/', 30),
  ('dec9dc59-70e9-4372-96bd-9b26150d0646', 'youtube', 'YouTube', 'https://www.youtube.com/@hitoshinakama7842', 40),

  ('9f6ee646-5814-482d-8f91-57293a905602', 'website', '公式サイト', 'https://www.jcp.or.jp/list/member/472077-01', 10);

commit;

select
  m.name,
  l.service,
  l.label,
  l.url,
  l.sort_order
from public.members m
join public.member_links l
  on l.member_id = m.id
where m.id in (
  'a30c4e98-585a-43bc-b8f7-1dddbe7426bf',
  'b4251917-a7f3-477f-be4d-abbca211cde7',
  '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b',
  '71dfb79c-1092-47ef-8bce-37c9a8ee3b06',
  '70fa0ad2-210f-40fa-9f34-0640839a40ff',
  'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2',
  '0374f5bb-bde4-4fc6-9cb0-598d4b58d37a',
  'fafc35f8-8a5b-457f-b63d-a4cc1421de53',
  '936cd874-ec02-4b48-b1aa-c6b50dad6bc5',
  'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2',
  '1672bf78-0505-4041-b301-75a22616edc4',
  '33422421-3897-4b09-81c2-8fb91bfdebfa',
  '2986e72e-ab8a-465f-b826-6118687ab673',
  '141916de-d2b8-406d-9457-ad7057332ff1',
  '2538eb08-aa41-41f0-8ec1-713ef7e26697',
  'dfd899e1-26bf-4d16-b353-28a96a067a7b',
  'dec9dc59-70e9-4372-96bd-9b26150d0646',
  '9f6ee646-5814-482d-8f91-57293a905602'
)
order by m.name, l.sort_order, l.service;
