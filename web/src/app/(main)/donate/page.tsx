import type { Metadata } from "next";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { routes } from "@/lib/routes";

export const metadata: Metadata = {
  title: "寄付で応援する | みらい議会 石垣市議会版",
  description: "AFTTT による石垣市議会版みらい議会の寄付案内ページ",
};

const supportOptions = [
  {
    title: "単発で応援する",
    description:
      "まずは少額から応援したい方向けの寄付枠です。公開情報の整理、要約、運用改善などの継続に活用します。",
  },
  {
    title: "毎月応援する",
    description:
      "継続的に支えたい方向けの寄付枠です。安定した更新、議案整理、改善作業の土台になります。",
  },
] as const;

export default function DonatePage() {
  return (
    <Container className="py-10 md:py-14">
      <div className="mx-auto flex max-w-4xl flex-col gap-10">
        <header className="space-y-4">
          <p className="text-sm font-bold tracking-[0.08em] text-primary-accent">
            DONATE
          </p>
          <div className="space-y-4">
            <h1 className="text-4xl font-extrabold tracking-[0.02em] text-slate-900">
              寄付で応援する
            </h1>
            <p className="max-w-3xl text-[15px] leading-8 text-slate-700">
              石垣市議会版みらい議会は、AFTTT
              が公開情報を整理し、市民のみなさんが議会を見やすくするために運営しています。今後は
              Stripe
              を利用した寄付導線の整備を予定しており、現在このページを準備中です。
            </p>
          </div>
        </header>

        <section className="grid gap-5 md:grid-cols-2">
          {supportOptions.map((option) => (
            <article
              key={option.title}
              className="flex flex-col gap-4 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm"
            >
              <div className="space-y-2">
                <h2 className="text-2xl font-bold text-slate-900">
                  {option.title}
                </h2>
                <p className="text-sm leading-7 text-slate-600">
                  {option.description}
                </p>
              </div>
              <div className="inline-flex w-fit rounded-full border border-slate-300 bg-slate-50 px-4 py-2 text-sm font-bold text-slate-700">
                Stripe 連携準備中
              </div>
            </article>
          ))}
        </section>

        <section className="rounded-3xl border border-slate-200 bg-slate-50 px-6 py-7">
          <div className="space-y-3">
            <h2 className="text-xl font-bold text-slate-900">寄付金の使い道</h2>
            <p className="text-sm leading-7 text-slate-600">
              いただいたご支援は、議案データの整理、説明文の改善、議員名簿や周辺情報の整備、サイトの保守運用などに活用する予定です。
            </p>
          </div>
        </section>

        <section className="rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-7">
          <div className="space-y-3">
            <h2 className="text-xl font-bold text-slate-900">
              現在のご案内について
            </h2>
            <p className="text-sm leading-7 text-slate-600">
              決済ページの準備が整い次第、このページに Stripe
              の寄付リンクを掲載します。税控除の有無や領収書の扱いなど、寄付に関する条件もその際に明記します。
            </p>
          </div>
        </section>

        <div>
          <Link
            href={routes.home()}
            className="inline-flex items-center justify-center rounded-full border border-slate-900 px-6 py-3 text-sm font-bold text-slate-900 transition-colors hover:bg-slate-50"
          >
            トップページへ戻る
          </Link>
        </div>
      </div>
    </Container>
  );
}
