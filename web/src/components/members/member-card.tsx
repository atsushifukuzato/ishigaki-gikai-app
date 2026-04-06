import { MapPin, Shield, Users } from "lucide-react";
import type { Member } from "@/features/members/shared/types";

function formatBirthDate(value: string | null) {
  if (!value) return null;

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}年${month}月${day}日生`;
}

function formatElectionCount(value: number | null) {
  if (value == null) return "当選回数未登録";
  return `当選${value}回`;
}

export function MemberCard({ member }: { member: Member }) {
  const birthDate = formatBirthDate(member.birth_date);

  return (
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
      </div>
    </article>
  );
}
