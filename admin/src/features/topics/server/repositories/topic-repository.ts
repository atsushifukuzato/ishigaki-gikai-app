import "server-only";

import { createAdminClient } from "@mirai-gikai/supabase";
import type {
  AttachTopicBillInput,
  CreateTopicInput,
  CreateTopicUpdateInput,
  DetachTopicBillInput,
  UpdateTopicInput,
  UpdateTopicUpdateInput,
} from "../../shared/types";

export async function findAllTopicsWithBillCount() {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topics")
    .select(
      `
      id,
      slug,
      title,
      description,
      content,
      current_status_label,
      current_status_note,
      current_status_updated_at,
      status,
      created_at,
      updated_at,
      topic_bills_count:topic_bills(count),
      topic_bill_relations:topic_bills(
        bill_id,
        bills(
          id,
          name,
          status,
          publish_status,
          diet_sessions(name)
        )
      ),
      topic_updates(
        id,
        topic_id,
        kind,
        title,
        summary,
        content,
        source_label,
        source_url,
        status_label,
        published_at,
        created_at,
        updated_at
      )
    `
    )
    .order("updated_at", { ascending: false })
    .order("published_at", {
      referencedTable: "topic_updates",
      ascending: false,
    });

  if (error) {
    throw new Error(`トピックの取得に失敗しました: ${error.message}`);
  }

  return data;
}

export async function createTopicRecord(input: CreateTopicInput) {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topics")
    .insert({
      ...input,
      current_status_updated_at:
        input.current_status_updated_at ??
        (input.current_status_label || input.current_status_note
          ? new Date().toISOString()
          : null),
    })
    .select()
    .single();

  if (error) {
    if (error.code === "23505") {
      return {
        data: null,
        error: { code: error.code, message: error.message },
      };
    }
    throw new Error(`トピックの作成に失敗しました: ${error.message}`);
  }

  return { data, error: null };
}

export async function updateTopicRecord(input: UpdateTopicInput) {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topics")
    .update({
      slug: input.slug,
      title: input.title,
      description: input.description,
      content: input.content,
      current_status_label: input.current_status_label,
      current_status_note: input.current_status_note,
      current_status_updated_at: input.current_status_updated_at,
      status: input.status,
    })
    .eq("id", input.id)
    .select()
    .single();

  if (error) {
    if (error.code === "23505" || error.code === "PGRST116") {
      return {
        data: null,
        error: { code: error.code, message: error.message },
      };
    }
    throw new Error(`トピックの更新に失敗しました: ${error.message}`);
  }

  return { data, error: null };
}

export async function deleteTopicRecord(id: string) {
  const supabase = createAdminClient();
  const { error } = await supabase.from("topics").delete().eq("id", id);

  if (error) {
    if (error.code === "PGRST116") {
      return { error: { code: error.code, message: error.message } };
    }
    throw new Error(`トピックの削除に失敗しました: ${error.message}`);
  }

  return { error: null };
}

export async function attachTopicBillRecord(input: AttachTopicBillInput) {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topic_bills")
    .insert(input)
    .select()
    .single();

  if (error) {
    if (error.code === "23505") {
      return {
        data: null,
        error: { code: error.code, message: error.message },
      };
    }
    throw new Error(`関連議案の追加に失敗しました: ${error.message}`);
  }

  return { data, error: null };
}

export async function detachTopicBillRecord(input: DetachTopicBillInput) {
  const supabase = createAdminClient();
  const { error } = await supabase
    .from("topic_bills")
    .delete()
    .eq("topic_id", input.topic_id)
    .eq("bill_id", input.bill_id);

  if (error) {
    throw new Error(`関連議案の削除に失敗しました: ${error.message}`);
  }

  return { error: null };
}

export async function createTopicUpdateRecord(input: CreateTopicUpdateInput) {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topic_updates")
    .insert(input)
    .select()
    .single();

  if (error) {
    if (error.code === "23505") {
      return {
        data: null,
        error: { code: error.code, message: error.message },
      };
    }
    throw new Error(`更新履歴の作成に失敗しました: ${error.message}`);
  }

  return { data, error: null };
}

export async function updateTopicUpdateRecord(input: UpdateTopicUpdateInput) {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("topic_updates")
    .update({
      kind: input.kind,
      title: input.title,
      summary: input.summary,
      content: input.content,
      source_label: input.source_label,
      source_url: input.source_url,
      status_label: input.status_label,
      published_at: input.published_at,
    })
    .eq("id", input.id)
    .select()
    .single();

  if (error) {
    if (error.code === "23505" || error.code === "PGRST116") {
      return {
        data: null,
        error: { code: error.code, message: error.message },
      };
    }
    throw new Error(`更新履歴の更新に失敗しました: ${error.message}`);
  }

  return { data, error: null };
}

export async function deleteTopicUpdateRecord(id: string) {
  const supabase = createAdminClient();
  const { error } = await supabase.from("topic_updates").delete().eq("id", id);

  if (error) {
    if (error.code === "PGRST116") {
      return { error: { code: error.code, message: error.message } };
    }
    throw new Error(`更新履歴の削除に失敗しました: ${error.message}`);
  }

  return { error: null };
}
