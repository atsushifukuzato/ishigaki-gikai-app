update public.members
set
  instagram_url = 'https://www.instagram.com/shirohanatani',
  threads_url = 'https://www.threads.com/@shirohanatani',
  twitter_url = 'https://x.com/shiro_hanatani',
  facebook_url = 'https://www.facebook.com/shiro.hanatani'
where id = 'a30c4e98-585a-43bc-b8f7-1dddbe7426bf';

update public.members
set
  instagram_url = 'https://www.instagram.com/natsuyo4388',
  threads_url = 'https://www.threads.com/@natsuyo4388'
where id = 'b4251917-a7f3-477f-be4d-abbca211cde7';

update public.members
set
  instagram_url = 'https://www.instagram.com/takara_munenori/',
  threads_url = 'https://www.threads.com/@takara_munenori',
  twitter_url = 'https://x.com/takara_munenori',
  facebook_url = 'https://www.facebook.com/TakaraMunenori'
where id = '7fe932ed-df1e-44aa-b5cc-f0a2cc6f713b';

update public.members
set
  instagram_url = 'https://www.instagram.com/konomi4649/'
where id = '71dfb79c-1092-47ef-8bce-37c9a8ee3b06';

update public.members
set
  instagram_url = 'https://www.instagram.com/yuki_shinzato_ishigakijima/',
  facebook_url = 'https://www.facebook.com/yuuki.shinzato.9'
where id = '70fa0ad2-210f-40fa-9f34-0640839a40ff';

update public.members
set
  instagram_url = 'https://www.instagram.com/nakaminetadashi/',
  threads_url = 'https://www.threads.com/@nakaminetadashi',
  facebook_url = 'https://www.facebook.com/tadashi.nakamine'
where id = 'c3cc242e-d8a7-4a1a-8740-1ff522ea43a2';

update public.members
set
  instagram_url = 'https://www.instagram.com/tatsuyaishigakicity/',
  threads_url = 'https://www.threads.com/@tatsuyaishigakicity',
  facebook_url = 'https://www.facebook.com/tatsuya.ishigaki.9887/'
where id = '0374f5bb-bde4-4fc6-9cb0-598d4b58d37a';

update public.members
set
  instagram_url = 'https://www.instagram.com/ieyasu_isg/',
  threads_url = 'https://www.threads.com/@ieyasu_isg',
  twitter_url = 'https://x.com/ieyasu_isg',
  facebook_url = 'https://www.facebook.com/ieyasu.ISG/'
where id = 'fafc35f8-8a5b-457f-b63d-a4cc1421de53';

update public.members
set
  instagram_url = 'https://www.instagram.com/yuusaku_isk911/',
  twitter_url = 'https://x.com/yuusaku_isg11'
where id = '936cd874-ec02-4b48-b1aa-c6b50dad6bc5';

update public.members
set
  twitter_url = 'https://x.com/Hidetoshi_yaima'
where id = 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2';

update public.members
set
  instagram_url = 'https://www.instagram.com/minosoko_yoichi/',
  threads_url = 'https://www.threads.com/@minosoko_yoichi',
  facebook_url = 'https://www.facebook.com/yoichi.minosoko/'
where id = '1672bf78-0505-4041-b301-75a22616edc4';

update public.members
set
  twitter_url = 'https://x.com/miyaramisao'
where id = '33422421-3897-4b09-81c2-8fb91bfdebfa';

update public.members
set
  instagram_url = 'https://www.instagram.com/gakiya__ryuji/',
  threads_url = 'https://www.threads.com/@gakiya__ryuji'
where id = '2986e72e-ab8a-465f-b826-6118687ab673';

update public.members
set
  instagram_url = 'https://www.instagram.com/eizotomoyose/'
where id = '141916de-d2b8-406d-9457-ad7057332ff1';

update public.members
set
  instagram_url = 'https://www.instagram.com/chiisana.kyojin_isg'
where id = '2538eb08-aa41-41f0-8ec1-713ef7e26697';

update public.members
set
  instagram_url = 'https://www.instagram.com/tairanet/',
  threads_url = 'https://www.threads.com/@tairanet',
  twitter_url = 'https://x.com/taira1970'
where id = 'dfd899e1-26bf-4d16-b353-28a96a067a7b';

update public.members
set
  instagram_url = 'https://www.instagram.com/nakama_hitoshi/',
  twitter_url = 'https://x.com/nakamahitoshi',
  facebook_url = 'https://www.facebook.com/nakamataduko/'
where id = 'dec9dc59-70e9-4372-96bd-9b26150d0646';

select
  name,
  twitter_url,
  facebook_url,
  instagram_url,
  threads_url
from public.members
where id in (
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
  'dec9dc59-70e9-4372-96bd-9b26150d0646'
)
order by name_kana nulls last, name;
