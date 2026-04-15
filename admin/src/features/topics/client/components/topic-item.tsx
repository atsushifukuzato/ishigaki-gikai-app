"use client";

import type { Route } from "next";
import Link from "next/link";
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
import { getBillStatusLabel } from "@/features/bills/shared/types";
import { routes } from "@/lib/routes";
import { attachTopicBill } from "../../server/actions/attach-topic-bill";
import { deleteTopic } from "../../server/actions/delete-topic";
import { detachTopicBill } from "../../server/actions/detach-topic-bill";
import { updateTopic } from "../../server/actions/update-topic";
import type {
  TopicBillOption,
  TopicStatus,
  TopicWithBillCount,
} from "../../shared/types";
import { TopicUpdateForm } from "./topic-update-form";
import { TopicUpdateItem } from "./topic-update-item";

type TopicItemProps = {
  topic: TopicWithBillCount;
  billOptions: TopicBillOption[];
};

export function TopicItem({ topic, billOptions }: TopicItemProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [slug, setSlug] = useState(topic.slug);
  const [title, setTitle] = useState(topic.title);
  const [description, setDescription] = useState(topic.description);
  const [content, setContent] = useState(topic.content);
  const [currentStatusLabel, setCurrentStatusLabel] = useState(
    topic.current_status_label ?? ""
  );
  const [currentStatusNote, setCurrentStatusNote] = useState(
    topic.current_status_note ?? ""
  );
  const [status, setStatus] = useState<TopicStatus>(topic.status);
  const [billSearchQuery, setBillSearchQuery] = useState("");
  const [selectedBillId, setSelectedBillId] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const availableBillOptions = billOptions.filter(
    (bill) =>
      !topic.related_bills.some((relatedBill) => relatedBill.id === bill.id)
  );
  const normalizedBillSearchQuery = billSearchQuery.trim().toLowerCase();
  const filteredBillOptions = availableBillOptions.filter((bill) => {
    if (!normalizedBillSearchQuery) {
      return true;
    }

    return [
      bill.name,
      bill.diet_session_name ?? "",
      getBillStatusLabel(bill.status),
      bill.publish_status,
    ]
      .join(" ")
      .toLowerCase()
      .includes(normalizedBillSearchQuery);
  });

  const handleUpdate = async () => {
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
      const result = await updateTopic({
        id: topic.id,
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
        toast.success("トピックを更新しました");
        setIsEditing(false);
      }
    } catch (error) {
      console.error("Update topic error:", error);
      toast.error("トピックの更新に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    setIsSubmitting(true);

    try {
      const result = await deleteTopic({ id: topic.id });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("トピックを削除しました");
      }
    } catch (error) {
      console.error("Delete topic error:", error);
      toast.error("トピックの削除に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleAttachBill = async () => {
    if (!selectedBillId) {
      toast.error("紐づける議案を選択してください");
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await attachTopicBill({
        topic_id: topic.id,
        bill_id: selectedBillId,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("関連議案を追加しました");
        setBillSearchQuery("");
        setSelectedBillId("");
      }
    } catch (error) {
      console.error("Attach topic bill error:", error);
      toast.error("関連議案の追加に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDetachBill = async (billId: string) => {
    setIsSubmitting(true);

    try {
      const result = await detachTopicBill({
        topic_id: topic.id,
        bill_id: billId,
      });

      if (result.error) {
        toast.error(result.error);
      } else {
        toast.success("関連議案を解除しました");
      }
    } catch (error) {
      console.error("Detach topic bill error:", error);
      toast.error("関連議案の解除に失敗しました");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancel = () => {
    setSlug(topic.slug);
    setTitle(topic.title);
    setDescription(topic.description);
    setContent(topic.content);
    setCurrentStatusLabel(topic.current_status_label ?? "");
    setCurrentStatusNote(topic.current_status_note ?? "");
    setStatus(topic.status);
    setIsEditing(false);
  };

  if (isEditing) {
    return (
      <div className="rounded-lg border p-4">
        <div className="space-y-4">
          <div className="rounded-lg border border-dashed p-4">
            <div className="space-y-3">
              <div>
                <h4 className="font-semibold">関連議案</h4>
                <p className="text-sm text-gray-500">
                  Topics 詳細ページに表示する議案を管理します。
                </p>
              </div>
              {topic.related_bills.length > 0 ? (
                <div className="space-y-2">
                  {topic.related_bills.map((bill) => (
                    <div
                      key={bill.id}
                      className="flex items-center justify-between gap-3 rounded-md border bg-white px-3 py-2"
                    >
                      <div className="min-w-0 space-y-1">
                        <p className="truncate text-sm font-medium">
                          {bill.name}
                        </p>
                        <p className="text-xs text-gray-500">
                          {getBillStatusLabel(bill.status)} /{" "}
                          {bill.diet_session_name ?? "会期情報なし"}
                        </p>
                      </div>
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={isSubmitting}
                        onClick={() => handleDetachBill(bill.bill_id)}
                      >
                        解除
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-gray-500">
                  まだ関連議案は紐づいていません。
                </p>
              )}
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label>タイトル</Label>
              <Input
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                disabled={isSubmitting}
              />
            </div>
            <div className="space-y-2">
              <Label>slug</Label>
              <Input
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                disabled={isSubmitting}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>概要</Label>
            <Textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              disabled={isSubmitting}
            />
          </div>

          <div className="space-y-2">
            <Label>本文</Label>
            <Textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
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
                disabled={isSubmitting}
              />
            </div>
            <div className="space-y-2">
              <Label>状況メモ</Label>
              <Textarea
                value={currentStatusNote}
                onChange={(e) => setCurrentStatusNote(e.target.value)}
                rows={3}
                disabled={isSubmitting}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>ステータス</Label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value as TopicStatus)}
              disabled={isSubmitting}
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
            >
              <option value="active">active</option>
              <option value="archived">archived</option>
            </select>
          </div>

          <div className="flex gap-2">
            <Button onClick={handleUpdate} disabled={isSubmitting}>
              {isSubmitting ? "保存中..." : "保存"}
            </Button>
            <Button
              variant="outline"
              onClick={handleCancel}
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
        <div className="flex-1 space-y-2">
          <div className="flex flex-wrap items-center gap-2">
            <h3 className="font-semibold">{topic.title}</h3>
            <span className="rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-600">
              {topic.status}
            </span>
            <span className="rounded bg-blue-100 px-2 py-0.5 text-xs text-blue-700">
              関連議案 {topic.bill_count}件
            </span>
          </div>
          <p className="text-sm text-gray-500">/{topic.slug}</p>
          {topic.current_status_label ? (
            <p className="text-sm font-semibold text-blue-700">
              現在: {topic.current_status_label}
            </p>
          ) : null}
          <p className="text-sm text-gray-700 whitespace-pre-wrap">
            {topic.description}
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
                <AlertDialogTitle>トピックの削除</AlertDialogTitle>
                <AlertDialogDescription>
                  このトピックを削除しますか？紐づいている topic_bills
                  も削除されます。
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

      <div className="mt-4 space-y-4 border-t pt-4">
        <div className="space-y-3">
          <div>
            <h4 className="font-semibold">関連議案</h4>
            <p className="text-sm text-gray-500">
              紐づけた議案は Topics 詳細ページにも表示されます。
            </p>
          </div>

          <div className="flex flex-col gap-2 md:flex-row">
            <Input
              value={billSearchQuery}
              onChange={(e) => setBillSearchQuery(e.target.value)}
              placeholder="議案名・会期名で絞り込み"
              disabled={isSubmitting || availableBillOptions.length === 0}
            />
            <select
              value={selectedBillId}
              onChange={(e) => setSelectedBillId(e.target.value)}
              disabled={isSubmitting || filteredBillOptions.length === 0}
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
            >
              <option value="">
                {filteredBillOptions.length > 0
                  ? "議案を選択"
                  : availableBillOptions.length > 0
                    ? "条件に合う議案がありません"
                    : "追加できる議案がありません"}
              </option>
              {filteredBillOptions.map((bill) => (
                <option key={bill.id} value={bill.id}>
                  {bill.name}
                  {bill.diet_session_name ? ` / ${bill.diet_session_name}` : ""}
                </option>
              ))}
            </select>
            <Button
              onClick={handleAttachBill}
              disabled={
                isSubmitting ||
                !selectedBillId ||
                filteredBillOptions.length === 0
              }
            >
              追加
            </Button>
          </div>

          {topic.related_bills.length > 0 ? (
            <div className="space-y-2">
              {topic.related_bills.map((bill) => (
                <div
                  key={bill.id}
                  className="flex flex-col gap-3 rounded-lg border bg-gray-50 px-3 py-3 md:flex-row md:items-center md:justify-between"
                >
                  <div className="min-w-0 space-y-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <p className="font-medium">{bill.name}</p>
                      <span className="rounded bg-gray-200 px-2 py-0.5 text-xs text-gray-700">
                        {getBillStatusLabel(bill.status)}
                      </span>
                      <span className="rounded bg-white px-2 py-0.5 text-xs text-gray-600">
                        {bill.publish_status}
                      </span>
                    </div>
                    <p className="text-sm text-gray-500">
                      {bill.diet_session_name ?? "会期情報なし"}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Button asChild variant="outline" size="sm">
                      <Link href={routes.billEdit(bill.bill_id) as Route}>
                        議案を開く
                      </Link>
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      disabled={isSubmitting}
                      onClick={() => handleDetachBill(bill.bill_id)}
                    >
                      解除
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500">
              まだ関連議案は紐づいていません。
            </p>
          )}
        </div>

        <div className="space-y-2">
          <h4 className="font-semibold">更新履歴</h4>
          {topic.updates.length > 0 ? (
            <div className="space-y-2">
              {topic.updates.map((update) => (
                <TopicUpdateItem key={update.id} update={update} />
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500">更新履歴はまだありません</p>
          )}
        </div>

        <div className="space-y-2">
          <h4 className="font-semibold">更新履歴を追加</h4>
          <TopicUpdateForm topicId={topic.id} />
        </div>
      </div>
    </div>
  );
}
