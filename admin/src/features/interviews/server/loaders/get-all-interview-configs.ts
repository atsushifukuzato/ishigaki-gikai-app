import "server-only";

import type { BillWithDietSession } from "@/features/bills/shared/types";
import { getBills } from "@/features/bills/server/loaders/get-bills";
import {
  findAllInterviewConfigs,
  type InterviewConfigWithBill,
} from "@/features/interview-config/server/repositories/interview-config-repository";
import { countAllSessionsByConfigId } from "@/features/interview-config/server/repositories/interview-config-repository";

export async function getAllInterviewConfigs(): Promise<
  InterviewConfigWithBill[]
> {
  try {
    return await findAllInterviewConfigs();
  } catch (error) {
    console.error("Failed to fetch all interview configs:", error);
    return [];
  }
}

export async function getAllSessionCounts(): Promise<Record<
  string,
  number
> | null> {
  try {
    return await countAllSessionsByConfigId();
  } catch (error) {
    console.error("Failed to fetch session counts:", error);
    return null;
  }
}

export function filterBillsWithoutInterviewConfigs(
  bills: BillWithDietSession[],
  configs: InterviewConfigWithBill[]
): BillWithDietSession[] {
  const configuredBillIds = new Set(configs.map((config) => config.bill_id));

  return bills.filter(
    (bill) => bill.document_type === "bill" && !configuredBillIds.has(bill.id)
  );
}

export async function getBillsWithoutInterviewConfigs(): Promise<
  BillWithDietSession[]
> {
  try {
    const [bills, configs] = await Promise.all([
      getBills(),
      findAllInterviewConfigs(),
    ]);

    return filterBillsWithoutInterviewConfigs(bills, configs);
  } catch (error) {
    console.error("Failed to fetch bills without interview configs:", error);
    return [];
  }
}
