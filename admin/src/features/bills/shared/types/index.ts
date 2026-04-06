import type { Database } from "@mirai-gikai/supabase";

export type Bill = Database["public"]["Tables"]["bills"]["Row"];
export type BillInsert = Database["public"]["Tables"]["bills"]["Insert"];
export type BillUpdate = Database["public"]["Tables"]["bills"]["Update"];

export type BillStatus = Database["public"]["Enums"]["bill_status_enum"];
export type BillPublishStatus =
  Database["public"]["Enums"]["bill_publish_status"];
export type DocumentType = Database["public"]["Enums"]["document_type_enum"];
export type OriginatingHouse = Database["public"]["Enums"]["house_enum"];

export type BillWithContent = Bill & {
  bill_content?: Database["public"]["Tables"]["bill_contents"]["Row"];
};

export type BillWithDietSession = Bill & {
  diet_sessions: { name: string } | null;
};

import type { SortConfig } from "@/lib/sort";

// ソート関連の型定義
export type BillSortField =
  | "created_at"
  | "published_at"
  | "status_order"
  | "publish_status_order";

export const BILL_SORT_FIELDS: readonly BillSortField[] = [
  "created_at",
  "published_at",
  "status_order",
  "publish_status_order",
] as const;

export type BillSortConfig = SortConfig<BillSortField>;

export const DEFAULT_BILL_SORT: BillSortConfig = {
  field: "created_at",
  order: "desc",
};

// ステータスのソート順（DBのstatus_order generated columnと一致させる）
export const BILL_STATUS_ORDER: Record<BillStatus, number> = {
  enacted: 0,
  rejected: 1,
  in_receiving_house: 2,
  in_originating_house: 3,
  introduced: 4,
  preparing: 5,
};

// House display mapping
export const HOUSE_LABELS: Record<OriginatingHouse, string> = {
  HR: "石垣市議会",
  HC: "参議院",
};

export const DOCUMENT_TYPE_LABELS: Record<DocumentType, string> = {
  bill: "議案",
  speech: "演説",
  report: "報告",
  consent: "同意",
  approval: "承認",
};

function getNonBillStatusLabel(
  status: BillStatus,
  documentType: Exclude<DocumentType, "bill">
): string {
  switch (documentType) {
    case "speech":
    case "report":
      switch (status) {
        case "preparing":
          return "準備中";
        case "introduced":
          return "公開済み";
        default:
          return "公開済み";
      }
    case "consent":
      switch (status) {
        case "preparing":
          return "準備中";
        case "introduced":
          return "提出済み";
        case "in_originating_house":
        case "in_receiving_house":
          return "審査中";
        case "enacted":
          return "同意済み";
        case "rejected":
          return "不同意";
        default:
          return status;
      }
    case "approval":
      switch (status) {
        case "preparing":
          return "準備中";
        case "introduced":
          return "提出済み";
        case "in_originating_house":
        case "in_receiving_house":
          return "審査中";
        case "enacted":
          return "承認済み";
        case "rejected":
          return "不承認";
        default:
          return status;
      }
  }
}

// ステータスを日本語ラベルに変換する関数
export function getBillStatusLabel(
  status: BillStatus,
  originatingHouse?: OriginatingHouse | null,
  documentType: DocumentType = "bill"
): string {
  if (documentType !== "bill") {
    return getNonBillStatusLabel(status, documentType);
  }

  switch (status) {
    case "preparing":
      return "準備中";
    case "introduced":
      return "提出済み";
    case "in_originating_house":
      if (originatingHouse) {
        return `${HOUSE_LABELS[originatingHouse]}審議中`;
      }
      return "審議中";
    case "in_receiving_house":
      if (originatingHouse) {
        const receivingHouse = originatingHouse === "HR" ? "HC" : "HR";
        return `${HOUSE_LABELS[receivingHouse]}審議中`;
      }
      return "審議中";
    case "enacted":
      return "成立";
    case "rejected":
      return "否決";
    default:
      return status;
  }
}
