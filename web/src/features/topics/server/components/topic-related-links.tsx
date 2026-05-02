import type { TopicUpdate } from "../../shared/types";

interface TopicRelatedLinksProps {
  updates: TopicUpdate[];
}

function formatPublishedAt(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
}

export function TopicRelatedLinks({ updates }: TopicRelatedLinksProps) {
  const links = updates
    .filter((update) => update.source_url)
    .map((update) => ({
      url: update.source_url as string,
      label: update.source_label || update.title,
      title: update.title,
      publishedAt: update.published_at,
    }))
    .filter(
      (link, index, array) =>
        array.findIndex((item) => item.url === link.url) === index
    );

  if (links.length === 0) {
    return null;
  }

  return (
    <section className="space-y-4">
      <div className="space-y-1">
        <h2 className="text-[22px] font-bold text-slate-900">関連情報・資料</h2>
        <p className="text-sm text-slate-500">
          このテーマを追うときに参照しやすい出典や関連リンクです。
        </p>
      </div>

      <div className="divide-y divide-slate-200 rounded-2xl bg-white px-4">
        {links.map((link) => (
          <a
            key={link.url}
            href={link.url}
            target="_blank"
            rel="noreferrer"
            className="block py-4 transition-opacity hover:opacity-75"
          >
            <div className="space-y-1">
              <p className="text-sm font-bold text-primary-accent">
                {link.label}
              </p>
              <p className="text-sm leading-6 text-slate-700">{link.title}</p>
              {formatPublishedAt(link.publishedAt) ? (
                <p className="text-xs text-slate-400">
                  {formatPublishedAt(link.publishedAt)}
                </p>
              ) : null}
            </div>
          </a>
        ))}
      </div>
    </section>
  );
}
