update public.members
set
  twitter_url = 'https://x.com/Hidetoshi_yaima',
  facebook_url = 'https://www.facebook.com/hidetoshi.uchihara'
where id = 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2';

select
  name,
  twitter_url,
  facebook_url
from public.members
where id = 'dddcef9f-e32a-4ccc-a2bf-8c80e7080aa2';
