interface TopicStatusCardProps {
  label: string | null;
  note: string | null;
  updatedAt: string | null;
}

function formatStatusDate(value: string | null) {
  if (!value) {
    return null;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日更新`;
}

export function TopicStatusCard({
  label,
  note,
  updatedAt,
}: TopicStatusCardProps) {
  if (!label && !note) {
    return null;
  }

  const updatedLabel = formatStatusDate(updatedAt);

  return (
    <section className="space-y-3">
      <h2 className="text-[22px] font-bold text-slate-900">現在の状況</h2>
      <div className="space-y-3 rounded-2xl bg-white px-4 py-6">
        {label ? (
          <div className="inline-flex rounded-full bg-[#eef6e2] px-4 py-1.5 text-sm font-bold text-slate-900">
            {label}
          </div>
        ) : null}
        {note ? (
          <p className="max-w-3xl text-[15px] leading-7 text-slate-600">
            {note}
          </p>
        ) : null}
        {updatedLabel ? (
          <p className="text-xs font-medium text-slate-400">{updatedLabel}</p>
        ) : null}
      </div>
    </section>
  );
}
