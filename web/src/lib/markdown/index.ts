import { toJsxRuntime } from "hast-util-to-jsx-runtime";
import type { ReactElement } from "react";
import { Fragment } from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import rehypeSanitize, { defaultSchema } from "rehype-sanitize";
import remarkBreaks from "remark-breaks";
import remarkParse from "remark-parse";
import remarkRehype from "remark-rehype";
import { unified } from "unified";
import { LongPressSection } from "@/features/bills/client/components/bill-detail/long-press-section";
import { DifficultyInfoCard } from "@/features/bills/server/components/bill-detail/difficulty-info-card";
import { rehypeEmbedYouTube } from "./rehype-embed-youtube";
import { rehypeExternalLinks } from "./rehype-external-links";
import { rehypeInjectElement } from "./rehype-inject-element";
import { rehypeWrapSections } from "./rehype-wrap-sections";

// rehypeSanitizeのスキーマをカスタマイズ
const sanitizeSchema = {
  ...defaultSchema,
  attributes: {
    ...defaultSchema.attributes,
    a: [...(defaultSchema.attributes?.a || []), "target", "rel"],
  },
  tagNames: [
    ...(defaultSchema.tagNames || []),
    // カスタム要素を許可
    "LongPressSection",
    "DifficultyInfoCard",
  ],
};

/**
 * MarkdownテキストをReact Elementに変換（Bills用）
 * DifficultyInfoCard・LongPressSection を自動注入する。
 * Topics など bills 以外のコンテンツには parseTopicMarkdown() を使用してください。
 */
export async function parseMarkdown(markdown: string): Promise<ReactElement> {
  // Markdown → mdast（remarkBreaksでソフト改行をbreak nodeに変換）
  const remarkProcessor = unified().use(remarkParse).use(remarkBreaks);
  const parsed = remarkProcessor.parse(markdown);
  const mdast = (await remarkProcessor.run(parsed)) as typeof parsed;

  // mdast → hast（rehypeプラグイン適用）
  const hast = await unified()
    .use(remarkRehype)
    .use(rehypeWrapSections)
    .use(rehypeInjectElement, {
      injections: [
        {
          targetH2Index: 3,
          tagName: "LongPressSection",
        },
        {
          targetH2Index: -1,
          tagName: "DifficultyInfoCard",
        },
      ],
    })
    .use(rehypeSanitize, sanitizeSchema)
    .use(rehypeExternalLinks)
    .use(rehypeEmbedYouTube)
    .run(mdast);

  // hast → React Element（部分水和）
  return toJsxRuntime(hast, {
    Fragment,
    jsx,
    jsxs,
    components: {
      LongPressSection, // Client Componentとして水和
      DifficultyInfoCard, // Client Componentとして水和
    },
  });
}

/**
 * MarkdownテキストをReact Elementに変換（Topics用）
 * bills 向けの DifficultyInfoCard・LongPressSection は注入しない。
 */
export async function parseTopicMarkdown(
  markdown: string
): Promise<ReactElement> {
  const remarkProcessor = unified().use(remarkParse).use(remarkBreaks);
  const parsed = remarkProcessor.parse(markdown);
  const mdast = (await remarkProcessor.run(parsed)) as typeof parsed;

  const hast = await unified()
    .use(remarkRehype)
    .use(rehypeWrapSections)
    .use(rehypeSanitize, sanitizeSchema)
    .use(rehypeExternalLinks)
    .use(rehypeEmbedYouTube)
    .run(mdast);

  return toJsxRuntime(hast, { Fragment, jsx, jsxs });
}
