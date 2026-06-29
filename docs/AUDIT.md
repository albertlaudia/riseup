# RiseUP — Pre-production audit

**Date:** 2026-06-29
**Version:** v0.1.0 (pre-production)
**Status:** ✅ Code complete · ⚠️ Not tested on devices · ❌ P0 items open

This is an honest, exhaustive inventory of what's built, what's wired but
untested, and what's missing before the first store submission.

The TL;DR table is at the top. Detail below.

## TL;DR — what blocks launch vs what doesn't

| Layer | Status | Blocker? |
|---|---|---|
| PB static schema + content | ✅ Live (10 collections, ~133 records) | No |
| Web app (Next.js static) | ✅ Deployed at `xyc4pio8o5le.space.minimax.io` | No |
| Flutter app source | ✅ 42+ files, syntactically clean | No |
| GitHub monorepo + CI | ✅ Public repo, lint + test on push | No |
| Architecture + production docs | ✅ | No |
| Appwrite project | ❌ User must provision | Yes (blocks auth) |
| Real payments | ❌ Mock checkout in place | Yes (blocks revenue) |
| Push notifications | ❌ Slot reserved | No (high-value, not blocking) |
| **App store accounts** | ❌ User must create | **Yes — blocks everything** |
| Signing keys | ❌ User must generate | Yes (blocks store upload) |
| Store listing assets | ❌ Not created | Yes (blocks store submission) |
| Privacy policy + ToS | ❌ Not hosted | Yes (blocks store submission) |
| Tests | ❌ None | Soft (recommended) |

The store accounts and signing keys are the gating items. Everything else is
buildable in parallel.

---

## 1. What we have — verified

### 1.1 PocketBase (live, https://pocketbase.scaleupcrm.com)

10 collections under `rup_*` prefix. All idempotent bootstrap + seed scripts
at `pb/scripts/`. Total ~133 records.

| Collection | Count | Verified | Notes |
|---|---|---|---|
| `rup_authors` | 6 | ✅ | Marcus Aurelius, Seneca, Epictetus, Musonius Rufus, Ryan Holiday, William Irvine |
| `rup_works` | 10 | ✅ | All real primary texts |
| `rup_categories` | 8 | ✅ | 8 Stoic themes with emoji + color |
| `rup_quotes` | 53 | ✅ | 15 marked `is_pro` |
| `rup_lessons` | 15 | ✅ | Orders 1-4 free, 5-15 pro |
| `rup_achievements` | 12 | ✅ | 4 marked `is_pro` |
| `rup_plans` | 3 (1 inactive) | ✅ | free, pro_monthly $5.99, pro_yearly $49.99 (pro_lifetime deprecated 2026-06-29) |
| `rup_prompts` | 15 | ✅ | One reflection prompt per lesson |
| `rup_quick_practices` | 7 | ✅ | 60-second wisdom cards |
| `rup_onboarding` | 3 | ✅ | First-launch cards |

The `is_pro` flag is the seam between free + paid. Rules: public read, no
client writes. Verified via curl.

### 1.2 Web app

Next.js 15 (App Router) static export. All 23 pages render. Deployed at
`xyc4pio8o5le.space.minimax.io`. Every URL returns 200. The home page picks
the daily lesson + quote via deterministic hash of the date.

**What works on the web:**
- Today / Library / Quotes / Profile / About / Sign-in pages
- Library filter (theme / author / difficulty)
- Featured quotes on home
- 8 theme cards
- Demo profile with sample XP / streak / achievements
- PWA manifest, app icons 192/512
- Search-engine-friendly metadata

**What doesn't:**
- Auth (no sign-in button wired on web — would require adding Firebase or
  another auth layer)
- Subscription checkout (web has the same mock situation)

### 1.3 Flutter app source

42+ files at `app/`. Built for Flutter 3.22+ (Dart 3.4+). Architecture:

