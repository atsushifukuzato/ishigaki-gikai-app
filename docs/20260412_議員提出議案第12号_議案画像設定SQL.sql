begin;

update public.bills
set
  thumbnail_url = '/img/bills/ishigaki-r8-3rd-giin12-school-lunch.png',
  share_thumbnail_url = '/img/bills/ishigaki-r8-3rd-giin12-school-lunch.png',
  updated_at = now()
where id = '9fd86780-cf7d-49b8-8b58-6151662e3b5b';

commit;

select
  id,
  name,
  thumbnail_url,
  share_thumbnail_url
from public.bills
where id = '9fd86780-cf7d-49b8-8b58-6151662e3b5b';
