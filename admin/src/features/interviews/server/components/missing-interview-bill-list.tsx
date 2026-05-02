import type { Route } from "next";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { routes } from "@/lib/routes";
import type { BillWithDietSession } from "@/features/bills/shared/types";
import { CreateDraftInterviewConfigButton } from "../../client/components/create-draft-interview-config-button";

interface MissingInterviewBillListProps {
  bills: BillWithDietSession[];
}

export function MissingInterviewBillList({
  bills,
}: MissingInterviewBillListProps) {
  return (
    <div>
      <div className="mb-2 text-sm text-gray-600">
        {bills.length}件の議案が未設定です
      </div>
      <p className="mb-4 text-sm text-gray-500">
        ここで作成される設定はすべて非公開です。質問やテーマを整えてから、後で公開できます。
      </p>

      {bills.length === 0 ? (
        <div className="rounded-md border border-dashed bg-gray-50 py-8 text-center text-gray-500">
          すべての議案にインタビュー設定があります。
        </div>
      ) : (
        <div className="rounded-md border bg-white">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>議案</TableHead>
                <TableHead>会期</TableHead>
                <TableHead>公開状態</TableHead>
                <TableHead>操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {bills.map((bill) => (
                <TableRow key={bill.id}>
                  <TableCell>
                    <Link
                      href={routes.billEdit(bill.id) as Route}
                      className="font-medium hover:underline"
                    >
                      {bill.name}
                    </Link>
                  </TableCell>
                  <TableCell className="text-gray-600">
                    {bill.diet_sessions?.name || "-"}
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary" className="w-16 justify-center">
                      未設定
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <CreateDraftInterviewConfigButton billId={bill.id} />
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}
    </div>
  );
}
