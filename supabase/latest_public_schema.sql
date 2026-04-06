


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."bill_publish_status" AS ENUM (
    'draft',
    'published',
    'coming_soon'
);


ALTER TYPE "public"."bill_publish_status" OWNER TO "postgres";


COMMENT ON TYPE "public"."bill_publish_status" IS 'ENUM type for bill publication status';



CREATE TYPE "public"."bill_status_enum" AS ENUM (
    'introduced',
    'in_originating_house',
    'in_receiving_house',
    'enacted',
    'rejected',
    'preparing'
);


ALTER TYPE "public"."bill_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."chat_role_enum" AS ENUM (
    'user',
    'system',
    'assistant'
);


ALTER TYPE "public"."chat_role_enum" OWNER TO "postgres";


CREATE TYPE "public"."difficulty_level_enum" AS ENUM (
    'normal',
    'hard'
);


ALTER TYPE "public"."difficulty_level_enum" OWNER TO "postgres";


CREATE TYPE "public"."document_type_enum" AS ENUM (
    'bill',
    'speech',
    'report',
    'consent',
    'approval'
);


ALTER TYPE "public"."document_type_enum" OWNER TO "postgres";


CREATE TYPE "public"."house_enum" AS ENUM (
    'HR',
    'HC'
);


ALTER TYPE "public"."house_enum" OWNER TO "postgres";


CREATE TYPE "public"."interview_config_status_enum" AS ENUM (
    'public',
    'closed'
);


ALTER TYPE "public"."interview_config_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."interview_feedback_tag_enum" AS ENUM (
    'irrelevant_questions',
    'not_aligned',
    'misunderstood',
    'too_many_questions',
    'other'
);


ALTER TYPE "public"."interview_feedback_tag_enum" OWNER TO "postgres";


CREATE TYPE "public"."interview_mode_enum" AS ENUM (
    'loop',
    'bulk'
);


ALTER TYPE "public"."interview_mode_enum" OWNER TO "postgres";


CREATE TYPE "public"."interview_report_role_enum" AS ENUM (
    'subject_expert',
    'work_related',
    'daily_life_affected',
    'general_citizen'
);


ALTER TYPE "public"."interview_report_role_enum" OWNER TO "postgres";


COMMENT ON TYPE "public"."interview_report_role_enum" IS 'インタビュー対象者の役割・属性を表すENUM型';



CREATE TYPE "public"."interview_role_enum" AS ENUM (
    'assistant',
    'user'
);


ALTER TYPE "public"."interview_role_enum" OWNER TO "postgres";


CREATE TYPE "public"."moderation_status_enum" AS ENUM (
    'ok',
    'warning',
    'ng'
);


ALTER TYPE "public"."moderation_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."stance_type_enum" AS ENUM (
    'for',
    'against',
    'neutral',
    'conditional_for',
    'conditional_against',
    'considering',
    'continued_deliberation'
);


ALTER TYPE "public"."stance_type_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bulk_publish_reports"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) RETURNS bigint
    LANGUAGE "sql"
    AS $$
  with updated as (
    update interview_report r
    set is_public_by_admin = true
    from interview_sessions s
    where s.id = r.interview_session_id
      and s.interview_config_id = p_config_id
      and r.is_public_by_user = true
      and r.is_public_by_admin = false
      and r.moderation_score is not null
      and r.moderation_score <= p_max_moderation_score
      and r.total_content_richness is not null
      and r.total_content_richness >= p_min_content_richness
    returning r.id
  )
  select count(*) from updated;
$$;


ALTER FUNCTION "public"."bulk_publish_reports"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_bulk_publish_targets"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) RETURNS bigint
    LANGUAGE "sql" STABLE
    AS $$
  select count(*)
  from interview_report r
  join interview_sessions s on s.id = r.interview_session_id
  where s.interview_config_id = p_config_id
    and r.is_public_by_user = true
    and r.is_public_by_admin = false
    and r.moderation_score is not null
    and r.moderation_score <= p_max_moderation_score
    and r.total_content_richness is not null
    and r.total_content_richness >= p_min_content_richness;
$$;


ALTER FUNCTION "public"."count_bulk_publish_targets"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_public_reports_by_stance"("p_bill_id" "uuid") RETURNS TABLE("stance" "text", "count" bigint)
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.stance::TEXT AS stance,
    COUNT(*) AS count
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
  GROUP BY ir.stance;
END;
$$;


