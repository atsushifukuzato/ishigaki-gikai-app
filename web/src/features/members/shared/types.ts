export interface MemberLink {
  id: string;
  member_id: string;
  service: string;
  label: string | null;
  url: string;
  sort_order: number;
}

export interface Member {
  id: string;
  name: string;
  name_kana: string | null;
  party: string | null;
  party_group: string | null;
  election_count: number | null;
  birth_date: string | null;
  address: string | null;
  image_url: string | null;
  website_url?: string | null;
  twitter_url?: string | null;
  facebook_url?: string | null;
  instagram_url?: string | null;
  threads_url?: string | null;
  youtube_url?: string | null;
  line_url?: string | null;
  links?: MemberLink[];
}
