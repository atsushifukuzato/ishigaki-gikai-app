import { Container } from "@/components/layouts/container";
import { MemberCard } from "@/components/members/member-card";
import { getMembers } from "@/features/members/server/repositories/member-repository";

export const metadata = {
  title: "議員名簿 | みらい議会 石垣市議会版",
};

export default async function MembersPage() {
  const members = await getMembers();

  return (
    <div
      className="py-10"
      style={{
        backgroundImage: "linear-gradient(#e2f6f3, #eef6e2)",
      }}
    >
      <Container>
        <div className="flex flex-col gap-8">
          <div className="space-y-3">
            <p className="text-sm font-bold tracking-[0.08em] text-primary-accent">
              MEMBERS
            </p>
            <div className="space-y-3">
              <h1 className="text-4xl font-extrabold tracking-[0.02em] text-slate-900">
                石垣市議会 議員名簿
              </h1>
              <p className="max-w-2xl text-[15px] leading-7 text-slate-600">
                石垣市議会の議員情報を一覧で確認できます。所属政党、会派、当選回数などを見やすいカード形式で掲載しています。
              </p>
            </div>
          </div>

          {members.length > 0 ? (
            <div className="grid gap-5 sm:grid-cols-2">
              {members.map((member, index) => (
                <MemberCard
                  key={`${member.name}-${member.birth_date ?? index}`}
                  member={member}
                />
              ))}
            </div>
          ) : (
            <div className="rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-12 text-center text-slate-500 shadow-sm">
              現在、表示できる議員データがありません。
            </div>
          )}
        </div>
      </Container>
    </div>
  );
}