ALTER FUNCTION "public"."count_public_reports_by_stance"("p_bill_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_reactions_by_report_ids"("report_ids" "uuid"[]) RETURNS TABLE("interview_report_id" "uuid", "reaction_type" "text", "cnt" bigint)
    LANGUAGE "sql" STABLE
    AS $$
  select
    r.interview_report_id,
    r.reaction_type,
    count(*) as cnt
  from report_reactions r
  where r.interview_report_id = any(report_ids)
  group by r.interview_report_id, r.reaction_type;
$$;


ALTER FUNCTION "public"."count_reactions_by_report_ids"("report_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_sessions_by_config_ids"("p_config_ids" "uuid"[]) RETURNS TABLE("interview_config_id" "uuid", "session_count" bigint)
    LANGUAGE "sql" STABLE
    AS $$
  select
    s.interview_config_id,
    count(s.id) as session_count
  from interview_sessions s
  where s.interview_config_id = any(p_config_ids)
  group by s.interview_config_id;
$$;


ALTER FUNCTION "public"."count_sessions_by_config_ids"("p_config_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_public_reports_by_bill_id_ordered_by_reactions"("p_bill_id" "uuid", "p_limit" integer DEFAULT 1000, "p_offset" integer DEFAULT 0, "p_stance" "text" DEFAULT NULL::"text", "p_sort_order" "text" DEFAULT 'recommended'::"text") RETURNS TABLE("id" "uuid", "stance" "public"."stance_type_enum", "role" "public"."interview_report_role_enum", "role_title" "text", "summary" "text", "total_content_richness" integer, "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.id,
    ir.stance,
    ir.role,
    ir.role_title,
    ir.summary,
    ir.total_content_richness,
    ir.created_at
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*) AS helpful_count
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) rc ON rc.interview_report_id = ir.id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
    AND (p_stance IS NULL OR ir.stance::TEXT = p_stance)
  ORDER BY
    CASE WHEN p_sort_order = 'newest' THEN NULL
         ELSE (COALESCE(rc.helpful_count, 0) + COALESCE(ir.total_content_richness, 0))
    END DESC NULLS LAST,
    ir.created_at DESC,
    ir.id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."find_public_reports_by_bill_id_ordered_by_reactions"("p_bill_id" "uuid", "p_limit" integer, "p_offset" integer, "p_stance" "text", "p_sort_order" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_sessions_ordered_by_helpful_count"("p_config_id" "uuid", "p_ascending" boolean DEFAULT false, "p_offset" integer DEFAULT 0, "p_limit" integer DEFAULT 30, "p_status" "text" DEFAULT NULL::"text", "p_visibility" "text" DEFAULT NULL::"text", "p_stance" "text" DEFAULT NULL::"text", "p_role" "text" DEFAULT NULL::"text") RETURNS TABLE("session_id" "uuid")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*)::BIGINT AS cnt
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) hc ON hc.interview_report_id = r.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(hc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(hc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."find_sessions_ordered_by_helpful_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_sessions_ordered_by_message_count"("p_config_id" "uuid", "p_ascending" boolean DEFAULT false, "p_offset" integer DEFAULT 0, "p_limit" integer DEFAULT 30, "p_status" "text" DEFAULT NULL::"text", "p_visibility" "text" DEFAULT NULL::"text", "p_stance" "text" DEFAULT NULL::"text", "p_role" "text" DEFAULT NULL::"text") RETURNS TABLE("session_id" "uuid")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*)::BIGINT AS cnt
    FROM interview_messages im
    INNER JOIN interview_sessions iss
      ON iss.id = im.interview_session_id
    WHERE iss.interview_config_id = p_config_id
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(mc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(mc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."find_sessions_ordered_by_message_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_sessions_ordered_by_moderation_score"("p_config_id" "uuid", "p_ascending" boolean DEFAULT false, "p_offset" integer DEFAULT 0, "p_limit" integer DEFAULT 30, "p_status" "text" DEFAULT NULL::"text", "p_visibility" "text" DEFAULT NULL::"text", "p_stance" "text" DEFAULT NULL::"text", "p_role" "text" DEFAULT NULL::"text") RETURNS TABLE("session_id" "uuid")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.moderation_score END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.moderation_score END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."find_sessions_ordered_by_moderation_score"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_sessions_ordered_by_total_content_richness"("p_config_id" "uuid", "p_ascending" boolean DEFAULT false, "p_offset" integer DEFAULT 0, "p_limit" integer DEFAULT 30, "p_status" "text" DEFAULT NULL::"text", "p_visibility" "text" DEFAULT NULL::"text", "p_stance" "text" DEFAULT NULL::"text", "p_role" "text" DEFAULT NULL::"text") RETURNS TABLE("session_id" "uuid")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.total_content_richness END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.total_content_richness END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$;


ALTER FUNCTION "public"."find_sessions_ordered_by_total_content_richness"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_users"() RETURNS TABLE("id" "uuid", "email" "text", "created_at" timestamp with time zone, "last_sign_in_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  SELECT u.id, u.email, u.created_at, u.last_sign_in_at
  FROM auth.users u
  WHERE u.raw_app_meta_data->'roles' ? 'admin'
  ORDER BY u.created_at DESC;
$$;


ALTER FUNCTION "public"."get_admin_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_interview_message_counts"("session_ids" "uuid"[]) RETURNS TABLE("interview_session_id" "uuid", "message_count" bigint)
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    im.interview_session_id,
    COUNT(*)::BIGINT AS message_count
  FROM interview_messages im
  WHERE im.interview_session_id = ANY(session_ids)
  GROUP BY im.interview_session_id;
END;
$$;


ALTER FUNCTION "public"."get_interview_message_counts"("session_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_interview_statistics"("p_config_id" "uuid") RETURNS TABLE("total_sessions" bigint, "completed_sessions" bigint, "avg_rating" numeric, "stance_for_count" bigint, "stance_against_count" bigint, "stance_neutral_count" bigint, "avg_total_content_richness" numeric, "role_subject_expert_count" bigint, "role_work_related_count" bigint, "role_daily_life_affected_count" bigint, "role_general_citizen_count" bigint, "avg_message_count" numeric, "median_duration_seconds" numeric, "public_by_user_count" bigint, "feedback_irrelevant_questions" bigint, "feedback_not_aligned" bigint, "feedback_misunderstood" bigint, "feedback_too_many_questions" bigint, "feedback_other" bigint, "total_cost_usd" numeric, "avg_cost_usd" numeric)
    LANGUAGE "plpgsql" STABLE
    AS $$
begin
  return query
  select
    count(s.id) as total_sessions,
    count(s.completed_at) as completed_sessions,
    round(avg(s.rating)::numeric, 2) as avg_rating,
    count(case when r.stance = 'for' then 1 end) as stance_for_count,
    count(case when r.stance = 'against' then 1 end) as stance_against_count,
    count(case when r.stance = 'neutral' then 1 end) as stance_neutral_count,
    round(avg(r.total_content_richness)::numeric, 1) as avg_total_content_richness,
    count(case when r.role = 'subject_expert' then 1 end) as role_subject_expert_count,
    count(case when r.role = 'work_related' then 1 end) as role_work_related_count,
    count(case when r.role = 'daily_life_affected' then 1 end) as role_daily_life_affected_count,
    count(case when r.role = 'general_citizen' then 1 end) as role_general_citizen_count,
    round(avg(coalesce(mc.message_count, 0))::numeric, 1) as avg_message_count,
    round(
      (select percentile_cont(0.5) within group (
        order by extract(epoch from (sub.completed_at - sub.started_at))
      )
      from interview_sessions sub
      where sub.interview_config_id = p_config_id
        and sub.completed_at is not null
      )::numeric, 0
    ) as median_duration_seconds,
    count(case when r.is_public_by_user = true then 1 end) as public_by_user_count,
    -- フィードバックタグ集計
    coalesce(max(fc.feedback_irrelevant_questions), 0) as feedback_irrelevant_questions,
    coalesce(max(fc.feedback_not_aligned), 0) as feedback_not_aligned,
    coalesce(max(fc.feedback_misunderstood), 0) as feedback_misunderstood,
    coalesce(max(fc.feedback_too_many_questions), 0) as feedback_too_many_questions,
    coalesce(max(fc.feedback_other), 0) as feedback_other,
    -- コスト集計
    coalesce(max(cc.total_cost), 0)::numeric as total_cost_usd,
    case
      when count(s.id) > 0 then round(coalesce(max(cc.total_cost), 0)::numeric / count(s.id), 6)
      else 0::numeric
    end as avg_cost_usd
  from interview_sessions s
  left join interview_report r on r.interview_session_id = s.id
  left join (
    select im.interview_session_id, count(*) as message_count
    from interview_messages im
    group by im.interview_session_id
  ) mc on mc.interview_session_id = s.id
  left join (
    select
      count(*) filter (where f.tag = 'irrelevant_questions') as feedback_irrelevant_questions,
      count(*) filter (where f.tag = 'not_aligned') as feedback_not_aligned,
      count(*) filter (where f.tag = 'misunderstood') as feedback_misunderstood,
      count(*) filter (where f.tag = 'too_many_questions') as feedback_too_many_questions,
      count(*) filter (where f.tag = 'other') as feedback_other
    from interview_rating_feedbacks f
    join interview_sessions fs on fs.id = f.interview_session_id
    where fs.interview_config_id = p_config_id
  ) fc on true
  left join (
    select sum(c.cost_usd) as total_cost
    from chat_usage_events c
    join interview_sessions cs on cs.id::text = c.session_id
    where cs.interview_config_id = p_config_id
  ) cc on true
  where s.interview_config_id = p_config_id;
end;
$$;


ALTER FUNCTION "public"."get_interview_statistics"("p_config_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN (
    EXISTS (
      SELECT 1
      FROM auth.users
      WHERE id = auth.uid()
      AND raw_app_meta_data->>'roles' LIKE '%admin%'
    )
  );
END;
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_active_diet_session"("target_session_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Single atomic UPDATE: set is_active based on whether id matches target
  UPDATE diet_sessions
  SET is_active = (id = target_session_id)
  -- WHERE clause required by Supabase on UPDATE queries
  -- https://supabase.com/docs/reference/javascript/update
  WHERE id IS NOT NULL;
END;
$$;


ALTER FUNCTION "public"."set_active_diet_session"("target_session_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sum_chat_usage_cost"("from_iso" timestamp with time zone, "to_iso" timestamp with time zone) RETURNS numeric
    LANGUAGE "sql" STABLE
    AS $$
  select coalesce(sum(cost_usd), 0)
  from public.chat_usage_events
  where occurred_at >= from_iso
    and occurred_at < to_iso;
$$;


ALTER FUNCTION "public"."sum_chat_usage_cost"("from_iso" timestamp with time zone, "to_iso" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."bill_contents" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "difficulty_level" "public"."difficulty_level_enum" NOT NULL,
    "title" "text" NOT NULL,
    "summary" "text" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."bill_contents" OWNER TO "postgres";


COMMENT ON TABLE "public"."bill_contents" IS '議案の難易度別コンテンツを管理するテーブル';



COMMENT ON COLUMN "public"."bill_contents"."difficulty_level" IS '難易度レベル（normal:ふつう, hard:難しい）';



COMMENT ON COLUMN "public"."bill_contents"."content" IS 'Markdown形式の議案内容';



CREATE TABLE IF NOT EXISTS "public"."bills" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "originating_house" "public"."house_enum" NOT NULL,
    "status" "public"."bill_status_enum" NOT NULL,
    "status_note" "text",
    "published_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "thumbnail_url" "text",
    "publish_status" "public"."bill_publish_status" DEFAULT 'draft'::"public"."bill_publish_status" NOT NULL,
    "is_featured" boolean DEFAULT false NOT NULL,
    "share_thumbnail_url" "text",
    "shugiin_url" "text",
    "diet_session_id" "uuid",
    "status_order" integer GENERATED ALWAYS AS (
CASE "status"
    WHEN 'enacted'::"public"."bill_status_enum" THEN 0
    WHEN 'rejected'::"public"."bill_status_enum" THEN 1
    WHEN 'in_receiving_house'::"public"."bill_status_enum" THEN 2
    WHEN 'in_originating_house'::"public"."bill_status_enum" THEN 3
    WHEN 'introduced'::"public"."bill_status_enum" THEN 4
    WHEN 'preparing'::"public"."bill_status_enum" THEN 5
    ELSE NULL::integer
END) STORED,
    "publish_status_order" integer GENERATED ALWAYS AS (
CASE "publish_status"
    WHEN 'draft'::"public"."bill_publish_status" THEN 0
    WHEN 'coming_soon'::"public"."bill_publish_status" THEN 1
    WHEN 'published'::"public"."bill_publish_status" THEN 2
    ELSE NULL::integer
END) STORED,
    "document_type" "public"."document_type_enum" DEFAULT 'bill'::"public"."document_type_enum" NOT NULL
);


ALTER TABLE "public"."bills" OWNER TO "postgres";


COMMENT ON TABLE "public"."bills" IS '議案の基本情報を格納するテーブル。コンテンツはbill_contentsテーブルで管理。';



COMMENT ON COLUMN "public"."bills"."originating_house" IS '発議院（HR:衆議院, HC:参議院）';



COMMENT ON COLUMN "public"."bills"."status" IS '議案のステータス';



COMMENT ON COLUMN "public"."bills"."published_at" IS 'サービスでの議案公開日時';



COMMENT ON COLUMN "public"."bills"."thumbnail_url" IS 'URL to the bill thumbnail image stored in Supabase Storage';



COMMENT ON COLUMN "public"."bills"."publish_status" IS 'Publication status: draft (private) or published (public)';



COMMENT ON COLUMN "public"."bills"."is_featured" IS 'Flag to indicate if this bill is featured on the homepage';



COMMENT ON COLUMN "public"."bills"."share_thumbnail_url" IS 'URL to the share/Twitter OGP image stored in Supabase Storage';



COMMENT ON COLUMN "public"."bills"."shugiin_url" IS 'URL to the House of Representatives (衆議院) page for this bill';



COMMENT ON COLUMN "public"."bills"."diet_session_id" IS '紐付けられた国会会期ID';



COMMENT ON COLUMN "public"."bills"."document_type" IS '議会コンテンツの種別（議案、演説、報告、同意、承認）';



CREATE TABLE IF NOT EXISTS "public"."bills_tags" (
    "bill_id" "uuid" NOT NULL,
    "tag_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."bills_tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."bills_tags" IS 'Junction table for bills and tags relationship';



COMMENT ON COLUMN "public"."bills_tags"."bill_id" IS 'Bill ID';



COMMENT ON COLUMN "public"."bills_tags"."tag_id" IS 'Tag ID';



CREATE TABLE IF NOT EXISTS "public"."chat_usage_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "session_id" "text",
    "prompt_name" "text",
    "model" "text" NOT NULL,
    "input_tokens" integer DEFAULT 0 NOT NULL,
    "output_tokens" integer DEFAULT 0 NOT NULL,
    "total_tokens" integer DEFAULT 0 NOT NULL,
    "cost_usd" numeric(12,6) DEFAULT 0 NOT NULL,
    "metadata" "jsonb",
    "occurred_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."chat_usage_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chats" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "role" "public"."chat_role_enum" NOT NULL,
    "message" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."chats" OWNER TO "postgres";


COMMENT ON TABLE "public"."chats" IS 'AIとの対話履歴を管理するテーブル';



COMMENT ON COLUMN "public"."chats"."user_id" IS 'ユーザーID（Supabase匿名認証）';



COMMENT ON COLUMN "public"."chats"."role" IS 'メッセージの送信者役割';



CREATE TABLE IF NOT EXISTS "public"."diet_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "slug" "text",
    "shugiin_url" "text",
    "is_active" boolean DEFAULT false NOT NULL,
    CONSTRAINT "end_date_after_start_date" CHECK (("end_date" >= "start_date"))
);


ALTER TABLE "public"."diet_sessions" OWNER TO "postgres";


COMMENT ON COLUMN "public"."diet_sessions"."slug" IS 'URL用のスラッグ（例: 219-rinji, 218-jokai）';



COMMENT ON COLUMN "public"."diet_sessions"."shugiin_url" IS '衆議院の国会議案情報ページURL';



COMMENT ON COLUMN "public"."diet_sessions"."is_active" IS 'Whether this session is the active one displayed on the top page. Only one session can be active at a time.';



CREATE TABLE IF NOT EXISTS "public"."expert_registrations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "affiliation" "text" NOT NULL,
    "email" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL
);


ALTER TABLE "public"."expert_registrations" OWNER TO "postgres";


COMMENT ON TABLE "public"."expert_registrations" IS '有識者リスト登録情報を管理するテーブル';



COMMENT ON COLUMN "public"."expert_registrations"."name" IS '有識者の氏名';



COMMENT ON COLUMN "public"."expert_registrations"."affiliation" IS '所属・肩書';



COMMENT ON COLUMN "public"."expert_registrations"."email" IS 'メールアドレス';



COMMENT ON COLUMN "public"."expert_registrations"."user_id" IS '登録したユーザーのID';



CREATE TABLE IF NOT EXISTS "public"."interview_configs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "status" "public"."interview_config_status_enum" DEFAULT 'closed'::"public"."interview_config_status_enum" NOT NULL,
    "themes" "text"[],
    "knowledge_source" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "mode" "public"."interview_mode_enum" DEFAULT 'loop'::"public"."interview_mode_enum" NOT NULL,
    "chat_model" "text",
    "estimated_duration" integer
);


ALTER TABLE "public"."interview_configs" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_configs" IS '議案ごとのインタビュー設定を管理するテーブル';



COMMENT ON COLUMN "public"."interview_configs"."bill_id" IS '対象議案ID（複数設定可、ただしpublicは1つのみ）';



COMMENT ON COLUMN "public"."interview_configs"."status" IS '設定ステータス（public: 公開/有効, closed: 非公開/無効）';



COMMENT ON COLUMN "public"."interview_configs"."themes" IS 'テーマの配列';



COMMENT ON COLUMN "public"."interview_configs"."knowledge_source" IS '議案のコンテキスト情報';



COMMENT ON COLUMN "public"."interview_configs"."name" IS '設定名（識別用）';



COMMENT ON COLUMN "public"."interview_configs"."mode" IS 'インタビューモード: loop（逐次深掘り）または bulk（一括深掘り）';



CREATE TABLE IF NOT EXISTS "public"."interview_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_session_id" "uuid" NOT NULL,
    "role" "public"."interview_role_enum" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."interview_messages" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_messages" IS 'インタビュー内の質問と回答を保存するテーブル';



COMMENT ON COLUMN "public"."interview_messages"."interview_session_id" IS 'インタビューセッションID';



COMMENT ON COLUMN "public"."interview_messages"."role" IS 'メッセージの役割（assistant: AIからの質問, user: ユーザーからの回答）';



COMMENT ON COLUMN "public"."interview_messages"."content" IS 'メッセージ内容';



CREATE TABLE IF NOT EXISTS "public"."interview_questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_config_id" "uuid" NOT NULL,
    "question" "text" NOT NULL,
    "follow_up_guide" "text",
    "quick_replies" "text"[],
    "question_order" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."interview_questions" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_questions" IS '事前定義されたインタビュー質問を管理するテーブル';



COMMENT ON COLUMN "public"."interview_questions"."interview_config_id" IS 'インタビュー設定ID';



COMMENT ON COLUMN "public"."interview_questions"."question" IS '質問文';



COMMENT ON COLUMN "public"."interview_questions"."follow_up_guide" IS '回答後のフォローアップ指針（深掘り方法など）';



COMMENT ON COLUMN "public"."interview_questions"."quick_replies" IS 'ユーザーが選択できるクイックリプライ';



COMMENT ON COLUMN "public"."interview_questions"."question_order" IS '質問の順序';



CREATE TABLE IF NOT EXISTS "public"."interview_rating_feedbacks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_session_id" "uuid" NOT NULL,
    "tag" "public"."interview_feedback_tag_enum" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."interview_rating_feedbacks" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_rating_feedbacks" IS '低評価（3以下）時のフィードバックタグ';



COMMENT ON COLUMN "public"."interview_rating_feedbacks"."tag" IS 'フィードバックタグ種別';



CREATE TABLE IF NOT EXISTS "public"."interview_report" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_session_id" "uuid" NOT NULL,
    "summary" "text",
    "stance" "public"."stance_type_enum",
    "role" "public"."interview_report_role_enum",
    "role_description" "text",
    "opinions" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_public_by_admin" boolean DEFAULT false NOT NULL,
    "content_richness" "jsonb",
    "role_title" "text",
    "is_public_by_user" boolean DEFAULT false NOT NULL,
    "total_content_richness" integer GENERATED ALWAYS AS (
CASE
    WHEN (("content_richness" IS NOT NULL) AND (("content_richness" ->> 'total'::"text") IS NOT NULL) AND (("content_richness" ->> 'total'::"text") ~ '^\d+$'::"text")) THEN (("content_richness" ->> 'total'::"text"))::integer
    ELSE NULL::integer
END) STORED,
    "moderation_score" integer,
    "moderation_status" "public"."moderation_status_enum" GENERATED ALWAYS AS (
CASE
    WHEN ("moderation_score" IS NULL) THEN NULL::"public"."moderation_status_enum"
    WHEN ("moderation_score" >= 70) THEN 'ng'::"public"."moderation_status_enum"
    WHEN ("moderation_score" >= 30) THEN 'warning'::"public"."moderation_status_enum"
    ELSE 'ok'::"public"."moderation_status_enum"
END) STORED,
    "moderation_reasoning" "text",
    CONSTRAINT "chk_moderation_score_range" CHECK ((("moderation_score" IS NULL) OR (("moderation_score" >= 0) AND ("moderation_score" <= 100))))
);


ALTER TABLE "public"."interview_report" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_report" IS 'インタビュー結果のレポートを保存するテーブル（AIが自動生成）';



COMMENT ON COLUMN "public"."interview_report"."interview_session_id" IS 'インタビューセッションID（1セッション1レポート）';



COMMENT ON COLUMN "public"."interview_report"."summary" IS 'インタビュー要約';



COMMENT ON COLUMN "public"."interview_report"."stance" IS 'AIが分析したユーザーのスタンス';



COMMENT ON COLUMN "public"."interview_report"."role" IS 'AIが推論したユーザーの役割・属性（ENUM型）';



COMMENT ON COLUMN "public"."interview_report"."role_description" IS '役割の説明';



COMMENT ON COLUMN "public"."interview_report"."opinions" IS '意見の配列 [{title: string, content: string}, ...]';



COMMENT ON COLUMN "public"."interview_report"."is_public_by_admin" IS '管理者によるレポートの公開状態（true: 公開, false: 非公開）';



COMMENT ON COLUMN "public"."interview_report"."content_richness" IS 'インタビューの情報充実度評価（total, clarity, specificity, impact, constructiveness, reasoning）';



COMMENT ON COLUMN "public"."interview_report"."role_title" IS 'A short title (10 characters or less) summarizing the user role, e.g., "物流業者", "主婦"';



COMMENT ON COLUMN "public"."interview_report"."is_public_by_user" IS 'Whether the user has consented to making their interview report public';



COMMENT ON COLUMN "public"."interview_report"."total_content_richness" IS '総合的な情報充実度（0-100）- content_richnessから自動生成されるGenerated Column';



COMMENT ON COLUMN "public"."interview_report"."moderation_score" IS 'モデレーションスコア（0-100）: 0が最も適切、100が最も不適切';



COMMENT ON COLUMN "public"."interview_report"."moderation_status" IS 'モデレーションステータス（generated column）: ok=問題なし, warning=要注意, ng=不適切';



COMMENT ON COLUMN "public"."interview_report"."moderation_reasoning" IS 'モデレーションスコアの根拠（200文字以内）';



CREATE TABLE IF NOT EXISTS "public"."interview_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_config_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "langfuse_session_id" "text",
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "archived_at" timestamp with time zone,
    "rating" smallint,
    CONSTRAINT "interview_sessions_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."interview_sessions" OWNER TO "postgres";


COMMENT ON TABLE "public"."interview_sessions" IS 'インタビューセッションを管理するテーブル';



COMMENT ON COLUMN "public"."interview_sessions"."interview_config_id" IS 'インタビュー設定ID';



COMMENT ON COLUMN "public"."interview_sessions"."user_id" IS 'ユーザーID（匿名認証）';



COMMENT ON COLUMN "public"."interview_sessions"."langfuse_session_id" IS 'LangfuseセッションID';



COMMENT ON COLUMN "public"."interview_sessions"."started_at" IS '開始日時';



COMMENT ON COLUMN "public"."interview_sessions"."completed_at" IS '完了日時';



CREATE TABLE IF NOT EXISTS "public"."mirai_stances" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "type" "public"."stance_type_enum" NOT NULL,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."mirai_stances" OWNER TO "postgres";


COMMENT ON TABLE "public"."mirai_stances" IS 'チームみらい（安野議員）の公式スタンスを記録するテーブル';



COMMENT ON COLUMN "public"."mirai_stances"."type" IS 'スタンス（for:賛成, against:反対, neutral:中立, conditional_for:条件付き賛成, conditional_against:条件付き反対, considering:検討中）';



CREATE TABLE IF NOT EXISTS "public"."preview_tokens" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "text"
);


ALTER TABLE "public"."preview_tokens" OWNER TO "postgres";


COMMENT ON TABLE "public"."preview_tokens" IS 'Preview tokens for bill access management';



COMMENT ON COLUMN "public"."preview_tokens"."token" IS 'Unique preview access token';



COMMENT ON COLUMN "public"."preview_tokens"."expires_at" IS 'Token expiration date (30 days)';



CREATE TABLE IF NOT EXISTS "public"."report_reactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "interview_report_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "reaction_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "report_reactions_reaction_type_check" CHECK (("reaction_type" = ANY (ARRAY['helpful'::"text", 'hmm'::"text"])))
);


ALTER TABLE "public"."report_reactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "label" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "featured_priority" integer,
    "description" "text"
);


ALTER TABLE "public"."tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."tags" IS 'Master table for tags';



COMMENT ON COLUMN "public"."tags"."label" IS 'Tag label (display name)';



COMMENT ON COLUMN "public"."tags"."featured_priority" IS 'Featured表示の優先度（数値が小さいほど優先度が高い）。NULLの場合は非表示';



COMMENT ON COLUMN "public"."tags"."description" IS 'Tag description text';



CREATE TABLE IF NOT EXISTS "public"."topic_analysis_classifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version_id" "uuid" NOT NULL,
    "interview_report_id" "uuid" NOT NULL,
    "topic_id" "uuid" NOT NULL,
    "opinion_index" integer NOT NULL
);


