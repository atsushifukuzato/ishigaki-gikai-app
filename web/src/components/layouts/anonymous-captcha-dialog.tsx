"use client";

import Script from "next/script";
import { useEffect, useRef, useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { setStoredAnonymousCaptchaToken } from "@/features/chat/client/lib/anonymous-auth-captcha";

interface AnonymousCaptchaDialogProps {
  open: boolean;
  siteKey: string;
  error?: string | null;
}

export function AnonymousCaptchaDialog({
  open,
  siteKey,
  error,
}: AnonymousCaptchaDialogProps) {
  const [isScriptReady, setIsScriptReady] = useState(false);
  const [widgetError, setWidgetError] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);
  const widgetIdRef = useRef<string | number | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }

    setWidgetError(null);
  }, [open]);

  useEffect(() => {
    if (!open || !isScriptReady || !containerRef.current || !window.turnstile) {
      return;
    }

    if (widgetIdRef.current !== null) {
      window.turnstile.reset(widgetIdRef.current);
      return;
    }

    widgetIdRef.current = window.turnstile.render(containerRef.current, {
      sitekey: siteKey,
      theme: "light",
      language: "ja",
      callback: (token) => {
        setWidgetError(null);
        setStoredAnonymousCaptchaToken(token);
      },
      "error-callback": () => {
        setWidgetError(
          "画像認証の読み込みに失敗しました。ページを再読み込みしてもう一度お試しください。"
        );
      },
      "expired-callback": () => {
        if (widgetIdRef.current !== null) {
          window.turnstile?.reset(widgetIdRef.current);
        }
      },
    });

    return () => {
      if (widgetIdRef.current !== null) {
        window.turnstile?.remove(widgetIdRef.current);
        widgetIdRef.current = null;
      }
    };
  }, [open, isScriptReady, siteKey]);

  return (
    <>
      <Script
        src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit"
        strategy="afterInteractive"
        onLoad={() => setIsScriptReady(true)}
      />

      <Dialog open={open}>
        <DialogContent
          className="max-w-md px-6 py-8"
          onEscapeKeyDown={(event) => event.preventDefault()}
          onInteractOutside={(event) => event.preventDefault()}
        >
          <DialogHeader className="gap-3 text-left">
            <DialogTitle className="text-xl font-bold text-mirai-text">
              続行前に人によるアクセス確認をお願いします
            </DialogTitle>
            <DialogDescription className="text-sm leading-7 text-mirai-text-muted">
              匿名で使える機能への大量アクセスを防ぐため、最初の1回だけ確認しています。
              確認が終わるとそのまま利用できます。
            </DialogDescription>
          </DialogHeader>

          <div className="rounded-2xl bg-mirai-surface-light px-4 py-4">
            <div
              ref={containerRef}
              className="flex min-h-[70px] items-center justify-center"
            />
          </div>

          {(error || widgetError) && (
            <p className="text-sm leading-6 text-destructive">
              {error || widgetError}
            </p>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}
