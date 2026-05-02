update public.topics
set
  current_status_label = '方針整理を継続確認',
  current_status_note = '旧市役所跡地の活用方針は、複合施設案を含めて整理・検討が続いている段階です。関連議案や予算審議、市の説明内容を継続して追う必要があります。',
  current_status_updated_at = '2026-04-15T11:30:00+09:00'::timestamptz
where slug = 'ishigaki-old-city-hall';

insert into public.topic_updates (
  topic_id,
  kind,
  title,
  summary,
  content,
  status_label,
  source_label,
  published_at
)
select
  t.id,
  updates.kind,
  updates.title,
  updates.summary,
  updates.content,
  updates.status_label,
  updates.source_label,
  updates.published_at
from public.topics t
cross join (
  values
    (
      'progress',
      '活用テーマとして継続的に確認する対象に位置づけ',
      '跡地活用は単発の議案では追い切れないため、議会動向と事業進捗をまとめて確認するテーマとして整理します。',
      E'## この段階で見ること\n\n- 市の活用方針がどう整理されているか\n- 関連予算や関連議案がどの時点で出てくるか\n- 事業の説明内容や計画の変化があるか',
      '継続確認',
      'Topics初期データ',
      '2026-04-15T11:10:00+09:00'::timestamptz
    ),
    (
      'council',
      '議会での論点は関連議案と説明内容を横断して確認',
      'このテーマでは、議案の可否だけでなく、委員会や本会議でどのような説明や論点整理が行われているかも重要になります。',
      E'## 見方\n\n- 提出された議案そのもの\n- 議案に付随する説明や質疑\n- 計画の前提条件や進め方の変化',
      '議会動向を確認中',
      'Topics初期データ',
      '2026-04-15T11:15:00+09:00'::timestamptz
    ),
    (
      'news',
      '市の方針や外部公表があれば同じタイムラインで確認',
      '議会外で公表された方針や進捗も、テーマ全体の理解に必要な情報として同じページに蓄積していきます。',
      E'## この更新の意味\n\n議案だけでは現在地が見えにくいテーマでは、行政発表や事業進捗も合わせて時系列で確認できるようにします。',
      '関連情報も確認対象',
      'Topics初期データ',
      '2026-04-15T11:20:00+09:00'::timestamptz
    ),
    (
      'decision',
      '現時点では方針整理を追う段階として表示',
      '現段階では最終的な決定事項を示すのではなく、何が検討中で、どの論点が残っているかを中立的に把握することを重視します。',
      E'## 現在地\n\n- 最終決定そのものを示す段階ではない\n- 方針整理や議会での議論の積み上がりを見る段階\n- 次の関連議案や市の公表内容が重要になる',
      '方針整理を継続確認',
      'Topics初期データ',
      '2026-04-15T11:30:00+09:00'::timestamptz
    )
) as updates(kind, title, summary, content, status_label, source_label, published_at)
where t.slug = 'ishigaki-old-city-hall'
  and not exists (
    select 1
    from public.topic_updates tu
    where tu.topic_id = t.id
      and tu.title = updates.title
  );
