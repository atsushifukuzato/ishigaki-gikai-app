# みらい議会 石垣市議会版：議案作成・実装ポリシー（完成版）

## 目的
本ドキュメントは、石垣市議会版における議案データの作成、整理、実装の共通ルールを定める。

このポリシーの目的は次の3点である。

1. 議案データの品質をそろえる  
2. ChatGPT 等で作成した下書きを、Codex / Claude Code で安全に実装できるようにする  
3. Topics や UI が再利用しやすい構造を保つ  

---

## 基本方針

### 1. 議案を基礎単位とする
- 議案は石垣市議会版における最小単位のデータである  
- Topics は議案を束ねる上位レイヤーとする  
- 議案単体で意味が通る状態を優先する  

---

### 2. 事実ベースを徹底する
- 公式議会資料・市資料を最優先する  
- 補助的に報道を参照してよい  
- 推測で補完しない  
- 不明な点は明示する  

---

### 3. 中立性を保つ
- 評価・意見・誘導的表現を入れない  
- 議案の内容と採決結果を分離する  
- 賛否の整理は別レイヤーで扱う  

---

### 4. normal / hard を分ける
- `normal`：一般市民向け、短くわかりやすく  
- `hard`：制度・金額・仕組み・論点を具体的に  
- 結論は変えず、情報の深さだけを変える  

---

### 5. 実装しやすい構造にする
- AIが作るのは「実装前の整理データ」  
- 最終反映は Codex / Claude Code が行う  
- 既存の DB / UI を優先する  

---

## データの位置づけ

### 正本の考え方
- 調査・整理データ（JSON / Markdown）を編集上の正本とする  
- Supabase 上のデータを公開運用上の正本とする  

### まとめ
- 編集正本：JSON / YAML / Markdown  
- 実装正本：Supabase  

---

## 議案データ構造

### ① 最小実装セット（これだけで投入可能）
- bill_name  
- bill_number  
- session_label  
- summary_normal  
- summary_hard  
- result_status  
- source_urls  

---

### ② 標準セット（基本ここまで作る）
- document_type  
- bill_type  
- source_label  
- result_date  

---

### ③ 拡張セット（必要に応じて）
- published_at  
- proposer  
- status_note  
- uncertainty_note  
- related_topic_slugs  
- notes  

---

## 各項目定義

### bill_name
- 正式名称をそのまま使用（改変禁止）

### bill_number
- 例：議案第11号

### session_label
- 例：令和6年第3回定例会

### document_type
- bill / report / approval / consent / speech

### bill_type
- 予算 / 条例 / 契約 / 請願 / 陳情 / その他

### summary_normal
- 1〜2文で簡潔に説明

### summary_hard
- 金額・制度・対象を具体的に記述

---

## 採決情報

### result_status
- 可決 / 否決  
- 採択 / 不採択  
- 継続審査 / 取り下げ / 不明  

### result_date
- 採決日（不明可）

### status_note
- 補足情報

---

## published_at
優先順位：
1. 議案提出日  
2. 資料公開日  
3. 不明  

---

## source関連

### source_label
例：石垣市議会資料

### source_urls
- 配列で保持  
- 公式資料を最低1件含める  

---

## 不明情報の扱い
- 推測しない  
- 不明は明記  

---

## 一致ルール（重要）

### bill_name 照合
- 完全一致優先  
- 不一致は自動採用しない  
- 類似一致はログのみ  

---

## データ構造原則
- 1議案 = 1レコード  

---

## Topicsとの関係
- 議案が先  
- Topicsは後  

---

## 運用フロー
1. 収集  
2. 整理  
3. 要約  
4. 不明整理  
5. Topics検討  
6. 実装  
7. 確認  

---

## ChatGPT依頼ルール
- 中立  
- 推測しない  
- normal / hard 分離  

---

## Codex依頼ルール
- 既存構造に合わせる  
- UIを壊さない  

---

## NG例
- 推測  
- コピペ  
- 要約未分離  

---

## まとめ
議案は最小単位であり、

- 正確  
- 構造化  
- 再利用可能  

が重要。

---

## 一言
「まず1件を完成させる」
