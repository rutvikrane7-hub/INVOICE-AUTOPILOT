# Invoice Autopilot

> Track invoices and overdue payments — built for freelancers and small agencies.

![Invoice Autopilot](https://img.shields.io/badge/Stack-React%20%2B%20Supabase-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## Features

| Feature | Free | Pro | Business |
|---|:---:|:---:|:---:|
| Active invoices | 5 | Unlimited | Unlimited |
| Color-coded status | ✅ | ✅ | ✅ |
| Mark as Paid | ✅ | ✅ | ✅ |
| Copy reminder (polite) | ✅ | ✅ | ✅ |
| 3 reminder tones | ❌ | ✅ | ✅ |
| Email reminders | ❌ | ✅ | ✅ |
| CSV export | ❌ | ✅ | ✅ |
| Team access | ❌ | ❌ | ✅ |
| WhatsApp messages | ❌ | ❌ | ✅ |

## Tech Stack

- **Frontend**: React 18 + Vite + TailwindCSS
- **Backend/DB**: Supabase (Auth + PostgreSQL + Realtime)
- **Payments**: Razorpay (India) + Lemon Squeezy (International)
- **Hosting**: Vercel

---

## Getting Started

### 1. Clone and install

```bash
cd invoice-autopilot
npm install
```

### 2. Set up Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run the contents of [`supabase-schema.sql`](./supabase-schema.sql)
3. In **Database > Replication**, enable Realtime for the `invoices` and `profiles` tables

### 3. Configure environment

```bash
cp .env.example .env.local
```

Fill in your Supabase URL and anon key from **Settings > API**.

### 4. Run locally

```bash
npm run dev
```

App runs at `http://localhost:5173`

---

## Deployment (Vercel)

1. Push to GitHub
2. Import repo in [Vercel](https://vercel.com)
3. Add all env vars from `.env.example` to Vercel project settings
4. Deploy — Vercel auto-detects Vite and the `/api` serverless functions

### Webhook URLs (set in payment dashboards)

| Provider | Webhook URL |
|---|---|
| Razorpay | `https://your-app.vercel.app/api/razorpay-webhook` |
| Lemon Squeezy | `https://your-app.vercel.app/api/lemonsqueezy-webhook` |

---

## Payment Setup

### Razorpay (INR)
1. Create Payment Links for Pro (₹199) and Business (₹499)
2. Add a **Note** field `plan` = `pro` or `business`
3. Set webhook URL to `/api/razorpay-webhook`
4. Copy link URLs to `VITE_RAZORPAY_PRO_LINK` / `VITE_RAZORPAY_BUSINESS_LINK`

### Lemon Squeezy (USD)
1. Create Products for Pro ($5) and Business ($12)
2. Note the Variant IDs
3. Set webhook URL to `/api/lemonsqueezy-webhook`
4. Set `LS_PRO_VARIANT_ID` and `LS_BUSINESS_VARIANT_ID` in env vars
5. Copy checkout URLs to `VITE_LS_PRO_CHECKOUT` / `VITE_LS_BUSINESS_CHECKOUT`

---

## Project Structure

```
invoice-autopilot/
├── api/                     # Vercel Serverless Functions
│   ├── razorpay-webhook.js
│   └── lemonsqueezy-webhook.js
├── src/
│   ├── components/          # Reusable UI components
│   ├── pages/               # Route-level page components
│   ├── hooks/               # Custom React hooks
│   ├── lib/                 # Supabase client + utilities
│   └── App.jsx              # Router + auth
├── supabase-schema.sql      # Run this in Supabase SQL Editor
├── .env.example             # Environment variable template
└── vercel.json
```

## License

MIT
