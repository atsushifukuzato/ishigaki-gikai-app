const BILL_TITLE_PREFIX_PATTERN = /^(?:議員提出議案第\d+号|議案第\d+号)\s*/;
const BILL_TITLE_SUFFIX_PATTERN = /\s*（第\d+号）\s*$/;

export function stripBillTitlePrefix(
  title: string | null | undefined
): string | null {
  if (!title) {
    return null;
  }

  const normalizedTitle = title
    .trim()
    .replace(BILL_TITLE_PREFIX_PATTERN, "")
    .replace(BILL_TITLE_SUFFIX_PATTERN, "")
    .trim();
  return normalizedTitle.length > 0 ? normalizedTitle : title.trim();
}

export function getBillDisplayTitle(bill: {
  name: string;
  bill_content?: {
    title: string | null;
  } | null;
}): string {
  return (
    stripBillTitlePrefix(bill.bill_content?.title) ??
    stripBillTitlePrefix(bill.name) ??
    bill.name
  );
}