ALTER TABLE "public"."topic_analysis_classifications" OWNER TO "postgres";


COMMENT ON TABLE "public"."topic_analysis_classifications" IS '意見とトピックの分類（多対多）';



COMMENT ON COLUMN "public"."topic_analysis_classifications"."version_id" IS '所属バージョンID';



COMMENT ON COLUMN "public"."topic_analysis_classifications"."interview_report_id" IS 'インタビューレポートID';



COMMENT ON COLUMN "public"."topic_analysis_classifications"."topic_id" IS 'トピックID';



COMMENT ON COLUMN "public"."topic_analysis_classifications"."opinion_index" IS 'レポート内の意見インデックス';



CREATE TABLE IF NOT EXISTS "public"."topic_analysis_topics" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description_md" "text" NOT NULL,
    "representative_opinions" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."topic_analysis_topics" OWNER TO "postgres";


COMMENT ON TABLE "public"."topic_analysis_topics" IS 'トピック解析で抽出されたトピック';



COMMENT ON COLUMN "public"."topic_analysis_topics"."version_id" IS '所属バージョンID';



COMMENT ON COLUMN "public"."topic_analysis_topics"."name" IS 'トピック名';



COMMENT ON COLUMN "public"."topic_analysis_topics"."description_md" IS 'トピックの説明文（markdown形式）';



