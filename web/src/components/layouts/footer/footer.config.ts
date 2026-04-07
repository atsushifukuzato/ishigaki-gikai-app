import { EXTERNAL_LINKS } from "@/config/external-links";
import { routes } from "@/lib/routes";

export type FooterLink = {
  label: string;
  href: string;
  external?: boolean;
};

export type FooterPolicyLink = {
  label: string;
  href: string;
  external?: boolean;
};

export const primaryLinks: FooterLink[] = [
  {
    label: "TOP",
    href: routes.home(),
  },
  {
    label: "みらい議会とは",
    href: EXTERNAL_LINKS.ABOUT_NOTE,
    external: true,
  },
  {
    label: "AFTTTとは",
    href: EXTERNAL_LINKS.AFTTT,
    external: true,
  },
  {
    label: "寄附で応援する",
    href: routes.donate(),
  },
];

export const policyLinks: FooterPolicyLink[] = [
  {
    label: "よくあるご質問",
    href: routes.faq(),
  },
  {
    label: "利用規約",
    href: routes.terms(),
  },
  {
    label: "プライバシーポリシー",
    href: routes.privacy(),
  },
];
