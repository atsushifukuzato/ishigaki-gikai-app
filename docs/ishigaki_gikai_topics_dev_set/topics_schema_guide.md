# Topics用 JSONスキーマ定義

## 目的
このスキーマは、みらい議会 石垣市議会版で Topics を構造化して管理するための共通ルールです。

## 設計意図
- Topic 自体の基本情報を持つ
- normal / hard の2段階表示に対応する
- topic と bill の候補関係を機械的に扱える
- Codex / Claude Code / seed script / 手作業レビューの共通フォーマットにする

## 必須キー
- `topic_slug`
- `topic_title`
- `topic_title_kana`
- `topic_status`
- `related_bills_summary_normal`
- `related_bills_summary_hard`
- `topic_bill_candidates`

## topic_bill_candidates の必須キー
- `bill_name`
- `related_level`
- `adoption_status`
- `reason_normal`
- `reason_hard`
- `source_url`

## adoption_status の意味
- `adopt`: topic_bills に紐づける前提
- `hold`: 関連はあるが、手動レビュー後に判断
- `skip`: topic_bills には紐づけない

## related_level の意味
- `high`: 議案名・内容にテーマが明示される
- `medium`: 文脈上関連するが、直接性は一段弱い
- `low`: 関連可能性はあるが、断定しない

## 使い方
1. 調査結果をこの JSON 形式に落とす
2. `bill_name` で既存 `bills` テーブルと照合する
3. `adoption_status=adopt` かつ `related_level=high` を優先して topic_bills に投入する
4. `hold` はレビュー待ちリストに回す
5. `skip` は topic 候補メモとして保持してもよいが、通常は紐づけない
