-- Initial schema. Money is stored in integer cents. Every row belongs to a business,
-- and row-level security limits each signed-in user to their own business's data.

create table business (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  logo_path text,
  address text,
  default_markup_pct numeric(6,2) not null default 30,
  tax_rate_pct numeric(6,3) not null default 0,
  invoice_prefix text not null default 'INV-',
  next_invoice_number integer not null default 1,
  created_at timestamptz not null default now()
);

create table client (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  name text not null,
  email text,
  phone text,
  billing_address text,
  created_at timestamptz not null default now()
);

create table project (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  client_id uuid references client (id) on delete set null,
  name text not null,
  site_address text,
  status text not null default 'active' check (status in ('active', 'done')),
  markup_pct numeric(6,2), -- null = use category or business default
  notes text,
  created_at timestamptz not null default now()
);

create table category (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  name text not null,
  markup_pct numeric(6,2), -- null = use business default
  sort_order integer not null default 0
);

-- Markup for one category on one job, e.g. plants at 40% on the Smith job.
-- Lookup order for a new item: item > project+category > project > category > business default.
create table project_category_markup (
  business_id uuid not null references business (id) on delete cascade,
  project_id uuid not null references project (id) on delete cascade,
  category_id uuid not null references category (id) on delete cascade,
  markup_pct numeric(6,2) not null,
  primary key (project_id, category_id)
);

create table worker (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  name text not null,
  phone text,
  pay_rate_cents integer not null default 0,  -- what she pays them per hour
  bill_rate_cents integer not null default 0, -- what the client is charged per hour
  is_owner boolean not null default false,
  active boolean not null default true
);

create table invoice (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  project_id uuid not null references project (id) on delete restrict,
  number text not null,
  issue_date date not null default current_date,
  due_date date,
  status text not null default 'draft' check (status in ('draft', 'sent', 'paid')),
  -- 'included' folds sales tax into line prices; 'separate' shows it as its own line.
  tax_display text not null default 'included' check (tax_display in ('included', 'separate')),
  period_start date,
  period_end date,
  paid_at date,
  payment_note text,
  subtotal_cents integer not null default 0,
  tax_cents integer not null default 0,
  total_cents integer not null default 0,
  pdf_path text,
  created_at timestamptz not null default now(),
  unique (business_id, number)
);

create table item (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  project_id uuid not null references project (id) on delete cascade,
  category_id uuid references category (id) on delete set null,
  description text not null,
  qty numeric(10,2) not null default 1,
  unit text,
  unit_cost_cents integer not null default 0,  -- her cost, never shown to clients
  markup_pct numeric(6,2),                     -- the markup used when the price was filled in
  unit_price_cents integer not null default 0, -- client price
  invoice_id uuid references invoice (id) on delete set null,
  created_at timestamptz not null default now()
);

create table time_entry (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  project_id uuid not null references project (id) on delete cascade,
  worker_id uuid not null references worker (id) on delete restrict,
  work_date date not null default current_date,
  hours numeric(6,2) not null,
  -- Rates are copied from the worker so past invoices don't change when a rate does.
  pay_rate_cents integer not null,
  bill_rate_cents integer not null,
  note text,
  invoice_id uuid references invoice (id) on delete set null,
  created_at timestamptz not null default now()
);

create table photo (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references business (id) on delete cascade,
  project_id uuid not null references project (id) on delete cascade,
  item_id uuid references item (id) on delete set null,
  storage_path text not null,
  caption text,
  taken_at timestamptz not null default now()
);

create index on project (business_id, status);
create index on item (project_id);
create index on time_entry (project_id);
create index on photo (project_id);
create index on invoice (project_id);

-- Row-level security: a user sees only rows of businesses they own.
create function my_business_ids() returns setof uuid
  language sql stable security definer set search_path = public as $$
  select id from business where owner_id = auth.uid()
$$;

alter table business enable row level security;
create policy business_owner on business
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

do $$
declare t text;
begin
  foreach t in array array['client','project','category','project_category_markup','worker','invoice','item','time_entry','photo'] loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy %I on %I for all using (business_id in (select my_business_ids())) with check (business_id in (select my_business_ids()))',
      t || '_by_business', t);
  end loop;
end $$;

-- Private bucket for job photos and invoice PDFs; paths start with the business id.
insert into storage.buckets (id, name, public) values ('project-files', 'project-files', false);
create policy project_files_by_business on storage.objects for all
  using (bucket_id = 'project-files' and (storage.foldername(name))[1]::uuid in (select my_business_ids()))
  with check (bucket_id = 'project-files' and (storage.foldername(name))[1]::uuid in (select my_business_ids()));