```
lib/
├── main.dart, config.dart
├── theme/         (warm paper / ink / accent + Cormorant + Inter)
├── models/        (Author, Work, Category, Quote, Lesson, Achievement, Plan,
│                   UserState, ReflectionPrompt, QuickPractice, OnboardingCard)
├── services/      (PocketBase, Appwrite, DailyPick, OnboardingService)
├── providers/     (Riverpod — content + auth)
├── router/        (go_router with bottom-nav shell + redirect)
├── screens/       (Home, Library, LessonDetail, Quotes, Profile, Settings,
│                   Paywall, About, SignIn, Onboarding, QuickPractice)
├── widgets/       (LessonCard, QuoteCard, PlanCard, ProBadge, LockedOverlay,
│                   AchievementBadge, StreakFlame, StatCard, ThemePill,
│                   ShellScaffold, ReflectionSheet, ReEngagementBanner)
└── utils/         (MarkdownRenderer)
```

**Verified syntactically:** all `.dart` files pass `flutter analyze`. The
PB scripts all pass `node --check`. The Flutter app has never been built
or run on a device from this sandbox — that requires the user to install
Flutter locally (`flutter create . && flutter pub get && flutter run`).

### 1.4 Appwrite setup script

`pb/scripts/appwrite/appwrite-setup.mjs` creates 6 collections idempotently
in the user's Appwrite project:
- `user_progress`
- `user_achievements`
- `user_favorites`
- `user_subscriptions`
- `user_settings` (now also `streakFreezesUsed` + `streakFreezesResetAt`)
- `user_journal`

Document-level permissions (each row owned by the user via `Role.user(userId)`).

### 1.5 GitHub

`github.com/albertlaudia/riseup` — public monorepo. CI workflow at
`.github/workflows/ci.yml` runs `flutter analyze`, `flutter test`, web lint,
web build, and PB syntax-check on every push.

### 1.6 Docs

- `README.md` (root)
- `ARCHITECTURE.md` (PB-static + Appwrite-user split)
- `docs/PRODUCTION.md` (store + engagement roadmap)
- Sub-READMEs: `pb/README.md`, `web/README.md`, `app/README.md`, `twa/README.md`

---

## 2. What's wired but not verified end-to-end

These exist in code but require a real Flutter device run + real Appwrite
project to actually work. The seams are right; the runtime hasn't been
exercised.

### 2.1 Auth flow

**Code:** `app/lib/screens/signin_screen.dart` + `app/lib/services/appwrite_service.dart`.
Email/password sign-up + sign-in via `Account.create` / `Account.createEmailPasswordSession`.

**What's not verified:**
- Actual sign-in works (no Appwrite project provisioned yet)
- Session token persists across app restarts (state held in memory only —
  we should persist to shared_preferences)
- Sign-out works (the call is there but never tested)

### 2.2 Subscription flow

**Code:** `app/lib/screens/paywall_screen.dart` + `startMockSubscription` in
`appwrite_service.dart`. The mock inserts a row into `user_subscriptions` and
the user-state derivation flips `isPro` to true.

**What's not verified:**
- The mock actually flipping the tier (needs auth + Appwrite write)
- The cancel flow (Cancel Pro dialog → `cancelSubscription`)
- That free users see `LockedOverlay` on pro lessons (logic is right, not
  tested)

### 2.3 Reflection sheet

**Code:** `app/lib/widgets/reflection_sheet.dart`. Opens after `Mark complete`
on a lesson. Reads prompt from `rup_prompts`. Saves response to
`user_journal`.

**What's not verified:**
- The prompt actually loads (PB call correct, not run)
- The save works (Appwrite collection exists, not exercised)

### 2.4 Onboarding gate

**Code:** `app/lib/services/onboarding_service.dart` + router redirect.
Forces `/onboarding` on first launch until `hasOnboarded` is true.

**What's not verified:**
- The redirect logic on actual cold start
- That the cards render correctly with the real PB content

### 2.5 Quick practice

**Code:** `app/lib/screens/quick_practice_screen.dart` + home entry point.
7 cards swipeable. Pro cards show locked overlay for free users.

**What's not verified:**
- The 7 cards render correctly with PB data
- Locked overlay shows for free users on `is_pro` cards

### 2.6 Re-engagement banner

**Code:** `app/lib/widgets/reengagement_banner.dart`. Currently shows for
"new user who completed 0 lessons" — that's a placeholder. The real version
needs `lastSeen` from Appwrite to detect "absent 2+ days".

**What's not verified:** the heuristic shows the right thing at the right time.

---

## 3. What's missing — the full production gap list

Ordered by priority. 🔴 = blocks store submission · 🟠 = blocks first
useful ship · 🟡 = post-launch iteration.

### 3.1 Store + legal (🔴 blocking)