COMMENT ON COLUMN "public"."topic_analysis_topics"."representative_opinions" IS '代表的な意見（JSON配列、最大5件）';



COMMENT ON COLUMN "public"."topic_analysis_topics"."sort_order" IS '表示順';



CREATE TABLE IF NOT EXISTS "public"."topic_analysis_versions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bill_id" "uuid" NOT NULL,
    "version" integer NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "summary_md" "text",
    "intermediate_results" "jsonb",
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "current_step" "text",
    "started_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "phase_data" "jsonb",
    CONSTRAINT "topic_analysis_versions_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'running'::"text", 'completed'::"text", 'failed'::"text"])))
);


ALTER TABLE "public"."topic_analysis_versions" OWNER TO "postgres";


COMMENT ON TABLE "public"."topic_analysis_versions" IS 'トピック解析のバージョン管理';



COMMENT ON COLUMN "public"."topic_analysis_versions"."bill_id" IS '対象議案ID';



COMMENT ON COLUMN "public"."topic_analysis_versions"."version" IS 'バージョン番号（議案ごとにインクリメント）';



COMMENT ON COLUMN "public"."topic_analysis_versions"."status" IS '解析ステータス: pending, running, completed, failed';



COMMENT ON COLUMN "public"."topic_analysis_versions"."summary_md" IS '全体サマリ（markdown形式）';



