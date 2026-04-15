"use client";

import { useState } from "react";
import { toast } from "sonner";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { deleteTopicUpdate } from "../../server/actions/delete-topic-update";
import { updateTopicUpdate } from "../../server/actions/update-topic-update";
import type { TopicUpdate, TopicUpdateKind } from "../../shared/types";

type TopicUpdateItemProps = {
  update: TopicUpdate;
};

const updateKindOptions: { value: TopicUpdateKind; label: string }[] = [
  { value: "progress", label: "進捗" },
  { value: "council", label: "議会" },
  { value: "decision", label: "決定" },
  { value: "news", label: "ニュース" },
];

function toLocalDateTime(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "";
  }
  const offsetMs = date.getTimezoneOffset() * 60 * 1000;
  return new Date(date.getTime() - offsetMs).toISOString().slice(0, 16);
}

function getKindLabel(kind: TopicUpdateKind) {
  return (
    updateKindOptions.find((option) => option.value === kind)?.label ?? kind
  );
}

export function TopicUpdateItem({ update }: TopicUpdateItemProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [kind, setKind] = useState<TopicUpdateKind>(update.kind);
  const [title, setTitle] = useState(update.title);
  const [summary, setSummary] = useState(update.summary);
  const [content, setContent] = useState(update.content);
  const [statusLabel, setStatusLabel] = useState(update.status_label ?? "");
  const [sourceLabel, setSourceLabel] = useState(update.source_label ?? "");
  const [sourceUrl, setSourceUrl] = useState(update.source_url ?? "");
  const [publishedAt, setPublishedAt] = useState(
    toLocalDateTime(update.published_at)
  );
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleUpdate = async () => {
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
      const result = await updateTopicUpdate({
        id: update.id,
        topic_id: update.topic_id,
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
        toast.success("更新履歴を更新しました");
        setIsEditing(false);
      }
    } catch (error) {
      console.error("Update topic update error:", error);
      toast.error("更新履歴の更新に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    setIsSubmitting(true);

    try {
      const result = await deleteTopicUpdate({ id: update.id });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("更新履歴を削除しました");
      }
    } catch (error) {
      console.error("Delete topic update error:", error);
      toast.error("更新履歴の削除に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isEditing) {
    return (
      <div className="rounded-lg border border-dashed p-4">
        <div className="space-y-4">
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

          <div className="flex gap-2">
            <Button onClick={handleUpdate} disabled={isSubmitting}>
              {isSubmitting ? "保存中..." : "保存"}
            </Button>
            <Button
              variant="outline"
              onClick={() => setIsEditing(false)}
              disabled={isSubmitting}
            >
              キャンセル
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-lg border p-4">
      <div className="flex items-start justify-between gap-4">
        <div className="space-y-2">
          <div className="flex flex-wrap items-center gap-2">
            <span className="rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
              {getKindLabel(update.kind)}
            </span>
            {update.status_label ? (
              <span className="rounded bg-blue-100 px-2 py-0.5 text-xs text-blue-700">
                {update.status_label}
              </span>
            ) : null}
            <span className="text-xs text-gray-500">
              {new Date(update.published_at).toLocaleString("ja-JP")}
            </span>
          </div>
          <h4 className="font-semibold">{update.title}</h4>
          <p className="text-sm text-gray-700 whitespace-pre-wrap">
            {update.summary}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsEditing(true)}
            disabled={isSubmitting}
          >
            編集
          </Button>
          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button variant="ghost" size="sm" disabled={isSubmitting}>
                削除
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>更新履歴の削除</AlertDialogTitle>
                <AlertDialogDescription>
                  この更新履歴を削除しますか？
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>キャンセル</AlertDialogCancel>
                <AlertDialogAction onClick={handleDelete}>
                  削除
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      </div>
    </div>
  );
}
