import type { Metadata } from "next";
import type { Route } from "next";
import type { ReactNode } from "react";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, MapPin, Shield, Users } from "lucide-react";
import { Container } from "@/components/layouts/container";
import { CompactBillCard } from "@/features/bills/client/components/bill-list/compact-bill-card";
import { getBillsByProposerMember } from "@/features/bills/server/loaders/get-bills-by-proposer-member";
import type { BillWithContent } from "@/features/bills/shared/types";
import { getMemberById } from "@/features/members/server/repositories/member-repository";
import { routes } from "@/lib/routes";

interface MemberDetailPageProps {
  params: Promise<{
    id: string;
  }>;
}

function formatBirthDate(value: string | null) {
  if (!value) return "未登録";

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "未登録";

  return `${date.getFullYear()}年生`;
}

function formatElectionCount(value: number | null) {
  if (value == null) return "未登録";
  return `当選${value}回`;
}

function MemberInfoItem({
  label,
  value,
  icon,
}: {
  label: string;
  value: string;
  icon: ReactNode;
}) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-4">
      <div className="flex items-start gap-3">
        <div className="mt-1 text-primary">{icon}</div>
        <div className="space-y-1">
          <p className="text-xs font-bold uppercase tracking-[0.08em] text-slate-400">
            {label}
          </p>
          <p className="text-sm leading-6 text-slate-700">{value}</p>
        </div>
      </div>
    </div>
  );
}

function SocialLink({ href, label }: { href: string; label: string }) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noreferrer"
      className="inline-flex items-center rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition-opacity hover:opacity-70"
    >
      {label}
    </a>
  );
}

export async function generateMetadata({
  params,
}: MemberDetailPageProps): Promise<Metadata> {
  const { id } = await params;
  const member = await getMemberById(id);

  if (!member) {
    return {
      title: "議員が見つかりません",
    };
  }

  return {
    title: `${member.name} | 議員名簿 | みらい議会 石垣市議会版`,
    description: `${member.name}議員の所属政党、会派、当選回数などの情報です。`,
  };
}

export default async function MemberDetailPage({
  params,
}: MemberDetailPageProps) {
  const { id } = await params;
  const [member, proposerBills] = await Promise.all([
    getMemberById(id),
    getBillsByProposerMember(id),
  ]);

  if (!member) {
    notFound();
  }

  return (
    <div
      className="py-10"
      style={{
        backgroundImage: "linear-gradient(#e2f6f3, #eef6e2)",
      }}
    >
      <Container>
        <div className="flex flex-col gap-8">
          <div className="space-y-4">
            <Link
              href={routes.members()}
              className="inline-flex items-center gap-2 text-sm font-medium text-slate-600 transition-opacity hover:opacity-70"
            >
              <ArrowLeft className="h-4 w-4" />
              議員名簿に戻る
            </Link>

            <div className="rounded-[32px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
                <div className="space-y-3">
                  <div className="inline-flex rounded-full bg-white px-3 py-1 text-xs font-bold text-slate-700 shadow-sm ring-1 ring-slate-200">
                    {formatElectionCount(member.election_count)}
                  </div>
                  <div className="space-y-1">
                    <h1 className="text-3xl font-extrabold tracking-[0.02em] text-slate-900">
                      {member.name}
                    </h1>
                    <p className="text-sm font-medium text-slate-500">
                      {member.name_kana || "ふりがな未登録"}
                    </p>
                  </div>
                </div>

                {member.image_url ? (
                  <div className="relative h-28 w-28 overflow-hidden rounded-3xl border border-slate-200 bg-slate-50">
                    <Image
                      src={member.image_url}
                      alt={member.name}
                      fill
                      className="object-cover"
                      sizes="112px"
                    />
                  </div>
                ) : null}
              </div>
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <MemberInfoItem
              label="政党"
              value={member.party || "未登録"}
              icon={<Shield className="h-4 w-4" />}
            />
            <MemberInfoItem
              label="会派"
              value={member.party_group || "未登録"}
              icon={<Users className="h-4 w-4" />}
            />
            <MemberInfoItem
              label="住所"
              value={member.address || "未登録"}
              icon={<MapPin className="h-4 w-4" />}
            />
            <MemberInfoItem
              label="生年"
              value={formatBirthDate(member.birth_date)}
              icon={<Users className="h-4 w-4" />}
            />
          </div>

          {(member.twitter_url ||
            member.facebook_url ||
            member.instagram_url ||
            member.threads_url) && (
            <div className="rounded-[32px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="space-y-4">
                <h2 className="text-xl font-bold text-slate-900">SNS</h2>
                <div className="flex flex-wrap gap-3">
                  {member.twitter_url ? (
                    <SocialLink href={member.twitter_url} label="X" />
                  ) : null}
                  {member.facebook_url ? (
                    <SocialLink href={member.facebook_url} label="Facebook" />
                  ) : null}
                  {member.instagram_url ? (
                    <SocialLink href={member.instagram_url} label="Instagram" />
                  ) : null}
                  {member.threads_url ? (
                    <SocialLink href={member.threads_url} label="Threads" />
                  ) : null}
                </div>
              </div>
            </div>
          )}

          {proposerBills.length > 0 && (
            <div className="rounded-[32px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="space-y-4">
                <h2 className="text-xl font-bold text-slate-900">
                  提出した議案
                </h2>
                <div className="space-y-3">
                  {proposerBills.map((bill: BillWithContent) => (
                    <Link
                      key={bill.id}
                      href={routes.billDetail(bill.id) as Route}
                      className="block rounded-2xl focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
                    >
                      <CompactBillCard bill={bill} />
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </Container>
    </div>
  );
}