COMMENT ON COLUMN "public"."topic_analysis_versions"."intermediate_results" IS '中間結果（デバッグ・参照用）';



COMMENT ON COLUMN "public"."topic_analysis_versions"."error_message" IS 'エラー時のメッセージ';



ALTER TABLE ONLY "public"."bill_contents"
    ADD CONSTRAINT "bill_contents_bill_id_difficulty_level_key" UNIQUE ("bill_id", "difficulty_level");



ALTER TABLE ONLY "public"."bill_contents"
    ADD CONSTRAINT "bill_contents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bills"
    ADD CONSTRAINT "bills_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bills_tags"
    ADD CONSTRAINT "bills_tags_pkey" PRIMARY KEY ("bill_id", "tag_id");



ALTER TABLE ONLY "public"."chat_usage_events"
    ADD CONSTRAINT "chat_usage_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."diet_sessions"
    ADD CONSTRAINT "diet_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."diet_sessions"
    ADD CONSTRAINT "diet_sessions_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."expert_registrations"
    ADD CONSTRAINT "expert_registrations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_configs"
    ADD CONSTRAINT "interview_configs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_messages"
    ADD CONSTRAINT "interview_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_questions"
    ADD CONSTRAINT "interview_questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_rating_feedbacks"
    ADD CONSTRAINT "interview_rating_feedbacks_interview_session_id_tag_key" UNIQUE ("interview_session_id", "tag");



