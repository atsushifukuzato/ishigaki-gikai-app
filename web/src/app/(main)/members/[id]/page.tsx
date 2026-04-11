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
import { formatBillDietSessionLabel } from "@/features/bills/shared/utils/diet-session-label";
import { getMemberById } from "@/features/members/server/repositories/member-repository";
import { routes } from "@/lib/routes";

const SOCIAL_ICON_MAP = {
  x: {
    name: "X",
    iconPath: "/icons/sns/icon_x.png",
    hasBorder: false,
  },
  facebook: {
    name: "Facebook",
    iconPath: "/icons/sns/icon_facebook.png",
    hasBorder: false,
  },
  instagram: {
    name: "Instagram",
    iconPath: "/icons/sns/icon_instagram.png",
    hasBorder: true,
  },
  threads: {
    name: "Threads",
    iconPath: "/icons/sns/icon_threads.png",
    hasBorder: true,
  },
} as const;

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

function SocialIconLink({
  href,
  name,
  iconPath,
  hasBorder,
}: {
  href: string;
  name: string;
  iconPath: string;
  hasBorder: boolean;
}) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noreferrer"
      aria-label={name}
      className="transition-opacity hover:opacity-70"
    >
      <Image
        src={iconPath}
        alt={name}
        width={36}
        height={36}
        className={
          hasBorder ? "rounded-full border border-mirai-border-light" : ""
        }
      />
    </a>
  );
}

function groupBillsByDietSession(bills: BillWithContent[]) {
  const grouped = new Map<
    string,
    { label: string; bills: BillWithContent[] }
  >();

  for (const bill of bills) {
    const label = formatBillDietSessionLabel(bill.diet_session) || "会期未設定";
    const existing = grouped.get(label);

    if (existing) {
      existing.bills.push(bill);
      continue;
    }

    grouped.set(label, { label, bills: [bill] });
  }

  return Array.from(grouped.values());
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

  const proposerBillGroups = groupBillsByDietSession(proposerBills);
  const twitterUrl =
    typeof member.twitter_url === "string" ? member.twitter_url.trim() : "";
  const facebookUrl =
    typeof member.facebook_url === "string" ? member.facebook_url.trim() : "";
  const instagramUrl =
    typeof member.instagram_url === "string" ? member.instagram_url.trim() : "";
  const threadsUrl =
    typeof member.threads_url === "string" ? member.threads_url.trim() : "";

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

          {(twitterUrl || facebookUrl || instagramUrl || threadsUrl) && (
            <div className="rounded-[32px] border border-slate-200 bg-white p-6 shadow-sm">
              <div className="space-y-4">
                <h2 className="text-xl font-bold text-slate-900">SNS</h2>
                <div className="flex flex-wrap gap-3">
                  {twitterUrl ? (
                    <SocialIconLink
                      href={twitterUrl}
                      name={SOCIAL_ICON_MAP.x.name}
                      iconPath={SOCIAL_ICON_MAP.x.iconPath}
                      hasBorder={SOCIAL_ICON_MAP.x.hasBorder}
                    />
                  ) : null}
                  {facebookUrl ? (
                    <SocialIconLink
                      href={facebookUrl}
                      name={SOCIAL_ICON_MAP.facebook.name}
                      iconPath={SOCIAL_ICON_MAP.facebook.iconPath}
                      hasBorder={SOCIAL_ICON_MAP.facebook.hasBorder}
                    />
                  ) : null}
                  {instagramUrl ? (
                    <SocialIconLink
                      href={instagramUrl}
                      name={SOCIAL_ICON_MAP.instagram.name}
                      iconPath={SOCIAL_ICON_MAP.instagram.iconPath}
                      hasBorder={SOCIAL_ICON_MAP.instagram.hasBorder}
                    />
                  ) : null}
                  {threadsUrl ? (
                    <SocialIconLink
                      href={threadsUrl}
                      name={SOCIAL_ICON_MAP.threads.name}
                      iconPath={SOCIAL_ICON_MAP.threads.iconPath}
                      hasBorder={SOCIAL_ICON_MAP.threads.hasBorder}
                    />
                  ) : null}
                </div>
              </div>
            </div>
          )}

          <div className="rounded-[32px] border border-slate-200 bg-white p-6 shadow-sm">
            <div className="space-y-4">
              <h2 className="text-xl font-bold text-slate-900">提出した議案</h2>
              {proposerBillGroups.length > 0 ? (
                <div className="space-y-6">
                  {proposerBillGroups.map((group) => (
                    <section key={group.label} className="space-y-3">
                      <h3 className="text-sm font-bold text-primary-accent">
                        {group.label}
                      </h3>
                      <div className="space-y-3">
                        {group.bills.map((bill: BillWithContent) => (
                          <Link
                            key={bill.id}
                            href={routes.billDetail(bill.id) as Route}
                            className="block rounded-2xl focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
                          >
                            <CompactBillCard bill={bill} />
                          </Link>
                        ))}
                      </div>
                    </section>
                  ))}
                </div>
              ) : null}
            </div>
          </div>
        </div>
      </Container>
    </div>
  );
}
