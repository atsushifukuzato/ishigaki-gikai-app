# みらい議会 石垣市議会版 開発用セット

このセットには以下が含まれます。

1. `topics_schema_guide.md`
   - Topics 用 JSON スキーマの考え方

2. `topic.schema.json`
   - Topics データの JSON Schema 本体

3. `topic_bills_schema_guide.md`
   - Supabase テーブル設計の方針

4. `topic_bills_supabase.sql`
   - Topics / topic_bills の作成 SQL

5. `codex_topics_implementation_prompt.md`
   - Codex / Claude Code にそのまま貼れる実装プロンプト

## 推奨順
1. JSON Schema を確認
2. SQL をレビュー
3. 実装プロンプトを Codex / Claude Code に投入
4. topic JSON を作成して seed に使う

## JSON 正本から DB へ反映する手順
1. `*.topic.json` をこのディレクトリで編集する
2. `.env.test` と `.env.prod` を用意する
3. まずテスト環境で `pnpm db:topics:import:test --dry-run <topic-json-path>` を実行する
4. 問題なければ `pnpm db:topics:import:test <topic-json-path>` を実行する
5. テスト環境の画面で確認後、本番環境で `pnpm db:topics:import:prod --dry-run <topic-json-path>` を実行する
6. 問題なければ `pnpm db:topics:import:prod <topic-json-path>` を実行する
7. 反映後、必要に応じて `pnpm revalidate:test --url <test-url> topics` または `pnpm revalidate:prod --url <prod-url> topics` を実行する

### 環境ファイル例
- `.env.test`
  - `SUPABASE_URL=https://zllffpfubgwysodynseo.supabase.co`
  - `SUPABASE_SERVICE_ROLE_KEY=...`
  - `REVALIDATE_SECRET=...`
- `.env.prod`
  - `SUPABASE_URL=https://sjjesaheibvpteoytbpy.supabase.co`
  - `SUPABASE_SERVICE_ROLE_KEY=...`
  - `REVALIDATE_SECRET=...`

### 推奨運用
1. JSON を編集する
2. `pnpm db:topics:import:test --dry-run docs/ishigaki_gikai_topics_dev_set/old_city_hall.topic.json`
3. `pnpm db:topics:import:test docs/ishigaki_gikai_topics_dev_set/old_city_hall.topic.json`
4. `pnpm revalidate:test --url <test-url> topics`
5. テスト画面を確認する
6. `pnpm db:topics:import:prod --dry-run docs/ishigaki_gikai_topics_dev_set/old_city_hall.topic.json`
7. `pnpm db:topics:import:prod docs/ishigaki_gikai_topics_dev_set/old_city_hall.topic.json`
8. `pnpm revalidate:prod --url https://ishigaki-gikai-app-web.vercel.app topics`

### 補足
- 現行 UI は DB (`topics`, `topic_updates`, `topic_bills`) を読む
- JSON は正本、import スクリプトは DB 反映レイヤーとして扱う
- `topic_bill_candidates` は `bill_name` 完全一致でのみ `topic_bills` に反映される
- `adoption_status = "adopt"` のみ自動反映対象
- `db:topics:import` と `revalidate` は後方互換のため残しているが、今後は `:test` / `:prod` の利用を推奨する
