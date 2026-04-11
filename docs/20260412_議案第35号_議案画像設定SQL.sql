begin;

update public.bills
set
  thumbnail_url = 'https://ishigaki-gikai-app-web.vercel.app/img/bills/ishigaki-r8-3rd-35-lodging-tax.png',
  share_thumbnail_url = 'https://ishigaki-gikai-app-web.vercel.app/img/bills/ishigaki-r8-3rd-35-lodging-tax.png',
  updated_at = now()
where name = '議案第35号 石垣市宿泊税条例の一部を改正する条例';

commit;

select
  name,
  thumbnail_url,
  share_thumbnail_url
from public.bills
where name = '議案第35号 石垣市宿泊税条例の一部を改正する条例';
