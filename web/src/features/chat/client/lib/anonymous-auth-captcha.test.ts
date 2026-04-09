// @vitest-environment jsdom

import { describe, expect, it, vi, beforeEach, afterEach } from "vitest";
import {
  ANON_CAPTCHA_TOKEN_STORAGE_KEY,
  getStoredAnonymousCaptchaToken,
  setStoredAnonymousCaptchaToken,
  clearStoredAnonymousCaptchaToken,
} from "./anonymous-auth-captcha";

describe("anonymous-auth-captcha", () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("stores and reads a captcha token", () => {
    setStoredAnonymousCaptchaToken("token-123");

    expect(window.localStorage.getItem(ANON_CAPTCHA_TOKEN_STORAGE_KEY)).toBe(
      "token-123"
    );
    expect(getStoredAnonymousCaptchaToken()).toBe("token-123");
  });

  it("clears a stored captcha token", () => {
    window.localStorage.setItem(ANON_CAPTCHA_TOKEN_STORAGE_KEY, "token-123");

    clearStoredAnonymousCaptchaToken();

    expect(getStoredAnonymousCaptchaToken()).toBeNull();
  });
});
