# Topics 運用メモ

## 正本

- Topic 内容の正本は JSON
- 正本 JSON の配置場所: `docs/ishigaki_gikai_topics_dev_set/`
- GitHub を唯一の正本とし、`main` を安定版とする

## 基本フロー

1. JSON を編集または追加する
2. test 環境で dry-run を実行する
3. test 環境へ import する
4. test UI を確認する
5. prod 環境で dry-run を実行する
6. prod 環境へ import する
7. 本番 UI を確認する
8. 必要な場合のみ revalidate を実行する

## 実行コマンド

```bash
npm run db:topics:import:test -- --dry-run
npm run db:topics:import:test
npm run db:topics:import:prod -- --dry-run
npm run db:topics:import:prod
```

- importer: `scripts/import-topics-json.mjs`
- importer は既定で `docs/ishigaki_gikai_topics_dev_set/` 配下の `.topic.json` を対象にする

## ルール

- `test` と `prod` の env は厳密に分ける
- `fuzzy bill_name matching` は使わない
- `bill_name` は exact match 前提で扱う
- 先に `test`、確認後に `prod` へ進む
- UI 変更と Topic データ変更は PR を分ける
- データ変更だけの PR では UI を触らない
- UI 改修の PR では Topic JSON を混ぜない
- `main` を正本とし、ローカルや Vercel 本番を正本扱いしない

## 今回確認済み Topic

- `ishigaki-old-city-hall`
