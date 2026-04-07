import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { routes } from "@/lib/routes";

export default function NotFound() {
  return (
    <Container className="py-24">
      <div className="mx-auto flex max-w-2xl flex-col items-center rounded-3xl border border-slate-200 bg-white px-8 py-16 text-center shadow-sm">
        <p className="text-sm font-bold tracking-[0.12em] text-primary-accent">
          404 NOT FOUND
        </p>
        <h1 className="mt-4 text-3xl font-bold text-slate-900">
          ページが見つかりませんでした
        </h1>
        <p className="mt-4 text-sm leading-7 text-slate-600">
          URLが変わったか、ページが削除された可能性があります。
          <br />
          トップページからもう一度お探しください。
        </p>
        <Link
          href={routes.home()}
          className="mt-8 inline-flex items-center justify-center rounded-full border border-slate-900 px-6 py-3 text-sm font-bold text-slate-900 transition-colors hover:bg-slate-50"
        >
          トップページへ戻る
        </Link>
      </div>
    </Container>
  );
}
