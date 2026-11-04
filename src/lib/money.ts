/** All money is stored as integer cents. */

export function priceFromCost(costCents: number, markupPct: number): number {
  return Math.round(costCents * (1 + markupPct / 100));
}

/**
 * Picks the markup for a new item, most specific first:
 * this item > this job + category > this job > the category > the business default.
 */
export function resolveMarkupPct(opts: {
  item?: number | null;
  projectCategory?: number | null;
  project?: number | null;
  category?: number | null;
  businessDefault: number;
}): number {
  return opts.item ?? opts.projectCategory ?? opts.project ?? opts.category ?? opts.businessDefault;
}

export function formatCents(cents: number, currency = "USD"): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(cents / 100);
}
