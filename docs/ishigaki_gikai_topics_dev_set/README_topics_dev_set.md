# Topics 運用メモ

- Topic 内容の正本は `docs/ishigaki_gikai_topics_dev_set/*.topic.json` を想定します。
- `topic.schema.json` は Topic JSON の共通フォーマットを定義するためのスキーマです。
- `scripts/import-topics-json.mjs` は JSON 正本を `topics` / `topic_updates` / `topic_bills` に反映する import レイヤーです。
- `topic_bill_candidates.bill_name` は `bills.name` と完全一致で照合します。fuzzy matching は使いません。
- `db:topics:import:test` と `db:topics:import:prod` で test / prod Supabase を分離して使います。
- この変更では DB反映・migration実行・revalidate実行は行いません。実行は次フェーズで扱います。
