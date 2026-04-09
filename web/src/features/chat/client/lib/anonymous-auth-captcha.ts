"use client";

export const ANON_CAPTCHA_TOKEN_STORAGE_KEY =
  "mirai-gikai.anonymous-auth-captcha-token";
export const ANON_CAPTCHA_TOKEN_UPDATED_EVENT =
  "mirai-gikai:anonymous-auth-captcha-token-updated";

export function getTurnstileSiteKey(): string | null {
  const value = process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY?.trim();
  return value ? value : null;
}

export function getStoredAnonymousCaptchaToken(): string | null {
  if (typeof window === "undefined") {
    return null;
  }

  const value = window.localStorage.getItem(ANON_CAPTCHA_TOKEN_STORAGE_KEY);
  return value ? value : null;
}

export function setStoredAnonymousCaptchaToken(token: string) {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.setItem(ANON_CAPTCHA_TOKEN_STORAGE_KEY, token);
  window.dispatchEvent(new CustomEvent(ANON_CAPTCHA_TOKEN_UPDATED_EVENT));
}

export function clearStoredAnonymousCaptchaToken() {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(ANON_CAPTCHA_TOKEN_STORAGE_KEY);
  window.dispatchEvent(new CustomEvent(ANON_CAPTCHA_TOKEN_UPDATED_EVENT));
}
