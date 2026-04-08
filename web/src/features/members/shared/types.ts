export interface Member {
  name: string;
  name_kana: string | null;
  party: string | null;
  party_group: string | null;
  election_count: number | null;
  birth_date: string | null;
  address: string | null;
  image_url: string | null;
  facebook_url?: string | null;
  instagram_url?: string | null;
  threads_url?: string | null;
}