ALTER TABLE ONLY "public"."interview_rating_feedbacks"
    ADD CONSTRAINT "interview_rating_feedbacks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_report"
    ADD CONSTRAINT "interview_report_interview_session_id_key" UNIQUE ("interview_session_id");



ALTER TABLE ONLY "public"."interview_report"
    ADD CONSTRAINT "interview_report_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interview_sessions"
    ADD CONSTRAINT "interview_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."mirai_stances"
    ADD CONSTRAINT "mirai_stances_bill_id_key" UNIQUE ("bill_id");



ALTER TABLE ONLY "public"."mirai_stances"
    ADD CONSTRAINT "mirai_stances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."preview_tokens"
    ADD CONSTRAINT "preview_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."preview_tokens"
    ADD CONSTRAINT "preview_tokens_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."report_reactions"
    ADD CONSTRAINT "report_reactions_interview_report_id_user_id_key" UNIQUE ("interview_report_id", "user_id");



ALTER TABLE ONLY "public"."report_reactions"
    ADD CONSTRAINT "report_reactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_label_key" UNIQUE ("label");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic_analysis_classifications"
    ADD CONSTRAINT "topic_analysis_classification_version_id_interview_report_i_key" UNIQUE ("version_id", "interview_report_id", "topic_id", "opinion_index");



ALTER TABLE ONLY "public"."topic_analysis_classifications"
    ADD CONSTRAINT "topic_analysis_classifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic_analysis_topics"
    ADD CONSTRAINT "topic_analysis_topics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic_analysis_versions"
    ADD CONSTRAINT "topic_analysis_versions_bill_id_version_key" UNIQUE ("bill_id", "version");



ALTER TABLE ONLY "public"."topic_analysis_versions"
    ADD CONSTRAINT "topic_analysis_versions_pkey" PRIMARY KEY ("id");



CREATE INDEX "chat_usage_events_session_id_idx" ON "public"."chat_usage_events" USING "btree" ("session_id");



CREATE INDEX "chat_usage_events_user_id_occurred_at_idx" ON "public"."chat_usage_events" USING "btree" ("user_id", "occurred_at");



CREATE INDEX "idx_bill_contents_bill_id" ON "public"."bill_contents" USING "btree" ("bill_id");



CREATE INDEX "idx_bill_contents_difficulty" ON "public"."bill_contents" USING "btree" ("difficulty_level");



CREATE INDEX "idx_bills_diet_session_id" ON "public"."bills" USING "btree" ("diet_session_id");



CREATE INDEX "idx_bills_is_featured" ON "public"."bills" USING "btree" ("is_featured") WHERE ("is_featured" = true);



CREATE INDEX "idx_bills_originating_house" ON "public"."bills" USING "btree" ("originating_house");



CREATE INDEX "idx_bills_publish_status" ON "public"."bills" USING "btree" ("publish_status");



CREATE INDEX "idx_bills_publish_status_order" ON "public"."bills" USING "btree" ("publish_status_order");



CREATE INDEX "idx_bills_published_at" ON "public"."bills" USING "btree" ("published_at" DESC);



CREATE INDEX "idx_bills_status" ON "public"."bills" USING "btree" ("status");



CREATE INDEX "idx_bills_status_order" ON "public"."bills" USING "btree" ("status_order");



CREATE INDEX "idx_chats_bill_id" ON "public"."chats" USING "btree" ("bill_id");



CREATE INDEX "idx_chats_bill_user" ON "public"."chats" USING "btree" ("bill_id", "user_id");



CREATE INDEX "idx_chats_created_at" ON "public"."chats" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_chats_user_id" ON "public"."chats" USING "btree" ("user_id");



CREATE INDEX "idx_diet_sessions_date_range" ON "public"."diet_sessions" USING "btree" ("start_date", "end_date");



CREATE INDEX "idx_diet_sessions_slug" ON "public"."diet_sessions" USING "btree" ("slug");



CREATE UNIQUE INDEX "idx_expert_registrations_email" ON "public"."expert_registrations" USING "btree" ("email");



CREATE UNIQUE INDEX "idx_expert_registrations_user_id" ON "public"."expert_registrations" USING "btree" ("user_id");



CREATE INDEX "idx_interview_configs_bill_id" ON "public"."interview_configs" USING "btree" ("bill_id");



CREATE UNIQUE INDEX "idx_interview_configs_bill_public" ON "public"."interview_configs" USING "btree" ("bill_id") WHERE ("status" = 'public'::"public"."interview_config_status_enum");



