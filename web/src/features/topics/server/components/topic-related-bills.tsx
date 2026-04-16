import "server-only";
import type { Route } from "next";
import Link from "next/link";
import { CompactBillCard } from "@/features/bills/client/components/bill-list/compact-bill-card";
import type { BillWithContent } from "@/features/bills/shared/types";
import { routes } from "@/lib/routes";

interface TopicRelatedBillsProps {
  bills: BillWithContent[];
}

export function TopicRelatedBills({ bills }: TopicRelatedBillsProps) {
  return (
    <section className="space-y-4">
      <div className="space-y-1">
        <h2 className="text-[22px] font-bold text-slate-900">関連議案一覧</h2>
        <p className="text-sm text-slate-500">{bills.length}件の公開済み議案</p>
      </div>

      <p className="text-sm leading-7 text-slate-500">
        議案そのものの内容に加えて、提出状況や会期もあわせて確認すると、
        このテーマが議会の中でどう進んでいるか追いやすくなります。
      </p>

      {bills.length > 0 ? (
        <div className="space-y-4">
          {bills.map((bill) => (
            <Link key={bill.id} href={routes.billDetail(bill.id) as Route}>
              <CompactBillCard bill={bill} />
            </Link>
          ))}
        </div>
      ) : (
        <div className="rounded-2xl border border-dashed border-slate-300 px-5 py-8 text-center text-slate-500">
          現在、このトピックに紐づく公開済み議案はありません。
        </div>
      )}
    </section>
  );
}
