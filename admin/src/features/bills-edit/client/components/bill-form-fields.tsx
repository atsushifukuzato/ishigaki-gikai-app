"use client";

import { useEffect } from "react";
import { useFormContext, useWatch, type Control } from "react-hook-form";
import { Checkbox } from "@/components/ui/checkbox";
import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import {
  DOCUMENT_TYPE_LABELS,
  type BillStatus,
  type DocumentType,
} from "@/features/bills/shared/types";
import type { DietSession } from "@/features/diet-sessions/shared/types";
import type { BillCreateInput } from "../../shared/types";
import { ThumbnailUpload } from "./thumbnail-upload";

const BILL_STATUS_OPTIONS: Array<{ value: BillStatus; label: string }> = [
  { value: "preparing", label: "準備中" },
  { value: "introduced", label: "提出済み" },
  { value: "in_originating_house", label: "審議中（提出議会）" },
  { value: "in_receiving_house", label: "審議中（送付院）" },
  { value: "enacted", label: "成立" },
  { value: "rejected", label: "否決" },
];

const DOCUMENT_TYPE_OPTIONS: Array<{
  value: DocumentType;
  label: string;
}> = Object.entries(DOCUMENT_TYPE_LABELS).map(([value, label]) => ({
  value: value as DocumentType,
  label,
}));

const DOCUMENT_STATUS_OPTIONS: Record<
  DocumentType,
  Array<{ value: BillStatus; label: string }>
> = {
  bill: BILL_STATUS_OPTIONS,
  speech: [
    { value: "preparing", label: "準備中" },
    { value: "introduced", label: "公開済み" },
  ],
  report: [
    { value: "preparing", label: "準備中" },
    { value: "introduced", label: "公開済み" },
  ],
  consent: [
    { value: "preparing", label: "準備中" },
    { value: "introduced", label: "提出済み" },
    { value: "in_originating_house", label: "審査中" },
    { value: "enacted", label: "同意済み" },
    { value: "rejected", label: "不同意" },
  ],
  approval: [
    { value: "preparing", label: "準備中" },
    { value: "introduced", label: "提出済み" },
    { value: "in_originating_house", label: "審査中" },
    { value: "enacted", label: "承認済み" },
    { value: "rejected", label: "不承認" },
  ],
};

interface BillFormFieldsProps {
  control: Control<BillCreateInput>;
  billId?: string;
  dietSessions: DietSession[];
}

export function BillFormFields({
  control,
  billId,
  dietSessions,
}: BillFormFieldsProps) {
  const form = useFormContext<BillCreateInput>();
  const documentType = useWatch({
    control,
    name: "document_type",
    defaultValue: "bill",
  });
  const status = useWatch({
    control,
    name: "status",
  });
  const currentStatusOptions = DOCUMENT_STATUS_OPTIONS[documentType ?? "bill"];

  useEffect(() => {
    form.setValue("originating_house", "HR", {
      shouldDirty: false,
      shouldValidate: false,
    });
  }, [form]);

  useEffect(() => {
    const allowedStatuses = currentStatusOptions.map((option) => option.value);

    if (status && allowedStatuses.includes(status)) {
      return;
    }

    form.setValue("status", currentStatusOptions[0].value, {
      shouldDirty: true,
      shouldValidate: true,
    });
  }, [currentStatusOptions, form, status]);

  return (
    <>
      <FormField
        control={control}
        name="name"
        render={({ field }) => (
          <FormItem>
            <FormLabel>議案名 *</FormLabel>
            <FormControl>
              <Input {...field} />
            </FormControl>
            <FormDescription>
              議案の正式名称を入力してください（最大200文字）
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <FormField
          control={control}
          name="document_type"
          render={({ field }) => (
            <FormItem>
              <FormLabel>種別 *</FormLabel>
              <Select
                onValueChange={field.onChange}
                value={field.value ?? "bill"}
                defaultValue="bill"
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="種別を選択" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {DOCUMENT_TYPE_OPTIONS.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <FormDescription>
                作成するコンテンツの種別を選択してください
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={control}
          name="status"
          render={({ field }) => (
            <FormItem>
              <FormLabel>ステータス *</FormLabel>
              <Select
                onValueChange={field.onChange}
                value={field.value}
                defaultValue={field.value}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="ステータスを選択" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {currentStatusOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <FormDescription>
                種別に応じた進行状況を選択してください
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={control}
          name="originating_house"
          render={({ field }) => (
            <FormItem>
              <FormLabel>提出議会 *</FormLabel>
              <FormControl>
                <Input value="石垣市議会" readOnly />
              </FormControl>
              <input type="hidden" {...field} value="HR" />
              <FormDescription>
                議案を提出した機関を選択してください
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
      </div>

      <FormField
        control={control}
        name="status_note"
        render={({ field }) => (
          <FormItem>
            <FormLabel>ステータス備考</FormLabel>
            <FormControl>
              <Textarea
                {...field}
                value={field.value || ""}
                className="min-h-[100px]"
              />
            </FormControl>
            <FormDescription>
              審議状況の詳細や補足情報を入力してください（最大500文字）
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="published_at"
        render={({ field }) => (
          <FormItem>
            <FormLabel>公開日時 *</FormLabel>
            <FormControl>
              <Input type="datetime-local" {...field} />
            </FormControl>
            <FormDescription>
              議案が公開される日時を設定してください
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="thumbnail_url"
        render={({ field }) => (
          <FormItem>
            <FormLabel>サムネイル画像</FormLabel>
            <FormControl>
              <ThumbnailUpload
                value={field.value}
                onChange={field.onChange}
                billId={billId}
              />
            </FormControl>
            <FormDescription>
              議案のサムネイル画像を設定してください（任意）
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="share_thumbnail_url"
        render={({ field }) => (
          <FormItem>
            <FormLabel>シェア用OGP画像</FormLabel>
            <FormControl>
              <ThumbnailUpload
                value={field.value}
                onChange={field.onChange}
                billId={billId}
                storagePrefix="share"
              />
            </FormControl>
            <FormDescription>
              Twitter等のSNSでシェアされた際に表示される画像を設定してください（任意）。設定しない場合はサムネイル画像が使用されます。
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="shugiin_url"
        render={({ field }) => (
          <FormItem>
            <FormLabel>石垣市議会URL</FormLabel>
            <FormControl>
              <Input
                {...field}
                value={field.value || ""}
                placeholder="https://www.shugiin.go.jp/..."
              />
            </FormControl>
            <FormDescription>
              石垣市議会の議案ページURLを入力してください（「これから掲載される議案」表示時に外部リンクとして使用）
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="diet_session_id"
        render={({ field }) => (
          <FormItem>
            <FormLabel>議会会期</FormLabel>
            <Select
              onValueChange={field.onChange}
              value={field.value ?? undefined}
            >
              <FormControl>
                <SelectTrigger>
                  <SelectValue placeholder="議会会期を選択" />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                {dietSessions.map((session) => (
                  <SelectItem key={session.id} value={session.id}>
                    {session.name}（{session.start_date}〜{session.end_date}）
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <FormDescription>
              議案が提出された議会会期を選択してください
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="is_featured"
        render={({ field }) => (
          <FormItem className="flex flex-row items-start space-x-3 space-y-0 rounded-md border p-4">
            <FormControl>
              <Checkbox
                checked={field.value}
                onCheckedChange={field.onChange}
              />
            </FormControl>
            <div className="space-y-1 leading-none">
              <FormLabel>注目の議案</FormLabel>
              <FormDescription>
                トップページなどで優先的に表示されます
              </FormDescription>
            </div>
          </FormItem>
        )}
      />
    </>
  );
}
