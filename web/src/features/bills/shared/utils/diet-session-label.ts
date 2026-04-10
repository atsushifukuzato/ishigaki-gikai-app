import type { BillDietSession } from "../types";

function getDietSessionTypeLabel(slug: string | null | undefined) {
  if (!slug) {
    return null;
  }

  if (slug.includes("regular")) {
    return "定例会";
  }

  if (slug.includes("rinji") || slug.includes("extraordinary")) {
    return "臨時会";
  }

  return null;
}

export function formatBillDietSessionLabel(
  dietSession: BillDietSession | undefined
) {
  if (!dietSession) {
    return null;
  }

  if (
    dietSession.name.includes("定例会") ||
    dietSession.name.includes("臨時会")
  ) {
    return dietSession.name;
  }

  const typeLabel = getDietSessionTypeLabel(dietSession.slug);
  return typeLabel ? `${dietSession.name}${typeLabel}` : dietSession.name;
}