CREATE INDEX "idx_interview_configs_status" ON "public"."interview_configs" USING "btree" ("status");



CREATE INDEX "idx_interview_messages_session_created" ON "public"."interview_messages" USING "btree" ("interview_session_id", "created_at");



CREATE INDEX "idx_interview_messages_session_id" ON "public"."interview_messages" USING "btree" ("interview_session_id");



CREATE INDEX "idx_interview_questions_config_id" ON "public"."interview_questions" USING "btree" ("interview_config_id");



CREATE INDEX "idx_interview_questions_config_order" ON "public"."interview_questions" USING "btree" ("interview_config_id", "question_order");



CREATE INDEX "idx_interview_rating_feedbacks_session" ON "public"."interview_rating_feedbacks" USING "btree" ("interview_session_id");



CREATE INDEX "idx_interview_rating_feedbacks_tag" ON "public"."interview_rating_feedbacks" USING "btree" ("tag");



CREATE INDEX "idx_interview_report_is_public_by_admin" ON "public"."interview_report" USING "btree" ("is_public_by_admin");



CREATE INDEX "idx_interview_report_moderation_status" ON "public"."interview_report" USING "btree" ("moderation_status");



CREATE INDEX "idx_interview_report_total_content_richness" ON "public"."interview_report" USING "btree" ("total_content_richness" DESC NULLS LAST);



CREATE INDEX "idx_interview_sessions_config_id" ON "public"."interview_sessions" USING "btree" ("interview_config_id");



CREATE INDEX "idx_interview_sessions_config_user" ON "public"."interview_sessions" USING "btree" ("interview_config_id", "user_id");



CREATE INDEX "idx_interview_sessions_started_at" ON "public"."interview_sessions" USING "btree" ("started_at");



CREATE INDEX "idx_interview_sessions_user_id" ON "public"."interview_sessions" USING "btree" ("user_id");



CREATE INDEX "idx_mirai_stances_bill_id" ON "public"."mirai_stances" USING "btree" ("bill_id");



CREATE INDEX "idx_mirai_stances_type" ON "public"."mirai_stances" USING "btree" ("type");



CREATE INDEX "idx_preview_tokens_bill_id" ON "public"."preview_tokens" USING "btree" ("bill_id");



CREATE INDEX "idx_preview_tokens_expires_at" ON "public"."preview_tokens" USING "btree" ("expires_at");



CREATE INDEX "idx_preview_tokens_token" ON "public"."preview_tokens" USING "btree" ("token");



CREATE INDEX "idx_report_reactions_report_id" ON "public"."report_reactions" USING "btree" ("interview_report_id");



CREATE INDEX "idx_report_reactions_user_id" ON "public"."report_reactions" USING "btree" ("user_id");



CREATE INDEX "idx_tags_featured_priority" ON "public"."tags" USING "btree" ("featured_priority") WHERE ("featured_priority" IS NOT NULL);



CREATE INDEX "idx_topic_analysis_classifications_topic_id" ON "public"."topic_analysis_classifications" USING "btree" ("topic_id");



CREATE INDEX "idx_topic_analysis_classifications_version_id" ON "public"."topic_analysis_classifications" USING "btree" ("version_id");



CREATE INDEX "idx_topic_analysis_topics_version_id" ON "public"."topic_analysis_topics" USING "btree" ("version_id");



CREATE INDEX "idx_topic_analysis_versions_bill_id" ON "public"."topic_analysis_versions" USING "btree" ("bill_id");



CREATE OR REPLACE TRIGGER "set_topic_analysis_versions_updated_at" BEFORE UPDATE ON "public"."topic_analysis_versions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "set_updated_at" BEFORE UPDATE ON "public"."diet_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_bill_contents_updated_at" BEFORE UPDATE ON "public"."bill_contents" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_bills_updated_at" BEFORE UPDATE ON "public"."bills" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_chats_updated_at" BEFORE UPDATE ON "public"."chats" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_expert_registrations_updated_at" BEFORE UPDATE ON "public"."expert_registrations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_interview_configs_updated_at" BEFORE UPDATE ON "public"."interview_configs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_interview_questions_updated_at" BEFORE UPDATE ON "public"."interview_questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_interview_report_updated_at" BEFORE UPDATE ON "public"."interview_report" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_interview_sessions_updated_at" BEFORE UPDATE ON "public"."interview_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_mirai_stances_updated_at" BEFORE UPDATE ON "public"."mirai_stances" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_tags_updated_at" BEFORE UPDATE ON "public"."tags" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."bill_contents"
    ADD CONSTRAINT "bill_contents_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bills"
    ADD CONSTRAINT "bills_diet_session_id_fkey" FOREIGN KEY ("diet_session_id") REFERENCES "public"."diet_sessions"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."bills_tags"
    ADD CONSTRAINT "bills_tags_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bills_tags"
    ADD CONSTRAINT "bills_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expert_registrations"
    ADD CONSTRAINT "expert_registrations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_configs"
    ADD CONSTRAINT "interview_configs_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_messages"
    ADD CONSTRAINT "interview_messages_interview_session_id_fkey" FOREIGN KEY ("interview_session_id") REFERENCES "public"."interview_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_questions"
    ADD CONSTRAINT "interview_questions_interview_config_id_fkey" FOREIGN KEY ("interview_config_id") REFERENCES "public"."interview_configs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_rating_feedbacks"
    ADD CONSTRAINT "interview_rating_feedbacks_interview_session_id_fkey" FOREIGN KEY ("interview_session_id") REFERENCES "public"."interview_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_report"
    ADD CONSTRAINT "interview_report_interview_session_id_fkey" FOREIGN KEY ("interview_session_id") REFERENCES "public"."interview_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interview_sessions"
    ADD CONSTRAINT "interview_sessions_interview_config_id_fkey" FOREIGN KEY ("interview_config_id") REFERENCES "public"."interview_configs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mirai_stances"
    ADD CONSTRAINT "mirai_stances_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."preview_tokens"
    ADD CONSTRAINT "preview_tokens_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."report_reactions"
    ADD CONSTRAINT "report_reactions_interview_report_id_fkey" FOREIGN KEY ("interview_report_id") REFERENCES "public"."interview_report"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic_analysis_classifications"
    ADD CONSTRAINT "topic_analysis_classifications_interview_report_id_fkey" FOREIGN KEY ("interview_report_id") REFERENCES "public"."interview_report"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic_analysis_classifications"
    ADD CONSTRAINT "topic_analysis_classifications_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "public"."topic_analysis_topics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic_analysis_classifications"
    ADD CONSTRAINT "topic_analysis_classifications_version_id_fkey" FOREIGN KEY ("version_id") REFERENCES "public"."topic_analysis_versions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic_analysis_topics"
    ADD CONSTRAINT "topic_analysis_topics_version_id_fkey" FOREIGN KEY ("version_id") REFERENCES "public"."topic_analysis_versions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic_analysis_versions"
    ADD CONSTRAINT "topic_analysis_versions_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id") ON DELETE CASCADE;



