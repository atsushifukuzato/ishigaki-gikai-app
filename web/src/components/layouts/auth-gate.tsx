"use client";

import type { ReactNode } from "react";
import { useAnonymousSupabaseUser } from "@/features/chat/client/hooks/use-anonymous-supabase-user";
import { AnonymousCaptchaDialog } from "./anonymous-captcha-dialog";

export function AuthGate({ children }: { children?: ReactNode }) {
  const { needsCaptcha, captchaSiteKey, error } = useAnonymousSupabaseUser();

  return (
    <>
      {captchaSiteKey && (
        <AnonymousCaptchaDialog
          open={needsCaptcha}
          siteKey={captchaSiteKey}
          error={error}
        />
      )}
      {children}
    </>
  );
}
