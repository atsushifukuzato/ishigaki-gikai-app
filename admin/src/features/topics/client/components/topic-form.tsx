"use client";

import type { FormEvent } from "react";
import { useId, useState } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { createTopic } from "../../server/actions/create-topic";
import type { TopicStatus } from "../../shared/types";

export function TopicForm() {
  const slugId = useId();
  const titleId = useId();
  const descriptionId = useId();
  const contentId = useId();
  const statusId = useId();
  const [slug, setSlug] = useState("");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [content, setContent] = useState("");
  const [currentStatusLabel, setCurrentStatusLabel] = useState("");
  const [currentStatusNote, setCurrentStatusNote] = useState("");
  const [status, setStatus] = useState<TopicStatus>("active");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      toast.error("タイトルを入力してください");
      return;
    }
    if (!slug.trim()) {
      toast.error("slugを入力してください");
      return;
    }
    if (!description.trim()) {
      toast.error("概要を入力してください");
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await createTopic({
        slug,
        title,
        description,
        content,
        current_status_label: currentStatusLabel,
        current_status_note: currentStatusNote,
        current_status_updated_at: null,
        status,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("トピックを作成しました");
        setSlug("");
        setTitle("");
        setDescription("");
        setContent("");
        setCurrentStatusLabel("");
        setCurrentStatusNote("");
        setStatus("active");
      }
    } catch (error) {
      console.error("Create topic error:", error);
      toast.error("トピックの作成に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor={titleId}>タイトル</Label>
          <Input
            id={titleId}
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="石垣市庁舎跡地活用"
            disabled={isSubmitting}
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor={slugId}>slug</Label>
          <Input
            id={slugId}
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="ishigaki-old-city-hall"
            disabled={isSubmitting}
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor={descriptionId}>概要</Label>
        <Textarea
          id={descriptionId}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="2〜3行の概要"
          rows={3}
          disabled={isSubmitting}
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor={contentId}>本文</Label>
        <Textarea
          id={contentId}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Markdown 可"
          rows={10}
          disabled={isSubmitting}
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <Label>現在の状況</Label>
          <Input
            value={currentStatusLabel}
            onChange={(e) => setCurrentStatusLabel(e.target.value)}
            placeholder="検討段階"
            disabled={isSubmitting}
          />
        </div>
        <div className="space-y-2">
          <Label>状況メモ</Label>
          <Textarea
            value={currentStatusNote}
            onChange={(e) => setCurrentStatusNote(e.target.value)}
            placeholder="いま何が進行中かを簡潔に記載"
            rows={3}
            disabled={isSubmitting}
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor={statusId}>ステータス</Label>
        <select
          id={statusId}
          value={status}
          onChange={(e) => setStatus(e.target.value as TopicStatus)}
          disabled={isSubmitting}
          className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
        >
          <option value="active">active</option>
          <option value="archived">archived</option>
        </select>
      </div>

      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "作成中..." : "作成"}
      </Button>
    </form>
  );
}
