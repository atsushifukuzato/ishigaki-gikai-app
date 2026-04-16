import "server-only";
import { parseMarkdown } from "@/lib/markdown";

interface TopicUpdateMarkdownProps {
  content: string;
}

export async function TopicUpdateMarkdown({
  content,
}: TopicUpdateMarkdownProps) {
  if (!content) return null;

  try {
    const markdown = await parseMarkdown(content);
    return (
      <div
        className="
          [&_h2]:text-sm [&_h2]:font-semibold [&_h2]:mb-2 [&_h2]:mt-3
          [&_h3]:text-sm [&_h3]:font-semibold [&_h3]:mb-1
          [&_p]:mb-2 [&_p]:leading-relaxed
          [&_ul]:list-disc [&_ul]:pl-5 [&_ul]:mb-2
          [&_ol]:list-decimal [&_ol]:pl-5 [&_ol]:mb-2
          [&_li]:mb-1
          [&_a]:underline [&_a]:underline-offset-[3px]
          text-sm leading-7 text-slate-500
        "
      >
        {markdown}
      </div>
    );
  } catch {
    return (
      <p className="whitespace-pre-wrap text-sm leading-7 text-slate-500">
        {content}
      </p>
    );
  }
}
