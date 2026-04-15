"use client";

import type { FormEvent } from "react";
import { useState } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { createTopicUpdate } from "../../server/actions/create-topic-update";
import type { TopicUpdateKind } from "../../shared/types";

type TopicUpdateFormProps = {
  topicId: string;
};

function getDefaultPublishedAt() {
  const now = new Date();
  const offsetMs = now.getTimezoneOffset() * 60 * 1000;
  return new Date(now.getTime() - offsetMs).toISOString().slice(0, 16);
}

const updateKindOptions: { value: TopicUpdateKind; label: string }[] = [
  { value: "progress", label: "進捗" },
  { value: "council", label: "議会" },
  { value: "decision", label: "決定" },
  { value: "news", label: "ニュース" },
];

export function TopicUpdateForm({ topicId }: TopicUpdateFormProps) {
  const [kind, setKind] = useState<TopicUpdateKind>("progress");
  const [title, setTitle] = useState("");
  const [summary, setSummary] = useState("");
  const [content, setContent] = useState("");
  const [statusLabel, setStatusLabel] = useState("");
  const [sourceLabel, setSourceLabel] = useState("");
  const [sourceUrl, setSourceUrl] = useState("");
  const [publishedAt, setPublishedAt] = useState(getDefaultPublishedAt());
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      toast.error("更新タイトルを入力してください");
      return;
    }
    if (!summary.trim()) {
      toast.error("更新要約を入力してください");
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await createTopicUpdate({
        topic_id: topicId,
        kind,
        title,
        summary,
        content,
        status_label: statusLabel,
        source_label: sourceLabel,
        source_url: sourceUrl,
        published_at: new Date(publishedAt).toISOString(),
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("更新履歴を追加しました");
        setKind("progress");
        setTitle("");
        setSummary("");
        setContent("");
        setStatusLabel("");
        setSourceLabel("");
        setSourceUrl("");
        setPublishedAt(getDefaultPublishedAt());
      }
    } catch (error) {
      console.error("Create topic update error:", error);
      toast.error("更新履歴の追加に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 rounded-lg border p-4">
      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <Label>種別</Label>
          <select
            value={kind}
            onChange={(e) => setKind(e.target.value as TopicUpdateKind)}
            disabled={isSubmitting}
            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            {updateKindOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <Label>公開日時</Label>
          <Input
            type="datetime-local"
            value={publishedAt}
            onChange={(e) => setPublishedAt(e.target.value)}
            disabled={isSubmitting}
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label>タイトル</Label>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          disabled={isSubmitting}
        />
      </div>

      <div className="space-y-2">
        <Label>要約</Label>
        <Textarea
          value={summary}
          onChange={(e) => setSummary(e.target.value)}
          rows={3}
          disabled={isSubmitting}
        />
      </div>

      <div className="space-y-2">
        <Label>本文</Label>
        <Textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          rows={6}
          disabled={isSubmitting}
        />
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <div className="space-y-2">
          <Label>状況ラベル</Label>
          <Input
            value={statusLabel}
            onChange={(e) => setStatusLabel(e.target.value)}
            placeholder="検討段階"
            disabled={isSubmitting}
          />
        </div>
        <div className="space-y-2">
          <Label>出典名</Label>
          <Input
            value={sourceLabel}
            onChange={(e) => setSourceLabel(e.target.value)}
            disabled={isSubmitting}
          />
        </div>
        <div className="space-y-2">
          <Label>出典URL</Label>
          <Input
            value={sourceUrl}
            onChange={(e) => setSourceUrl(e.target.value)}
            disabled={isSubmitting}
          />
        </div>
      </div>

      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "追加中..." : "更新履歴を追加"}
      </Button>
    </form>
  );
}
