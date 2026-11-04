-- Default landscape categories for a new business. Other trades can use their own list.
-- Usage: replace :business_id, or call from the app's onboarding step.
insert into category (business_id, name, sort_order) values
  (:'business_id', 'Plants', 1),
  (:'business_id', 'Pots & planters', 2),
  (:'business_id', 'Hardscape', 3),
  (:'business_id', 'Soil, mulch & gravel', 4),
  (:'business_id', 'Fencing & wood', 5),
  (:'business_id', 'Water features', 6),
  (:'business_id', 'Other', 7);
