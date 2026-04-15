-- 旧市役所庁舎跡地活用関連議案（Aフェーズ）を追加
-- 入力データ正本: ishigaki_old_city_hall_bills.json
-- related_topic_slugs: ishigaki-old-city-hall（Bフェーズで topic_bills に紐づける）

-- =====================================================
-- 1. 石垣市議会の定例会セッションを追加
-- =====================================================
INSERT INTO diet_sessions (name, slug, start_date, end_date, is_active)
VALUES
  ('令和6年第3回定例会', 'ishigaki-r6-dai3-teireikai', '2024-02-26', '2024-03-18', false),
  ('令和7年第2回定例会', 'ishigaki-r7-dai2-teireikai', '2025-02-24', '2025-03-17', false),
  ('令和8年第3回定例会', 'ishigaki-r8-dai3-teireikai', '2026-02-23', '2026-03-09', false)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- 2. 議案4件を追加（bill_name完全一致で重複チェック）
-- =====================================================
DO $$
DECLARE
  v_bill_id_1 uuid;
  v_bill_id_2 uuid;
  v_bill_id_3 uuid;
  v_bill_id_4 uuid;
  v_session_r6_3 uuid;
  v_session_r7_2 uuid;
  v_session_r8_3 uuid;
BEGIN
  -- セッションIDを取得
  SELECT id INTO v_session_r6_3 FROM diet_sessions WHERE slug = 'ishigaki-r6-dai3-teireikai';
  SELECT id INTO v_session_r7_2 FROM diet_sessions WHERE slug = 'ishigaki-r7-dai2-teireikai';
  SELECT id INTO v_session_r8_3 FROM diet_sessions WHERE slug = 'ishigaki-r8-dai3-teireikai';

  -- --------------------------------------------------
  -- 議案第4号 令和5年度石垣市一般会計補正予算（第9号）
  -- セッション: 令和6年第3回定例会 / 可決: 2024-03-04
  -- --------------------------------------------------
  IF NOT EXISTS (SELECT 1 FROM bills WHERE name = '議案第4号 令和5年度石垣市一般会計補正予算（第9号）') THEN
    INSERT INTO bills (
      name, document_type, originating_house, status,
      publish_status, is_featured, status_note,
      published_at, shugiin_url, diet_session_id
    ) VALUES (
      '議案第4号 令和5年度石垣市一般会計補正予算（第9号）',
      'bill', 'HR', 'enacted',
      'published', false, '会期中に可決',
      '2024-03-04',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html',
      v_session_r6_3
    )
    RETURNING id INTO v_bill_id_1;
  ELSE
    SELECT id INTO v_bill_id_1 FROM bills WHERE name = '議案第4号 令和5年度石垣市一般会計補正予算（第9号）';
  END IF;

  -- --------------------------------------------------
  -- 議案第11号 令和6年度石垣市一般会計予算
  -- セッション: 令和6年第3回定例会 / 可決: 2024-03-18
  -- --------------------------------------------------
  IF NOT EXISTS (SELECT 1 FROM bills WHERE name = '議案第11号 令和6年度石垣市一般会計予算') THEN
    INSERT INTO bills (
      name, document_type, originating_house, status,
      publish_status, is_featured, status_note,
      published_at, shugiin_url, diet_session_id
    ) VALUES (
      '議案第11号 令和6年度石垣市一般会計予算',
      'bill', 'HR', 'enacted',
      'published', false, '会期最終日に可決',
      '2024-03-18',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html',
      v_session_r6_3
    )
    RETURNING id INTO v_bill_id_2;
  ELSE
    SELECT id INTO v_bill_id_2 FROM bills WHERE name = '議案第11号 令和6年度石垣市一般会計予算';
  END IF;

  -- --------------------------------------------------
  -- 議案第12号 令和7年度石垣市一般会計予算
  -- セッション: 令和7年第2回定例会 / 可決: 2025-03-17
  -- --------------------------------------------------
  IF NOT EXISTS (SELECT 1 FROM bills WHERE name = '議案第12号 令和7年度石垣市一般会計予算') THEN
    INSERT INTO bills (
      name, document_type, originating_house, status,
      publish_status, is_featured, status_note,
      published_at, shugiin_url, diet_session_id
    ) VALUES (
      '議案第12号 令和7年度石垣市一般会計予算',
      'bill', 'HR', 'enacted',
      'published', false, '会期最終日に可決',
      '2025-03-17',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa7nen2025nen/10775.html',
      v_session_r7_2
    )
    RETURNING id INTO v_bill_id_3;
  ELSE
    SELECT id INTO v_bill_id_3 FROM bills WHERE name = '議案第12号 令和7年度石垣市一般会計予算';
  END IF;

  -- --------------------------------------------------
  -- 議案第5号 令和7年度石垣市一般会計補正予算（第12号）
  -- セッション: 令和8年第3回定例会 / 可決: 2026-03-09
  -- --------------------------------------------------
  IF NOT EXISTS (SELECT 1 FROM bills WHERE name = '議案第5号 令和7年度石垣市一般会計補正予算（第12号）') THEN
    INSERT INTO bills (
      name, document_type, originating_house, status,
      publish_status, is_featured, status_note,
      published_at, shugiin_url, diet_session_id
    ) VALUES (
      '議案第5号 令和7年度石垣市一般会計補正予算（第12号）',
      'bill', 'HR', 'enacted',
      'published', false, '会期中に可決',
      '2026-03-09',
      'https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa8nen2026nen/11780.html',
      v_session_r8_3
    )
    RETURNING id INTO v_bill_id_4;
  ELSE
    SELECT id INTO v_bill_id_4 FROM bills WHERE name = '議案第5号 令和7年度石垣市一般会計補正予算（第12号）';
  END IF;

  -- =====================================================
  -- 3. bill_contents を追加（normal / hard 各2件 × 4議案）
  --    source_urls はコンテンツ内のリンクとして保持
  -- =====================================================

  -- === 議案第4号 令和5年度石垣市一般会計補正予算（第9号）===

  IF v_bill_id_1 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_1 AND difficulty_level = 'normal'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_1,
      'normal',
      '令和5年度 補正予算（第9号）',
      '令和5年度の補正予算で、庁舎跡地の利活用事業などに関する経費が追加された。',
      $content$# 令和5年度石垣市一般会計補正予算（第9号）

