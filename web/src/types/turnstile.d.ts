interface TurnstileRenderOptions {
  sitekey: string;
  callback?: (token: string) => void;
  "error-callback"?: () => void;
  "expired-callback"?: () => void;
  theme?: "light" | "dark" | "auto";
  language?: string;
}

interface TurnstileInstance {
  render: (
    container: HTMLElement,
    options: TurnstileRenderOptions
  ) => string | number;
  reset: (widgetId?: string | number) => void;
  remove: (widgetId: string | number) => void;
}

declare global {
  interface Window {
    turnstile?: TurnstileInstance;
  }
}

export {};
