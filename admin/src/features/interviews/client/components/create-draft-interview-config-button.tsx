"use client";

import type { Route } from "next";
import { FilePlus2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useTransition } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { createDraftInterviewConfig } from "../../server/actions/create-draft-interview-config";

interface CreateDraftInterviewConfigButtonProps {
  billId: string;
}

export function CreateDraftInterviewConfigButton({
  billId,
}: CreateDraftInterviewConfigButtonProps) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const handleClick = () => {
    startTransition(async () => {
      const result = await createDraftInterviewConfig(billId);

      if (!result.success) {
        toast.error(result.error || "下書き設定の作成に失敗しました");
        return;
      }

      toast.success("非公開の下書きインタビュー設定を作成しました");
      router.push(result.data.editPath as Route);
      router.refresh();
    });
  };

  return (
    <Button
      size="sm"
      variant="outline"
      onClick={handleClick}
      disabled={isPending}
    >
      <FilePlus2 className="mr-1 h-4 w-4" />
      {isPending ? "作成中..." : "下書きを作成"}
    </Button>
  );
}
