export function calculateInvoiceTotals(items: Array<{ quantity: number; price: number; discount: number; gstRate: number }>) {
  const normalized = items.map((item) => {
    const lineTotal = item.quantity * item.price;
    const taxable = Math.max(lineTotal - item.discount, 0);
    const tax = (taxable * item.gstRate) / 100;
    return { taxable, tax, discount: item.discount };
  });

  const subtotal = normalized.reduce((sum, item) => sum + item.taxable, 0);
  const tax = normalized.reduce((sum, item) => sum + item.tax, 0);
  const discount = normalized.reduce((sum, item) => sum + item.discount, 0);
  const total = subtotal + tax;

  return { subtotal, tax, discount, total };
}