ALTER TABLE "public"."bill_contents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bills_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_usage_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."diet_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."expert_registrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_configs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_questions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_rating_feedbacks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_report" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interview_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."mirai_stances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."preview_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."report_reactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."topic_analysis_classifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."topic_analysis_topics" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."topic_analysis_versions" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."bulk_publish_reports"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."bulk_publish_reports"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."bulk_publish_reports"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."count_bulk_publish_targets"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."count_bulk_publish_targets"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_bulk_publish_targets"("p_config_id" "uuid", "p_max_moderation_score" integer, "p_min_content_richness" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."count_public_reports_by_stance"("p_bill_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."count_public_reports_by_stance"("p_bill_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_public_reports_by_stance"("p_bill_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."count_reactions_by_report_ids"("report_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."count_reactions_by_report_ids"("report_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_reactions_by_report_ids"("report_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."count_sessions_by_config_ids"("p_config_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."count_sessions_by_config_ids"("p_config_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_sessions_by_config_ids"("p_config_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."find_public_reports_by_bill_id_ordered_by_reactions"("p_bill_id" "uuid", "p_limit" integer, "p_offset" integer, "p_stance" "text", "p_sort_order" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."find_public_reports_by_bill_id_ordered_by_reactions"("p_bill_id" "uuid", "p_limit" integer, "p_offset" integer, "p_stance" "text", "p_sort_order" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_public_reports_by_bill_id_ordered_by_reactions"("p_bill_id" "uuid", "p_limit" integer, "p_offset" integer, "p_stance" "text", "p_sort_order" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_helpful_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_helpful_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_helpful_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_message_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_message_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_message_count"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_moderation_score"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_moderation_score"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_moderation_score"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_total_content_richness"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_total_content_richness"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_sessions_ordered_by_total_content_richness"("p_config_id" "uuid", "p_ascending" boolean, "p_offset" integer, "p_limit" integer, "p_status" "text", "p_visibility" "text", "p_stance" "text", "p_role" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_admin_users"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_admin_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_interview_message_counts"("session_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_interview_message_counts"("session_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_interview_message_counts"("session_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_interview_statistics"("p_config_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_interview_statistics"("p_config_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_interview_statistics"("p_config_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_active_diet_session"("target_session_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."set_active_diet_session"("target_session_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_active_diet_session"("target_session_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."sum_chat_usage_cost"("from_iso" timestamp with time zone, "to_iso" timestamp with time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."sum_chat_usage_cost"("from_iso" timestamp with time zone, "to_iso" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON TABLE "public"."bill_contents" TO "anon";
GRANT ALL ON TABLE "public"."bill_contents" TO "authenticated";
GRANT ALL ON TABLE "public"."bill_contents" TO "service_role";



GRANT ALL ON TABLE "public"."bills" TO "anon";
GRANT ALL ON TABLE "public"."bills" TO "authenticated";
GRANT ALL ON TABLE "public"."bills" TO "service_role";



GRANT ALL ON TABLE "public"."bills_tags" TO "anon";
GRANT ALL ON TABLE "public"."bills_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."bills_tags" TO "service_role";



GRANT ALL ON TABLE "public"."chat_usage_events" TO "anon";
GRANT ALL ON TABLE "public"."chat_usage_events" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_usage_events" TO "service_role";



GRANT ALL ON TABLE "public"."chats" TO "anon";
GRANT ALL ON TABLE "public"."chats" TO "authenticated";
GRANT ALL ON TABLE "public"."chats" TO "service_role";



GRANT ALL ON TABLE "public"."diet_sessions" TO "anon";
GRANT ALL ON TABLE "public"."diet_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."diet_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."expert_registrations" TO "anon";
GRANT ALL ON TABLE "public"."expert_registrations" TO "authenticated";
GRANT ALL ON TABLE "public"."expert_registrations" TO "service_role";



GRANT ALL ON TABLE "public"."interview_configs" TO "anon";
GRANT ALL ON TABLE "public"."interview_configs" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_configs" TO "service_role";



GRANT ALL ON TABLE "public"."interview_messages" TO "anon";
GRANT ALL ON TABLE "public"."interview_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_messages" TO "service_role";



GRANT ALL ON TABLE "public"."interview_questions" TO "anon";
GRANT ALL ON TABLE "public"."interview_questions" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_questions" TO "service_role";



GRANT ALL ON TABLE "public"."interview_rating_feedbacks" TO "anon";
GRANT ALL ON TABLE "public"."interview_rating_feedbacks" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_rating_feedbacks" TO "service_role";



GRANT ALL ON TABLE "public"."interview_report" TO "anon";
GRANT ALL ON TABLE "public"."interview_report" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_report" TO "service_role";



GRANT ALL ON TABLE "public"."interview_sessions" TO "anon";
GRANT ALL ON TABLE "public"."interview_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."interview_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."mirai_stances" TO "anon";
GRANT ALL ON TABLE "public"."mirai_stances" TO "authenticated";
GRANT ALL ON TABLE "public"."mirai_stances" TO "service_role";



GRANT ALL ON TABLE "public"."preview_tokens" TO "anon";
GRANT ALL ON TABLE "public"."preview_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."preview_tokens" TO "service_role";



GRANT ALL ON TABLE "public"."report_reactions" TO "anon";
GRANT ALL ON TABLE "public"."report_reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."report_reactions" TO "service_role";



GRANT ALL ON TABLE "public"."tags" TO "anon";
GRANT ALL ON TABLE "public"."tags" TO "authenticated";
GRANT ALL ON TABLE "public"."tags" TO "service_role";



GRANT ALL ON TABLE "public"."topic_analysis_classifications" TO "anon";
GRANT ALL ON TABLE "public"."topic_analysis_classifications" TO "authenticated";
GRANT ALL ON TABLE "public"."topic_analysis_classifications" TO "service_role";



GRANT ALL ON TABLE "public"."topic_analysis_topics" TO "anon";
GRANT ALL ON TABLE "public"."topic_analysis_topics" TO "authenticated";
GRANT ALL ON TABLE "public"."topic_analysis_topics" TO "service_role";



GRANT ALL ON TABLE "public"."topic_analysis_versions" TO "anon";
GRANT ALL ON TABLE "public"."topic_analysis_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."topic_analysis_versions" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