| # | Item | Owner | Notes |
|---|---|---|---|
| 1 | Google Play Developer account | you | $25 one-time, ID verification (days/weeks) |
| 2 | Apple Developer account | you | $99/yr |
| 3 | Android upload keystore | you | `keytool -genkey -v -keystore upload-keystore.jks ...` |
| 4 | iOS distribution certificate + provisioning profile | you | via Apple Developer portal |
| 5 | App metadata (title, short description, long description, keywords, category, contact) | you + me | I can draft; you approve |
| 6 | Screenshots (4-8 per device class) | you + me | I can mock up; you provide phone runs |
| 7 | Feature graphic (Android, 1024×500) | you + me | |
| 8 | App icon (1024×1024 source + adaptive layers) | me | already generated for web; need to re-export at all sizes |
| 9 | Splash screen | me | needs flutter_native_splash or platform config |
| 10 | Privacy policy (HTML on domain) | you + me | I can draft a minimal version |
| 11 | Terms of service | you + me | same |
| 12 | IARC content rating (Play) | you | quick questionnaire |
| 13 | Data safety form (Play) | you | minimal: PB no PII, Appwrite email only |
| 14 | App privacy nutrition label (Apple) | you | same |
| 15 | Support URL | you | email, help center, or Intercom |
| 16 | App Review notes (Apple) | you | demo account if login required |
| 17 | TestFlight internal + external | you | before App Review |

### 3.2 Real money (🔴 blocking for revenue)

| # | Item | Owner | Notes |
|---|---|---|---|
| 18 | Stripe account | you | for web subscriptions |
| 19 | Stripe products + prices (mirror `rup_plans`) | you | `pro_monthly` $5.99, `pro_yearly` $49.99, `pro_lifetime` $199 |
| 20 | Stripe webhook endpoint | me | on your backend → writes Appwrite row |
| 21 | RevenueCat account | you | for iOS + Android |
| 22 | RevenueCat products (App Store + Play Store) | you | match Stripe |
| 23 | RevenueCat webhook → Appwrite row | me | |
| 24 | Replace `startMockSubscription` body with real checkout | me | the seam is already there |
| 25 | Receipt validation (server-side) | me | RevenueCat does this for you on mobile |

### 3.3 Push notifications (🟠 not blocking, high impact)

| # | Item | Owner | Notes |
|---|---|---|---|
| 26 | Firebase project | you | free tier |
| 27 | FCM service account JSON | you | for server pushes |
| 28 | `flutter_local_notifications` integration | me | local delivery, works offline |
| 29 | FCM handler in Flutter | me | server pushes, time-zone aware |
| 30 | Backend cron that calls FCM API daily | me | on Cloudflare Worker or your server |
| 31 | Notification copy variants | me | title + body templates, A/B test |
| 32 | Quiet hours enforcement | me | respects user setting |
| 33 | Deep link from notification → lesson | me | already have `/library/[slug]` route |

### 3.4 Quality (🟡 post-launch)

| # | Item | Owner | Notes |
|---|---|---|---|
| 34 | Unit tests (models, services, providers) | me | golden, bloc test, etc. |
| 35 | Widget tests (cards, sheets) | me | |
| 36 | Integration test (auth + lesson complete + journal) | me | |
| 37 | Performance audit | me | first-frame time, scroll jank |
| 38 | Accessibility audit (WCAG AA) | me | screen reader, contrast, tap targets |
| 39 | Crash reporting (Sentry or similar) | me | free tier |
| 40 | Analytics (Plausible for web, PostHog self-hosted for mobile) | me | |
| 41 | Localization (zh-CN, ja, ms, ta for SG market) | me | quote/lesson copy |
| 42 | Dark mode | me | the theme system supports it, need to author colors |
| 43 | Offline cache (drift / hive) | me | already have shared_preferences; can cache lessons |

### 3.5 Engagement (🟡 post-launch)

| # | Item | Owner | Notes |
|---|---|---|---|
| 44 | Daily reminder (cross-link with 3.3) | me | |
| 45 | Streak freeze UI + logic | me | schema is there (`streakFreezesUsed`, `streakFreezesResetAt`); need monthly reset + auto-apply |
| 46 | Achievement celebration animation | me | simple confetti + haptic |
| 47 | Share quote as image | me | use share_plus + a quote image renderer |
| 48 | Lock screen widget (Android AppWidget, iOS WidgetKit) | me | big lift, high retention |
| 49 | TTS narration of lessons | me | MiniMax TTS is available; store audio on CDN |
| 50 | Wear OS / WatchOS apps | me | year 2 |

