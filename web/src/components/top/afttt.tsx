import Image from "next/image";
import { LinkButton } from "./link-button";

const AFTTT_SOCIAL_LINKS = [
  {
    name: "Instagram",
    url: "https://www.instagram.com/afttt.jp",
    iconPath: "/icons/sns/icon_instagram.png",
    hasBorder: true,
  },
  {
    name: "X",
    url: "https://x.com/AtsushiFukuzato",
    iconPath: "/icons/sns/icon_x.png",
    hasBorder: false,
  },
  {
    name: "Threads",
    url: "https://www.threads.com/@atsushi_fukuzato",
    iconPath: "/icons/sns/icon_threads.png",
    hasBorder: true,
  },
  {
    name: "Facebook",
    url: "https://www.facebook.com/atsushi.fukuzato",
    iconPath: "/icons/sns/icon_facebook.png",
    hasBorder: false,
  },
  {
    name: "note",
    url: "https://note.com/atsushi_fukuzato",
    iconPath: "/icons/sns/icon_note.png",
    hasBorder: true,
  },
] as const;

export function AFTTT() {
  return (
    <div className="py-10">
      <div className="flex flex-col gap-6">
        <div className="flex flex-col gap-4">
          <h2 className="text-[44px] font-extrabold leading-none tracking-[0.02em] text-black">
            AFTTT
          </h2>
          <p className="text-sm font-bold text-primary-accent">
            アフトについて
          </p>
        </div>

        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-3">
            <p className="text-[15px] leading-[28px] text-black">
              沖縄石垣島を拠点とする小さな制作オフィスです。
            </p>
            <p className="text-[15px] leading-[28px] text-black">
              編集・出版・撮影・デザイン・ウェブサイト制作・業務アプリ開発・バックオフィス支援など、幅広く手がけています。
            </p>
          </div>

          <div className="flex flex-col gap-4">
            <LinkButton
              href="https://afttt.jp/"
              icon={{
                src: "/icons/info-icon.svg",
                alt: "",
                width: 23,
                height: 22,
              }}
            >
              AFTTTについて詳しく
            </LinkButton>
          </div>

          <div className="flex flex-wrap gap-3 items-end">
            {AFTTT_SOCIAL_LINKS.map((sns) => (
              <a
                key={sns.name}
                href={sns.url}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:opacity-70 transition-opacity"
              >
                <Image
                  src={sns.iconPath}
                  alt={sns.name}
                  width={48}
                  height={48}
                  className={
                    sns.hasBorder
                      ? "rounded-full border border-mirai-border-light"
                      : ""
                  }
                />
              </a>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
