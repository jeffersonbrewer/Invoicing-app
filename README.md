# Invoicing app

A phone-first web app for small trade businesses (starting with landscape design) to keep
project folders with photos, log materials with cost and client price, track hours for the
owner and subcontractors, and send PDF invoices.

Plan: https://claude.ai/artifact/BsW9qrJTxSLv4cctm4ACEB

## Stack

- Next.js (App Router) + TypeScript + Tailwind CSS, installable as a PWA
- Supabase for the database, sign-in and photo storage
- Hosting on Netlify (free plan allows business use)

## Run it locally

1. Install Node.js 20 or newer.
2. `npm install`
3. Create a free project at https://supabase.com, then copy `.env.example` to `.env.local`
   and fill in the URL and anon key from Project Settings > API.
4. In the Supabase SQL editor, run `supabase/migrations/0001_initial_schema.sql`.
5. `npm run dev` and open http://localhost:3000 (or your computer's IP on your phone).

## Data rules

- Money is stored as integer cents.
- Each material stores both her cost and the client price; the price defaults to cost plus markup.
- Time entries copy the worker's rates when logged, so old invoices never change.
- Markup for a new item is picked most specific first: item, job + category, job, category, business default.
- Sales tax can be folded into prices (default) or shown as its own invoice line.
- Every table belongs to a `business`, and row-level security keeps businesses separate.

## Build order

1. Projects + photos
2. Materials with markup
3. Workers + time entries
4. Invoice PDF + email
