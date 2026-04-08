create table if not exists public.members (
  id uuid primary key,
  name text not null,
  name_kana text,
  party text,
  image_url text,
  website_url text,
  twitter_url text,
  created_at timestamptz not null default now(),
  birth_date date,
  address text,
  election_count integer,
  party_group text
);