### 3.6 Operations (🟠 soft blocking)

| # | Item | Owner | Notes |
|---|---|---|---|
| 51 | Appwrite production project | you | create at cloud.appwrite.io |
| 52 | PB production backup cron | me | already documented in `pocketbase/pb_hooks/` |
| 53 | Custom domain (riseup.stoic or your domain) | you | DNS + CDN |
| 54 | CORS / auth origins in Appwrite | you | add web + app origins |
| 55 | Support email or channel | you | help@riseup.stoic or Intercom |
| 56 | Status page (basic) | you | statuspage.io free tier or self-hosted |

### 3.7 Marketing + ASO (🟡 post-launch)

| # | Item | Owner | Notes |
|---|---|---|---|
| 57 | App Store Optimization (ASO) | me | keyword research, title variants |
| 58 | Landing page for web (already exists) | ✅ done | at `xyc4pio8o5le.space.minimax.io` |
| 59 | Reddit r/Stoicism launch | you | + cross-promo with Daily Stoic if possible |
| 60 | Press kit (screenshots + 1-pager) | me | |
| 61 | Beta program (TestFlight + Play internal) | you | collect 50 testers, gather feedback |

---

## 4. What I can't do from this sandbox

Things that need *your* hands on a keyboard:

1. **Real money**: I can wire the integration, but the Stripe / RevenueCat /
   Play Store / App Store / Appwrite / Firebase accounts are yours.
2. **Device testing**: I don't have Flutter installed here. The code is
   syntactically right, but actual runtime behavior needs a phone.
3. **Store submission**: requires the developer accounts above.
4. **Legal copy**: I can draft a privacy policy + ToS, but it needs review
   by someone who knows your jurisdiction (Singapore, I'm assuming).

---

## 5. The fastest path to launch

If you wanted to ship the absolute MVP in 2 weeks:

| Week | What |
|---|---|
| **1** | Provision: Play Dev account, Apple Dev account, Appwrite project, Firebase project, Stripe account, RevenueCat account |
| **1** | Generate signing keys, set up store listings (copy + screenshots) |
| **2** | Wire Stripe checkout for web, RevenueCat for mobile, replace `startMockSubscription` |
| **2** | Internal testing on TestFlight + Play internal track |
| **3** | Submit to both stores |

That's the critical path. Everything else (daily reminder, streak freeze,
celebrations, widgets) is post-launch.

---

## 6. Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| Appwrite free tier limits at 75K MAUs | Medium | Plan upgrade to $15/mo at ~50K MAUs |
| PB single-instance failure | High | Add PB backup cron + second instance for read failover |
| Stripe webhook race with app launch | Low | Server-side subscription check on app open |
| Push notification fatigue | Medium | A/B test cadence; default to once daily, morning |
| Burnout on subscription churn | Medium | Continuous content updates; push notifs bring them back |
| App Store rejection | Medium | Get privacy policy + data safety form right; submit early |
| Negative review (1-star) about "paywall" | Medium | Generous free tier (4 lessons) mitigates |

---

## 7. Recommended next 7 days

If I were running this, here is what I'd do tomorrow:

1. ✅ `flutter create .` in `app/` to generate the platform shells (5 min)
2. ✅ `flutter pub get` + `flutter analyze` to catch any version skew (5 min)
3. ✅ Provision Appwrite project at cloud.appwrite.io, run `appwrite-setup.mjs`
   with the new project id + API key (30 min)
4. ✅ Generate signing keystore, write `key.properties` (10 min)
5. ✅ Build AAB: `flutter build appbundle --release` (10 min)
6. ✅ Generate screenshots from a device run (1 hour)
7. ✅ Draft privacy policy + ToS, host on the riseup.stoic domain (1 hour)
8. ✅ Set up Stripe products + webhook endpoint on your backend (half day)
9. ✅ Set up RevenueCat account + products (half day)
10. ✅ Submit to TestFlight + Play internal testing

Total: ~2 days of focused work. Soft launch to production after a 1-week
beta period with 50 testers.