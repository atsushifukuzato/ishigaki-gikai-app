import { LinkButton } from "@/components/top/link-button";
import { EXTERNAL_LINKS } from "@/config/external-links";
import { routes } from "@/lib/routes";

/**
 * デスクトップメニュー: アクションボタン（サイドバー内）
 */
export function DesktopMenuActionButtons() {
  return (
    <div className="flex flex-col gap-3">
      <LinkButton
        href={EXTERNAL_LINKS.ABOUT_NOTE}
        icon={{
          src: "/icons/note-icon.png",
          alt: "note",
          width: 20,
          height: 20,
        }}
      >
        みらい議会とは
      </LinkButton>

      <LinkButton
        href={routes.donate()}
        icon={{
          src: "/icons/heart-icon.svg",
          alt: "寄附",
          width: 20,
          height: 20,
        }}
        target="_self"
        rel={undefined}
      >
        寄附で応援する
      </LinkButton>
    </div>
  );
}
