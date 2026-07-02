# RiseUP

> A daily Stoic practice app. Lessons, quotes, and a streak that doesn't care about your mood.

This is a monorepo with three pieces:

| Folder | What | Stack |
|---|---|---|
| [`web/`](./web) | Marketing / browser app | Next.js 15 (App Router) + Tailwind, reads PocketBase only |
| [`app/`](./app) | Mobile app (iOS + Android + web) | Flutter 3.22+, reads PocketBase (static) + Appwrite (user data) |
| [`pb/`](./pb) | Backend tooling | Node.js scripts — bootstraps PB, seeds content, sets up Appwrite collections |
| [`server/`](./server) | Server-side jobs | Cloudflare Workers — FCM push notifications (Year 2) |
| [`twa/`](./twa) | Trusted Web Activity | Bubblewrap config to ship the web app as a Play Store app |

The live web app is at https://riseup.stoic (or whatever you've pointed at the `web/out/` static export).

## Architecture

```
                       ┌──────────────┐
   authors / lessons   │              │   public read-only
   quotes / plans  ───►│  PocketBase  │◄──── web app
   categories          │   (static)   │◄──── Flutter app
                       │              │
                       └──────────────┘

                       ┌──────────────┐
   auth / progress     │              │   per-user, document-level
   favorites / subs ──►│   Appwrite   │◄──── Flutter app only
   settings            │  (per-user)  │
                       │              │
                       └──────────────┘
```

See [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) for the full breakdown, including the subscription state machine and the Stripe/RevenueCat hook points.

## Pre-production status

Before shipping to the stores, see:
- [`docs/AUDIT.md`](./docs/AUDIT.md) — what's built, what's wired-but-untested, what's missing
- [`docs/TASKS.md`](./docs/TASKS.md) — the master task list (every task with priority + status)
- [`docs/PRODUCTION.md`](./docs/PRODUCTION.md) — Play Store + App Store checklist

## Commercial plan

[`docs/BUSINESS-PLAN.md`](./docs/BUSINESS-PLAN.md) covers:
- Market sizing (TAM/SAM/SOM)
- Pricing strategy + unit economics (CAC $5-8, LTV ~$32)
- SMART goals: Year 1 → Year 3
- Moats + risk register
- A one-page pitch in the appendix

## Production release

See [`docs/PRODUCTION.md`](./docs/PRODUCTION.md) for the full Play Store + App Store + Web checklist.

## Quick start (development)

```bash
# 1. Bootstrap the static content
cd pb
node scripts/pb-bootstrap.mjs
node scripts/seed.mjs
node scripts/mark-pro.mjs

# 2. (One time) Set up Appwrite for user data
cd scripts/appwrite
npm install
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
APPWRITE_PROJECT_ID=... \
APPWRITE_API_KEY=... \
node appwrite-setup.mjs

# 3. Web app
cd ../../web
npm install
npm run dev          # http://localhost:3001

# 4. Flutter app
cd ../app
bash scripts/setup.sh
flutter run
```

## Content

| Type | Count | Where |
|---|---|---|
| Authors | 6 | `rup_authors` (Marcus Aurelius, Seneca, Epictetus, Musonius Rufus, Ryan Holiday, William Irvine) |
| Primary works | 10 | `rup_works` |
| Themes | 8 | `rup_categories` |
| Lessons | 15 | `rup_lessons` |
| Quotes | 53 | `rup_quotes` |
| Achievements | 12 | `rup_achievements` |
| Plans | 3 | `rup_plans` (free + pro_monthly + pro_yearly; pro_lifetime deprecated) |

## License

[MIT](./LICENSE) — see LICENSE file.

## Quotes are by their authors

Marcus Aurelius (121-180 AD), Seneca (4 BC - 65 AD), Epictetus (50-135 AD),
Musonius Rufus (30-101 AD), Ryan Holiday (modern), William B. Irvine (modern).
Lesson content under `pb/seed/lessons.mjs` is original synthesis by the
project author; the Stoic quotes themselves are public domain (the original
texts are >1900 years old).
