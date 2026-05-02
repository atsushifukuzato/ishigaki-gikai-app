import { parseMarkdown } from "@/lib/markdown";

interface TopicContentProps {
  content: string;
}

export async function TopicContent({ content }: TopicContentProps) {
  if (!content) {
    return null;
  }

  try {
    const markdown = await parseMarkdown(content);

    return (
      <div
        className="
          markdown-content max-w-none text-base
          [&_h1]:text-2xl [&_h1]:font-bold [&_h1]:mb-4
          [&_h2]:text-[22px] [&_h2]:font-bold [&_h2]:mb-4
          [&_h3]:text-lg [&_h3]:font-semibold [&_h3]:mb-2
          [&_p]:mb-4 [&_p]:leading-relaxed
          [&_ul]:list-disc [&_ul]:pl-6 [&_ul]:mb-4
          [&_ol]:list-decimal [&_ol]:pl-6 [&_ol]:mb-4
          [&_li]:mb-4
          [&_a]:!underline [&_a]:!underline-offset-[3px]
          [&_a:hover]:opacity-70
          [&_blockquote]:border-l-4 [&_blockquote]:border-gray-300
          [&_blockquote]:pl-4
          [&_pre]:bg-gray-100 [&_pre]:p-4 [&_pre]:rounded [&_pre]:overflow-x-auto
          [&_code]:bg-gray-100 [&_code]:px-1 [&_code]:rounded
          [&_section]:mb-9
          [&_section]:break-all
          [&_section>*:last-child]:mb-0
          [&_section:has(>iframe)]:p-0
          [&_iframe.youtube-embed]:w-full [&_iframe.youtube-embed]:aspect-video [&_iframe.youtube-embed]:mb-4
          [&_iframe.youtube-embed]:rounded-lg [&_iframe.youtube-embed]:shadow-md
        "
      >
        {markdown}
      </div>
    );
  } catch (error) {
    console.error("Failed to parse topic markdown:", error);

    return (
      <div className="whitespace-pre-wrap text-base leading-relaxed text-slate-700">
        {content}
      </div>
    );
  }
}
