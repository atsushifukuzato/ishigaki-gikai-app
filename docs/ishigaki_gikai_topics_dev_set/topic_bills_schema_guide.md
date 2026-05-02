# topic_billsテーブル設計（Supabase用）

## 目的
Topics と Bills は多対多になりやすいため、中間テーブル `topic_bills` を置いて関連を管理します。

## 前提
- 既存に `bills` テーブルがある
- 新規に `topics` テーブルを作る
- topic と bill の関係ごとに、関連度・説明・表示優先度を持たせる

## 推奨テーブル構成

### topics
- `id` uuid primary key
- `slug` text unique not null
- `title` text not null
- `title_kana` text
- `status` text not null default 'draft'
- `category` text
- `summary_normal` text not null
- `summary_hard` text not null
- `source_policy` text
- `published_at` timestamptz
- `created_at` timestamptz
- `updated_at` timestamptz

### topic_bills
- `id` uuid primary key
- `topic_id` uuid not null references topics(id)
- `bill_id` uuid not null references bills(id)
- `related_level` text not null
- `adoption_status` text not null default 'adopt'
- `reason_normal` text not null
- `reason_hard` text not null
- `source_url` text not null
- `source_type` text
- `is_primary` boolean not null default false
- `display_order` integer not null default 100
- `notes` text
- `created_at` timestamptz
- `updated_at` timestamptz

## 制約の考え方
- `topics.slug` は一意
- `topic_bills(topic_id, bill_id)` は一意
- `related_level` は `high | medium | low`
- `adoption_status` は `adopt | hold | skip`

## UI運用の考え方
- 初期表示は `adoption_status='adopt'` を対象
- さらに `related_level='high'` を優先表示
- `is_primary=true` を topic の代表議案として使う
- `hold` は管理画面のみ表示でもよい

## 実装メモ
- `bills` との照合は bill_name の完全一致を優先
- 完全一致しない場合はログに残し、人手確認
- 自動処理で曖昧一致を採用しない
