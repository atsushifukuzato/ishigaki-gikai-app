import Image from "next/image";
import type { Route } from "next";
import { MapPin, Shield, Users } from "lucide-react";
import Link from "next/link";
import type { Member } from "@/features/members/shared/types";
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

function formatBirthDate(value: string | null) {
  if (!value) return null;

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;

  const year = date.getFullYear();

  return `${year}年生`;
}

function formatElectionCount(value: number | null) {
  if (value == null) return "当選回数未登録";
  return `当選${value}回`;
}

export function MemberCard({ member }: { member: Member }) {
  const birthDate = formatBirthDate(member.birth_date);
  const twitterUrl =
    typeof member.twitter_url === "string" ? member.twitter_url.trim() : "";
  const facebookUrl =
    typeof member.facebook_url === "string" ? member.facebook_url.trim() : "";
  const instagramUrl =
    typeof member.instagram_url === "string" ? member.instagram_url.trim() : "";
  const threadsUrl =
    typeof member.threads_url === "string" ? member.threads_url.trim() : "";

  return (
    <Link
      href={routes.memberDetail(member.id) as Route}
      className="block rounded-3xl focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    >
      <article className="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm transition-transform duration-200 hover:-translate-y-0.5 hover:shadow-md">
        <div className="border-b border-slate-100 bg-white px-5 py-5">
          <div className="space-y-3">
            <div className="inline-flex rounded-full bg-white px-3 py-1 text-xs font-bold text-slate-700 shadow-sm ring-1 ring-slate-200">
              {formatElectionCount(member.election_count)}
            </div>

            <div className="space-y-1">
              <h2 className="text-xl font-bold tracking-[0.02em] text-slate-900">
                {member.name}
              </h2>
              <p className="text-sm font-medium text-slate-500">
                {member.name_kana || "ふりがな未登録"}
              </p>
            </div>
          </div>
        </div>

        <div className="flex flex-col gap-4 p-5">
          <div className="grid gap-3 text-sm leading-6 text-slate-700">
            <div className="flex items-start gap-2">
              <Shield className="mt-1 h-4 w-4 shrink-0 text-primary" />
              <div>
                <div className="text-xs font-bold uppercase tracking-[0.08em] text-slate-400">
                  政党
                </div>
                <div>{member.party || "未登録"}</div>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <Users className="mt-1 h-4 w-4 shrink-0 text-primary" />
              <div>
                <div className="text-xs font-bold uppercase tracking-[0.08em] text-slate-400">
                  会派
                </div>
                <div>{member.party_group || "未登録"}</div>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <MapPin className="mt-1 h-4 w-4 shrink-0 text-primary" />
              <div>
                <div className="text-xs font-bold uppercase tracking-[0.08em] text-slate-400">
                  住所
                </div>
                <div>{member.address || "未登録"}</div>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">
            {birthDate || "生年月日未登録"}
          </div>

          {twitterUrl || facebookUrl || instagramUrl || threadsUrl ? (
            <div className="flex flex-wrap items-center gap-3">
              {twitterUrl ? (
                <a
                  href={twitterUrl}
                  target="_blank"
                  rel="noreferrer"
                  aria-label={SOCIAL_ICON_MAP.x.name}
                  className="transition-opacity hover:opacity-70"
                >
                  <Image
                    src={SOCIAL_ICON_MAP.x.iconPath}
                    alt={SOCIAL_ICON_MAP.x.name}
                    width={36}
                    height={36}
                    className={
                      SOCIAL_ICON_MAP.x.hasBorder
                        ? "rounded-full border border-mirai-border-light"
                        : ""
                    }
                  />
                </a>
              ) : null}

              {facebookUrl ? (
                <a
                  href={facebookUrl}
                  target="_blank"
                  rel="noreferrer"
                  aria-label={SOCIAL_ICON_MAP.facebook.name}
                  className="transition-opacity hover:opacity-70"
                >
                  <Image
                    src={SOCIAL_ICON_MAP.facebook.iconPath}
                    alt={SOCIAL_ICON_MAP.facebook.name}
                    width={36}
                    height={36}
                    className={
                      SOCIAL_ICON_MAP.facebook.hasBorder
                        ? "rounded-full border border-mirai-border-light"
                        : ""
                    }
                  />
                </a>
              ) : null}

              {instagramUrl ? (
                <a
                  href={instagramUrl}
                  target="_blank"
                  rel="noreferrer"
                  aria-label={SOCIAL_ICON_MAP.instagram.name}
                  className="transition-opacity hover:opacity-70"
                >
                  <Image
                    src={SOCIAL_ICON_MAP.instagram.iconPath}
                    alt={SOCIAL_ICON_MAP.instagram.name}
                    width={36}
                    height={36}
                    className={
                      SOCIAL_ICON_MAP.instagram.hasBorder
                        ? "rounded-full border border-mirai-border-light"
                        : ""
                    }
                  />
                </a>
              ) : null}

              {threadsUrl ? (
                <a
                  href={threadsUrl}
                  target="_blank"
                  rel="noreferrer"
                  aria-label={SOCIAL_ICON_MAP.threads.name}
                  className="transition-opacity hover:opacity-70"
                >
                  <Image
                    src={SOCIAL_ICON_MAP.threads.iconPath}
                    alt={SOCIAL_ICON_MAP.threads.name}
                    width={36}
                    height={36}
                    className={
                      SOCIAL_ICON_MAP.threads.hasBorder
                        ? "rounded-full border border-mirai-border-light"
                        : ""
                    }
                  />
                </a>
              ) : null}
            </div>
          ) : null}
        </div>
      </article>
    </Link>
  );
}