## この議案のポイント

- 令和5年度（2023年度）の石垣市一般会計に追加の経費を計上した補正予算です。
- 「旧市役所庁舎等跡地利活用事業」として約1,017万円が盛り込まれています。
- 公募型プロポーザルで選ばれた事業者との基本協定締結や特別目的会社（SPC）の設立に時間がかかったため、一部の経費は翌年度（令和6年度）に繰り越されています。

## この議案が必要な理由

旧市役所庁舎の跡地を活用するためのプロセスが具体的に動き出した段階で、その準備・調整に必要な費用を確保するために提出されました。

## 結果

2024年3月4日に石垣市議会で可決されました。

## 注意事項

SPCの具体的な構成や契約条件などの詳細は、この議案資料からは確認できません。

## 出典

- [石垣市議会 令和6年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html)
- [議案第4号 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/33/R6dai3kaigiandai4gou.pdf)
$content$
    );
  END IF;

  IF v_bill_id_1 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_1 AND difficulty_level = 'hard'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_1,
      'hard',
      '議案第4号 令和5年度石垣市一般会計補正予算（第9号）',
      '令和5年度一般会計補正予算（第9号）を定める議案。旧市役所庁舎等跡地利活用事業として約1,017万円が計上され、SPC設立遅延により一部経費が繰越明許費となっている。',
      $content$# 議案第4号 令和5年度石垣市一般会計補正予算（第9号）

## 議案の概要

令和5年度一般会計補正予算（第9号）を定める議案である。公開資料では、「旧市役所庁舎等跡地利活用事業」として約1,017万円が計上されている。

## 主要事項

当該事業については、公募型プロポーザルによる事業者選定後、基本協定の締結や特別目的会社（SPC）の設立に時間を要したため、一部経費が翌年度に繰り越されていることが報告されている。これにより、庁舎跡地活用が具体的な事業化段階に進んでいることが確認できる。

## 議決結果

2024年3月4日　可決（令和6年第3回定例会 会期中）

## 不確実な点

SPCの具体的構成や契約条件などの詳細は、当該議案資料からは確認できない。

## 出典

