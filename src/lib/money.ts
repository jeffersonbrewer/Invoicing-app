/** All money is stored as integer cents. */

export function priceFromCost(costCents: number, markupPct: number): number {
  return Math.round(costCents * (1 + markupPct / 100));
}

export function formatCents(cents: number, currency = "USD"): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(cents / 100);
}
