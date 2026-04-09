"use client";

import { createBrowserClient } from "@mirai-gikai/supabase";
import { useCallback, useEffect, useState } from "react";
import {
  ANON_CAPTCHA_TOKEN_UPDATED_EVENT,
  clearStoredAnonymousCaptchaToken,
  getStoredAnonymousCaptchaToken,
  getTurnstileSiteKey,
} from "../lib/anonymous-auth-captcha";

// Create a singleton Supabase client with persistent session
const supabase = createBrowserClient();
let ensureAnonymousUserPromise: Promise<string | undefined> | null = null;

type AnonymousAuthStatus =
  | "checking"
  | "needs_captcha"
  | "signing_in"
  | "ready"
  | "error";

function isCaptchaVerificationError(message: string): boolean {
  const normalized = message.toLowerCase();
  return (
    normalized.includes("captcha") ||
    normalized.includes("turnstile") ||
    normalized.includes("token") ||
    normalized.includes("verification")
  );
}

async function _signInAnonymously(captchaToken?: string) {
  if (!ensureAnonymousUserPromise) {
    ensureAnonymousUserPromise = (async () => {
      const { data, error } = await supabase.auth.signInAnonymously(
        captchaToken
          ? {
              options: {
                captchaToken,
              },
            }
          : undefined
      );

      if (error) {
        throw error;
      }

      return data.user?.id;
    })().finally(() => {
      ensureAnonymousUserPromise = null;
    });
  }

  return ensureAnonymousUserPromise;
}

/**
 * Hook to ensure an anonymous Supabase user exists and return the user ID
 * This will automatically create an anonymous user if none exists
 */
export function useAnonymousSupabaseUser() {
  const [userId, setUserId] = useState<string | undefined>(undefined);
  const [status, setStatus] = useState<AnonymousAuthStatus>("checking");
  const [error, setError] = useState<string | null>(null);
  const captchaSiteKey = getTurnstileSiteKey();

  const ensureAnonUser = useCallback(async () => {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (user) {
        setUserId(user.id);
        setStatus("ready");
        setError(null);
        return;
      }

      const captchaToken = getStoredAnonymousCaptchaToken();

      if (captchaSiteKey && !captchaToken) {
        setStatus("needs_captcha");
        setError(null);
        return;
      }

      setStatus("signing_in");
      setError(null);

      const signedInUserId = await _signInAnonymously(
        captchaToken ?? undefined
      );

      clearStoredAnonymousCaptchaToken();

      if (signedInUserId) {
        setUserId(signedInUserId);
        setStatus("ready");
        return;
      }

      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();

        if (user) {
          setUserId(user.id);
          setStatus("ready");
          return;
        }
      } catch (err) {
        console.error("Error reloading anonymous user:", err);
      }
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "匿名ユーザーの作成に失敗しました";

      console.error("Error ensuring anonymous user:", err);

      clearStoredAnonymousCaptchaToken();

      if (captchaSiteKey && isCaptchaVerificationError(message)) {
        setStatus("needs_captcha");
        setError(
          "認証確認の有効期限が切れた可能性があります。もう一度確認をお願いします。"
        );
        return;
      }

      setStatus("error");
      setError(
        "匿名ユーザーの準備に失敗しました。時間をおいて再読み込みしてください。"
      );
    }
  }, [captchaSiteKey]);

  useEffect(() => {
    void ensureAnonUser();

    const handleCaptchaTokenUpdated = () => {
      void ensureAnonUser();
    };

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUserId(session.user.id);
        setStatus("ready");
        setError(null);
        return;
      }

      setUserId(undefined);
      void ensureAnonUser();
    });

    window.addEventListener(
      ANON_CAPTCHA_TOKEN_UPDATED_EVENT,
      handleCaptchaTokenUpdated
    );

    return () => {
      subscription.unsubscribe();
      window.removeEventListener(
        ANON_CAPTCHA_TOKEN_UPDATED_EVENT,
        handleCaptchaTokenUpdated
      );
    };
  }, [ensureAnonUser]);

  return {
    userId,
    status,
    error,
    needsCaptcha: status === "needs_captcha",
    captchaSiteKey,
  };
}