- [石垣市議会 令和6年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html)
- [議案第4号 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/33/R6dai3kaigiandai4gou.pdf)
$content$
    );
  END IF;

  -- === 議案第11号 令和6年度石垣市一般会計予算 ===

  IF v_bill_id_2 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_2 AND difficulty_level = 'normal'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_2,
      'normal',
      '令和6年度 一般会計予算',
      '石垣市の令和6年度の予算を定める議案で、庁舎跡地の利活用事業などに関する経費が含まれている。',
      $content$# 令和6年度石垣市一般会計予算

## この議案のポイント

- 石垣市の令和6年度（2024年度）の年間予算を定める議案です。
- 「旧市役所庁舎等跡地利活用事業」として約1,284万円が計上されており、主に調査委託料とされています。
- 庁舎跡地の活用に向けた検討・調整が引き続き進められていることが確認できます。

## この議案が必要な理由

毎年度、市の行政サービスや各種事業を実施するために予算を議会で承認してもらう必要があります。令和6年度もその一環として提出されました。

## 結果

2024年3月18日に石垣市議会で可決されました（会期最終日）。

## 注意事項

旧市役所庁舎等跡地利活用事業の詳細な実施内容や事業範囲については、本予算書の記載だけでは具体的に確認できません。

## 出典

- [石垣市議会 令和6年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html)
- [令和6年度一般会計予算書 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/4/R6ippannyosansho.pdf)
$content$
    );
  END IF;

  IF v_bill_id_2 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_2 AND difficulty_level = 'hard'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_2,
      'hard',
      '議案第11号 令和6年度石垣市一般会計予算',
      '石垣市の令和6年度一般会計予算を定める議案。総務費中「旧市役所庁舎等跡地利活用事業」として約1,284万円（主に調査委託料）が計上され、跡地活用に向けた継続的な検討が確認できる。',
      $content$# 議案第11号 令和6年度石垣市一般会計予算

## 議案の概要

石垣市の令和6年度一般会計予算を定める議案である。公開されている予算書では、総務費の中に「旧市役所庁舎等跡地利活用事業」として約1,284万円が計上されており、主に調査委託料とされている。これにより、庁舎跡地の活用に向けた検討・調整が継続的に進められていることが確認できる。

## 主要事項

前年度（令和5年度補正予算第9号）での事業化段階に続き、令和6年度においても調査委託として予算が確保されている。これは事業の継続性を示している。

## 議決結果

2024年3月18日　可決（令和6年第3回定例会 会期最終日）

## 不確実な点

当該事業の具体的な実施内容や最終的な活用形態については、この議案単体の資料からは詳細までは確認できない。

## 出典

- [石垣市議会 令和6年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa6nen2024nen/9374.html)
- [令和6年度一般会計予算書 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/4/R6ippannyosansho.pdf)
$content$
    );
  END IF;

  -- === 議案第12号 令和7年度石垣市一般会計予算 ===

  IF v_bill_id_3 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_3 AND difficulty_level = 'normal'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_3,
      'normal',
      '令和7年度 一般会計予算',
      '石垣市の令和7年度の予算を定める議案で、庁舎跡地の利活用事業に関する経費が含まれている。',
      $content$# 令和7年度石垣市一般会計予算

## この議案のポイント

- 石垣市の令和7年度（2025年度）の年間予算を定める議案です。
- 「旧市役所庁舎等跡地利活用事業」として約1,144万円が計上されており、主に調査委託料として位置付けられています。
- 前年度に引き続き同一事業が予算計上されており、庁舎跡地活用が継続的な政策課題として進められています。

## この議案が必要な理由

令和6年度に続き、令和7年度においても庁舎跡地活用に関する調査・検討を継続するために必要な予算として提出されました。

## 結果

2025年3月17日に石垣市議会で可決されました（会期最終日）。

## 注意事項

具体的な施設計画や事業スキームの詳細については、この議案資料からは明確に確認できません。

## 出典

- [石垣市議会 令和7年第2回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa7nen2025nen/10775.html)
- [令和7年度一般会計予算書 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/4/R7ippanyosansho.pdf)
$content$
    );
  END IF;

  IF v_bill_id_3 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_3 AND difficulty_level = 'hard'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_3,
      'hard',
      '議案第12号 令和7年度石垣市一般会計予算',
      '石垣市の令和7年度一般会計予算を定める議案。「旧市役所庁舎等跡地利活用事業」として約1,144万円（主に調査委託料）が計上。前年度に続く継続計上により政策の継続性が確認できる。',
      $content$# 議案第12号 令和7年度石垣市一般会計予算

