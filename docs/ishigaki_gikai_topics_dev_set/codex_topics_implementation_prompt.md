# Codex / Claude Code にそのまま投げる実装プロンプト

以下をそのまま貼れるように整えた実装指示です。

---

あなたは既存の「みらい議会 石垣市議会版」コードベースに、Topics 機能を追加する実装担当です。

## 目的
- 議案をテーマ単位で束ねる `topics` 機能を追加したい
- Topic と Bill は多対多で紐づく
- normal / hard の2段階表示に対応したい
- まずは Topic ごとに「関連議案」を安全に管理できる状態を作る

## 前提
- 既存に `bills` テーブルがある
- bill の既存データは維持する
- 新規に `topics` と `topic_bills` を追加する
- `topic_bills` は `topics` と `bills` の中間テーブル
- 自動紐づけは安全優先にする

## 実装要件
1. Supabase migration を作成して `topics` と `topic_bills` を追加する
2. `topics` には以下を持たせる
   - slug
   - title
   - title_kana
   - status (`draft`, `review`, `published`, `archived`)
   - category
   - summary_normal
   - summary_hard
   - source_policy
   - published_at
   - created_at
   - updated_at
3. `topic_bills` には以下を持たせる
   - topic_id
   - bill_id
   - related_level (`high`, `medium`, `low`)
   - adoption_status (`adopt`, `hold`, `skip`)
   - reason_normal
   - reason_hard
   - source_url
   - source_type
   - is_primary
   - display_order
   - notes
   - created_at
   - updated_at
4. `topic_bills(topic_id, bill_id)` に unique 制約をつける
5. 一覧取得時は `adoption_status='adopt'` を基本表示とし、`is_primary desc, display_order asc` で並べる
6. Topic 詳細画面では `summary_normal` / `summary_hard` を難易度切替で表示できるようにする
7. Related bills でも `reason_normal` / `reason_hard` を難易度切替で出せるようにする
8. `bill_name` ベースで既存 `bills` との照合を行う seed / import 処理を作る
9. bill 一致ルールは完全一致優先とし、不一致はログに出して skip せず `hold` 扱い候補として残せる実装にする
10. UI 初期表示では `high` を優先し、`medium` は必要なら別表示、`low` は管理画面のみでもよい
11. TypeScript 型定義も追加する
12. 可能なら seed 用の JSON 読み込み処理も追加する

## 安全方針
- 曖昧一致で bill を自動採用しない
- 出典 URL がない関連データは topic_bills に入れない
- `low` 関連は初期 UI に出さない
- 管理用途と公開用途を分けて考える

## 実装してほしいもの
- migration
- 型定義
- seed / import 処理
- topic 詳細取得クエリ
- related bills 表示用データ整形
- 必要最小限の UI 接続

## 追加でほしいこと
- `ishigaki-old-city-hall` をサンプル topic として seed できるようにする
- コード内コメントは最小限でよい
- 既存 bills スキーマを壊さない
- 実装後に変更ファイル一覧と導入手順をまとめる

## Topics データの入力方針
- 入力は JSON を正本にする
- JSON の `topic_bill_candidates` から topic_bills を生成する
- `adoption_status='adopt'` のみ自動投入してよい
- `hold` / `skip` はレビュー対象として別ログに残す

必要なら `topic_bill_candidates` の JSON 例も追加してください。