## 議案の概要

石垣市の令和7年度一般会計予算を定める議案である。公開されている予算書では、「旧市役所庁舎等跡地利活用事業」として約1,144万円が計上されており、主に調査委託料として位置付けられている。前年度に引き続き同一事業が予算計上されていることから、庁舎跡地活用が継続的な政策課題として進められていることが確認できる。

## 主要事項

令和6年度の約1,284万円から若干減少しているが、引き続き調査委託費として予算が確保されている。この継続計上パターンは、事業の進捗に合わせた段階的な予算配分を示している可能性がある。

## 議決結果

2025年3月17日　可決（令和7年第2回定例会 会期最終日）

## 不確実な点

庁舎跡地活用事業の具体的な整備内容やスケジュールについては、本予算書のみでは詳細が確認できない。

## 出典

- [石垣市議会 令和7年第2回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa7nen2025nen/10775.html)
- [令和7年度一般会計予算書 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/4/R7ippanyosansho.pdf)
$content$
    );
  END IF;

  -- === 議案第5号 令和7年度石垣市一般会計補正予算（第12号）===

  IF v_bill_id_4 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_4 AND difficulty_level = 'normal'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_4,
      'normal',
      '令和7年度 補正予算（第12号）',
      '令和7年度の補正予算で、庁舎跡地利活用事業の経費が翌年度へ繰り越された。',
      $content$# 令和7年度石垣市一般会計補正予算（第12号）

## この議案のポイント

- 令和7年度（2025年度）の石垣市一般会計の補正予算です。
- 「旧市役所庁舎等跡地利活用事業」として約1,045万円が「繰越明許費」として計上されています。
- 繰越明許費とは、年度内に事業が完了しなかったため、翌年度（令和8年度）に経費を引き継ぐことを意味します。
- 庁舎跡地活用事業が継続中であり、予算執行が調整されている状況です。

## この議案が必要な理由

事業が予定通り年度内に完了しなかったため、翌年度へ予算を引き継ぐ手続きとして提出されました。

## 結果

2026年3月9日に石垣市議会で可決されました。

## 注意事項

繰越の具体的な理由や事業進捗の詳細については、この議案資料のみでは十分に確認できません。

## 出典

- [石垣市議会 令和8年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa8nen2026nen/11780.html)
- [議案第5号 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/33/R8_dai3_giandai5.pdf)
$content$
    );
  END IF;

  IF v_bill_id_4 IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM bill_contents WHERE bill_id = v_bill_id_4 AND difficulty_level = 'hard'
  ) THEN
    INSERT INTO bill_contents (bill_id, difficulty_level, title, summary, content)
    VALUES (
      v_bill_id_4,
      'hard',
      '議案第5号 令和7年度石垣市一般会計補正予算（第12号）',
      '令和7年度一般会計補正予算（第12号）を定める議案。旧市役所庁舎等跡地利活用事業として約1,045万円が繰越明許費として計上。事業の年度内未完了により翌年度への引継ぎが確認できる。',
      $content$# 議案第5号 令和7年度石垣市一般会計補正予算（第12号）

## 議案の概要

令和7年度一般会計補正予算（第12号）を定める議案である。公開資料では、「旧市役所庁舎等跡地利活用事業」として約1,045万円が繰越明許費として計上されている。これは当該事業に関する経費が年度内に完了せず、翌年度へ引き継がれることを意味する。

## 主要事項

繰越明許費の計上は、事業進捗が当初の計画より遅延していることを示す一方、事業そのものは継続されていることも確認できる。令和6年度・令和7年度と連続して予算計上・繰越が行われており、複数年にわたる事業として進められている状況がわかる。

## 議決結果

2026年3月9日　可決（令和8年第3回定例会 会期中）

## 不確実な点

繰越の具体的な理由や事業進捗の詳細については、本議案資料のみでは十分に確認できない。

## 出典

- [石垣市議会 令和8年第3回定例会 議案一覧](https://www.city.ishigaki.okinawa.jp/soshiki/gikai/teireikairinnjikai/teisyutugianntokekka/reiwa8nen2026nen/11780.html)
- [議案第5号 PDF](https://www.city.ishigaki.okinawa.jp/material/files/group/33/R8_dai3_giandai5.pdf)
$content$
    );
  END IF;

END $$;
