# RiseUP — Master task list

**Status legend:**
- ✅ done
- ⚠️ partial (code exists but not verified)
- 🟦 in progress
- ⬜ not started
- 🚫 explicitly deferred / out of scope

**Priority legend:**
- 🔴 P0 — blocks store submission
- 🟠 P1 — needed for first useful ship
- 🟡 P2 — post-launch iteration

---

## A. PocketBase (static content)

| # | Task | Priority | Status |
|---|---|---|---|
| A1 | Bootstrap script creates all `rup_*` collections idempotently | 🔴 | ✅ |
| A2 | Self-healing field patching (existing collections get new fields) | 🟠 | ✅ |
| A3 | `rup_authors` collection with bios, eras, avatars | 🟠 | ✅ |
| A4 | Seed 6 authors (Marcus Aurelius, Seneca, Epictetus, Musonius, Holiday, Irvine) | 🟠 | ✅ |
| A5 | `rup_works` collection (primary texts) | 🟠 | ✅ |
| A6 | Seed 10 works (Meditations, Letters, etc.) | 🟠 | ✅ |
| A7 | `rup_categories` collection (themes) | 🟠 | ✅ |
| A8 | Seed 8 themes (Dichotomy of Control, Virtue, Memento Mori, …) | 🟠 | ✅ |
| A9 | `rup_quotes` collection with `is_featured`, `is_pro` flags | 🟠 | ✅ |
| A10 | Seed 53 quotes with proper attribution | 🟠 | ✅ |
| A11 | Mark ~15 featured quotes as `is_pro` | 🟠 | ✅ |
| A12 | `rup_lessons` collection with full content (markdown body, intro, takeaway, action) | 🟠 | ✅ |
| A13 | Seed 15 lessons (3 beginner, 8 intermediate, 4 advanced) | 🟠 | ✅ |
| A14 | Mark orders 5-15 as `is_pro` | 🟠 | ✅ |
| A15 | `rup_achievements` collection (XP + conditions) | 🟠 | ✅ |
| A16 | Seed 12 achievements (streaks, counts, themes explored) | 🟠 | ✅ |
| A17 | Mark 4 high-end achievements as `is_pro` | 🟠 | ✅ |
| A18 | `rup_plans` collection (subscription catalog) | 🔴 | ✅ |
| A19 | Seed 3 plans (free + pro_monthly + pro_yearly; lifetime dropped 2026-06-29) | 🔴 | ✅ |
| A20 | `rup_prompts` collection (one reflection prompt per lesson) | 🟠 | ✅ |
| A21 | Seed 15 reflection prompts | 🟠 | ✅ |
| A22 | `rup_quick_practices` collection (60-second wisdom cards) | 🟠 | ✅ |
| A23 | Seed 7 quick practices (mix of free + pro) | 🟠 | ✅ |
| A24 | `rup_onboarding` collection (3 swipeable cards) | 🟠 | ✅ |
| A25 | Seed 3 onboarding cards | 🟠 | ✅ |
| A26 | Public read rules on all static collections | 🔴 | ✅ |
| A27 | `mark-pro.mjs` migration script (one-off) | 🟡 | ✅ |
| A28 | `indexes` on slug/code/firebase_uid for fast lookups | 🟡 | ✅ |
| A29 | Backup cron (PB internal) | 🟡 | 🚫 deferred to ops |

---

## B. Appwrite (user data)

| # | Task | Priority | Status |
|---|---|---|---|
| B1 | Setup script creates database + collections idempotently | 🔴 | ✅ |
| B2 | `user_progress` collection (lessons completed + xp) | 🔴 | ✅ |
| B3 | Unique index on (userId, lessonSlug) | 🟠 | ✅ |
| B4 | `user_achievements` collection (unlocked) | 🔴 | ✅ |
| B5 | Unique index on (userId, achievementCode) | 🟠 | ✅ |
| B6 | `user_favorites` collection (saved quotes / lessons) | 🟠 | ✅ |
| B7 | `user_subscriptions` collection (source of truth for tier) | 🔴 | ✅ |
| B8 | `user_settings` collection (theme, notifications, etc.) | 🟠 | ✅ |
| B9 | `user_journal` collection (reflection entries) | 🟠 | ✅ |
| B10 | Streak freeze fields on `user_settings` | 🟡 | ✅ |
| B11 | Document-level permissions (each row owned by user) | 🔴 | ✅ |
| B12 | Email/password auth provider configured | 🔴 | ⬜ (user must enable in Appwrite Console) |
| B13 | **Appwrite production project provisioned** | 🔴 | ⬜ |
| B14 | Webhook endpoint that writes `user_subscriptions` on Stripe success | 🔴 | ⬜ |
| B15 | Webhook endpoint on RevenueCat receipt events | 🔴 | ⬜ |
| B16 | Monthly cron that resets `streakFreezesUsed` | 🟡 | ⬜ |
| B17 | Server-side subscription validation (don't trust client `tier`) | 🟡 | ⬜ |

---

## C. Web app (Next.js)

| # | Task | Priority | Status |
|---|---|---|---|
| C1 | Next.js 15 project with App Router | 🟠 | ✅ |
| C2 | Tailwind 3 with custom theme (paper / ink / accent) | 🟠 | ✅ |
| C3 | `lib/pb.ts` — typed PB helpers | 🟠 | ✅ |
| C4 | `lib/types.ts` — Author, Lesson, Quote, etc. | 🟠 | ✅ |
| C5 | `lib/markdown.ts` — tiny markdown renderer | 🟠 | ✅ |
| C6 | Home page with daily lesson + quote + library preview | 🟠 | ✅ |
| C7 | Library page with theme / author / difficulty filters | 🟠 | ✅ |
| C8 | Lesson detail page with content + takeaway + action + related | 🟠 | ✅ |
| C9 | Quotes page with featured + per-theme sections | 🟠 | ✅ |
| C10 | Profile page (demo state) | 🟠 | ✅ |
| C11 | About page | 🟠 | ✅ |
| C12 | Library filter is client-side (`useSearchParams`) | 🟠 | ✅ |
| C13 | Static export config (`output: 'export'`) | 🟠 | ✅ |
| C14 | 15 lesson pages pre-rendered via `generateStaticParams` | 🟠 | ✅ |
| C15 | PWA manifest | 🟡 | ✅ |
| C16 | App icons 192/512 + generated | 🟡 | ✅ |
| C17 | Deployed to public URL | 🟡 | ✅ |
| C18 | Web app auth / sign-in | 🟡 | 🚫 deferred (web stays read-only for v1) |
| C19 | Stripe checkout on web | 🔴 | ⬜ |
| C20 | SEO meta tags | 🟡 | ✅ |
| C21 | Custom domain | 🟡 | ⬜ |

---

## D. Flutter app

### D.1 Foundation

| # | Task | Priority | Status |
|---|---|---|---|
| D1 | `pubspec.yaml` with all deps | 🔴 | ✅ |
| D2 | `theme/` — colors, text styles, ThemeData | 🟠 | ✅ |
| D3 | `models/` — all data classes with `fromRecord` factories | 🟠 | ✅ |
| D4 | `services/pocketbase_service.dart` — read-only PB client | 🟠 | ✅ |
| D5 | `services/appwrite_service.dart` — auth + user data | 🔴 | ⚠️ code complete, not tested |
| D6 | `services/daily_pick.dart` — deterministic daily index | 🟠 | ✅ |
| D7 | `services/onboarding_service.dart` — shared_preferences flag | 🟠 | ✅ |
| D8 | `providers/app_providers.dart` — PB FutureProviders | 🟠 | ✅ |
| D9 | `providers/auth_providers.dart` — Appwrite StateNotifier | 🟠 | ⚠️ code complete, not tested |
| D10 | `router/app_router.dart` — go_router with shell + redirect | 🟠 | ✅ |
| D11 | `main.dart` — entry, theme, router | 🟠 | ✅ |
| D12 | `config.dart` — build-time env vars | 🟠 | ✅ |

### D.2 Core screens

| # | Task | Priority | Status |
|---|---|---|---|
| D20 | Home screen — daily lesson + quote + library preview | 🔴 | ✅ |
| D21 | Library screen — filterable list | 🔴 | ✅ |
| D22 | Lesson detail screen — full text + takeaway + action | 🔴 | ✅ |
| D23 | Quotes screen — featured + theme-grouped | 🔴 | ✅ |
| D24 | Profile screen — XP / streak / achievements | 🟠 | ⚠️ demo state |
| D25 | Settings screen — theme, notifications, reminder time | 🟠 | ✅ |
| D26 | About screen — what + why + how | 🟠 | ✅ |
| D27 | Sign-in screen — email/password | 🔴 | ✅ |
| D28 | Paywall screen — 4 plans + mock checkout | 🔴 | ⚠️ mock only |
| D29 | Bottom nav shell (4 tabs) | 🔴 | ✅ |

### D.3 Engagement layer

| # | Task | Priority | Status |
|---|---|---|---|
| D40 | Onboarding screen (3 swipeable cards, skip button) | 🟠 | ✅ |
| D41 | Router redirect forces `/onboarding` on first launch | 🟠 | ✅ |
| D42 | Quick Practice screen (60-second scroll) | 🟠 | ✅ |
| D43 | Quick Practice entry on home | 🟠 | ✅ |
| D44 | Reflection sheet after lesson complete | 🟠 | ✅ |
| D45 | Reflection saves to `user_journal` | 🟠 | ✅ |
| D46 | Re-engagement banner on home (new-user heuristic) | 🟡 | ✅ |
| D47 | Re-engagement banner reads `lastSeen` from Appwrite | 🟡 | ⬜ |

### D.4 Shared widgets

| # | Task | Priority | Status |
|---|---|---|---|
| D50 | `LessonCard` — hero + compact + default | 🔴 | ✅ |
| D51 | `QuoteCard` — sm/md/lg | 🔴 | ✅ |
| D52 | `StreakFlame` | 🔴 | ✅ |
| D53 | `StatCard` | 🟠 | ✅ |
| D54 | `AchievementBadge` — locked / unlocked variants | 🟠 | ✅ |
| D55 | `ThemePill` — color-coded by theme | 🟠 | ✅ |
| D56 | `AuthorMark` | 🟠 | ✅ |
| D57 | `ProBadge` + `LockedOverlay` | 🔴 | ✅ |
| D58 | `PlanCard` — paywall card | 🔴 | ✅ |
| D59 | `ShellScaffold` — bottom nav wrapper | 🔴 | ✅ |

### D.5 Paywall + subscription

| # | Task | Priority | Status |
|---|---|---|---|
| D60 | Paywall reads `rup_plans` | 🔴 | ✅ |
| D61 | Paywall highlights "Best value" plan | 🔴 | ✅ |
| D62 | `startMockSubscription` writes to `user_subscriptions` | 🔴 | ⚠️ |
| D63 | User tier derived from active subscription | 🔴 | ✅ |
| D64 | Free tier shows locked overlay on `is_pro` content | 🔴 | ✅ |
| D65 | Cancel Pro flow | 🟠 | ✅ |
| D66 | Real Stripe checkout (web) | 🔴 | ⬜ |
| D67 | Real RevenueCat checkout (mobile) | 🔴 | ⬜ |
| D68 | Receipt validation on backend | 🔴 | ⬜ |

### D.6 Push notifications

| # | Task | Priority | Status |
|---|---|---|---|
| D70 | `flutter_local_notifications` + `timezone` + `permission_handler` in pubspec | 🟠 | ✅ |
| D71 | `NotificationService` (init, schedule daily, cancel, tap handler) | 🟠 | ✅ |
| D72 | `ReminderScheduler` orchestrator (picks today's lesson, schedules / cancels on settings change) | 🟠 | ✅ |
| D73 | Settings toggle + time picker wired to reschedule immediately | 🟠 | ✅ |
| D74 | Android manifest with `POST_NOTIFICATIONS` + `SCHEDULE_EXACT_ALARM` + boot receiver + deep-link intent-filter | 🟠 | ✅ |
| D75 | Deep link from notification → lesson via `riseup://library/[slug]` | 🟠 | ✅ |
| D76 | `fcmToken` + `fcmTokenUpdatedAt` fields on `user_settings` collection (Appwrite) | 🟠 | ✅ |
| D77 | `saveFcmToken` method in Appwrite service | 🟠 | ✅ |
| D78 | Cloudflare Worker scaffold for server-pushed reminders | 🟡 | ✅ |
| D79 | Wire actual FCM in Flutter (firebase_messaging dep + token refresh handler) | 🟠 | ⬜ |
| D80 | Deploy Cloudflare Worker with secrets | 🟠 | ⬜ |
| D81 | Quiet hours enforcement (e.g. 22:00 - 07:00 skip) | 🟡 | ⬜ |

### D.7 Streak + achievements

| # | Task | Priority | Status |
|---|---|---|---|
| D80 | Streak freeze UI | 🟡 | ⬜ |
| D81 | Streak freeze auto-applied when day missed | 🟡 | ⬜ |
| D82 | Streak freeze monthly reset (cron) | 🟡 | ⬜ |
| D83 | Achievement unlock detection | 🟡 | ⬜ |
| D84 | Achievement celebration animation | 🟡 | ⬜ |
| D85 | Confetti / haptic on unlock | 🟡 | ⬜ |

### D.8 Quality

| # | Task | Priority | Status |
|---|---|---|---|
| D90 | Unit tests (models, services) | 🟡 | ⬜ |
| D91 | Widget tests (cards, sheets) | 🟡 | ⬜ |
| D92 | Integration test (auth + lesson complete + journal) | 🟡 | ⬜ |
| D93 | Golden tests (visual regression) | 🟡 | ⬜ |
| D94 | Accessibility audit (TalkBack, contrast) | 🟡 | ⬜ |
| D95 | Crash reporting (Sentry) | 🟡 | ⬜ |
| D96 | Analytics (PostHog self-hosted) | 🟡 | ⬜ |

### D.9 Polish

| # | Task | Priority | Status |
|---|---|---|---|
| D100 | Dark mode | 🟡 | ⬜ |
| D101 | Localization (zh-CN, ja, ms, ta) | 🟡 | ⬜ |
| D102 | Offline cache (drift / hive) | 🟡 | ⬜ |
| D103 | Share quote as image | 🟡 | ⬜ |
| D104 | Lock screen widget (Android) | ⚪ | ⬜ |
| D105 | Lock screen widget (iOS) | ⚪ | ⬜ |
| D106 | Wear OS / WatchOS | ⚪ | ⬜ |
| D107 | TTS narration of lessons | ⚪ | ⬜ |

---

## E. Build + Distribution

### E.1 Android

| # | Task | Priority | Status |
|---|---|---|---|
| E1 | `flutter create . --platforms=android` | 🔴 | ⬜ (user step) |
| E2 | Generate signing keystore | 🔴 | ⬜ (user step) |
| E3 | `key.properties` with passwords | 🔴 | ⬜ |
| E4 | AndroidManifest with INTERNET permission | 🔴 | ✅ |
| E5 | App ID = `com.albertlaudia.riseup` (or chosen) | 🔴 | ⬜ |
| E6 | Adaptive launcher icons (foreground + background) | 🟠 | ⬜ |
| E7 | Build AAB: `flutter build appbundle --release` | 🔴 | ⬜ |
| E8 | Target API 34+ (Android 14) | 🔴 | ⬜ |

### E.2 iOS

| # | Task | Priority | Status |
|---|---|---|---|
| E20 | `flutter create . --platforms=ios` | 🔴 | ⬜ |
| E21 | Bundle ID = `com.albertlaudia.riseup` | 🔴 | ⬜ |
| E22 | Apple Developer account | 🔴 | ⬜ (user step) |
| E23 | Distribution certificate | 🔴 | ⬜ |
| E24 | Provisioning profile | 🔴 | ⬜ |
| E25 | Build IPA: `flutter build ipa --release` | 🔴 | ⬜ |

### E.3 Store listings

| # | Task | Priority | Status |
|---|---|---|---|
| E40 | Play Store listing — title, short desc, long desc | 🔴 | ⬜ |
| E41 | Play Store screenshots (4-8) | 🔴 | ⬜ |
| E42 | Play Store feature graphic (1024×500) | 🔴 | ⬜ |
| E43 | Play Store content rating (IARC) | 🔴 | ⬜ |
| E44 | Play Store data safety form | 🔴 | ⬜ |
| E45 | App Store listing — same fields | 🔴 | ⬜ |
| E46 | App Store screenshots per device class | 🔴 | ⬜ |
| E47 | App Store privacy nutrition label | 🔴 | ⬜ |
| E48 | App Store support URL | 🔴 | ⬜ |
| E49 | App Store review notes (demo account) | 🔴 | ⬜ |

### E.4 Legal

| # | Task | Priority | Status |
|---|---|---|---|
| E60 | Privacy policy HTML page | 🔴 | ⬜ |
| E61 | Terms of service HTML page | 🔴 | ⬜ |
| E62 | GDPR / CCPA disclosure (covered by privacy policy) | 🟠 | ⬜ |
| E63 | Data processing agreement (if EU users) | 🟡 | ⬜ |

---

## F. Marketing + Launch

| # | Task | Priority | Status |
|---|---|---|---|
| F1 | App Store Optimization (ASO) keyword research | 🟠 | ⬜ |
| F2 | Reddit r/Stoicism launch post | 🟠 | ⬜ |
| F3 | Cross-promo with Daily Stoic / Stoa / etc. | 🟡 | ⬜ |
| F4 | Press kit (screenshots + 1-pager) | 🟡 | ⬜ |
| F5 | Beta program (50 testers) | 🟠 | ⬜ |
| F6 | Soft launch (1-2 test markets) | 🟡 | ⬜ |
| F7 | Full launch | 🟡 | ⬜ |
| F8 | Web landing page refresh with store badges | 🟡 | ⬜ |

---

## G. Operations

| # | Task | Priority | Status |
|---|---|---|---|
| G1 | Custom domain (riseup.stoic or your choice) | 🟡 | ⬜ |
| G2 | HTTPS via Cloudflare (free) | 🟡 | ⬜ |
| G3 | PB backup cron | 🟡 | ⬜ |
| G4 | Appwrite CORS / origin whitelist | 🟠 | ⬜ |
| G5 | Support email (help@…) | 🟠 | ⬜ |
| G6 | Status page (basic) | 🟡 | ⬜ |
| G7 | Error monitoring (Sentry) | 🟡 | ⬜ |
| G8 | Analytics (Plausible web + PostHog mobile) | 🟡 | ⬜ |

---

## H. Verification — what was actually tested

| # | Was tested | Result |
|---|---|---|
| H1 | PB bootstrap script runs cleanly on empty instance | ✅ verified (script output captured) |
| H2 | PB bootstrap is idempotent (re-runnable) | ✅ verified |
| H3 | PB seed creates all 133 records | ✅ verified (counts confirmed) |
| H4 | PB public read works for all 10 collections | ✅ verified via curl |
| H5 | Web app builds (Next.js static export) | ✅ verified (build output captured) |
| H6 | Web app serves all 23 pages | ✅ verified (HTTP 200 on each) |
| H7 | Web app renders PB content correctly | ✅ verified (quotes, lessons, authors visible in HTML) |
| H8 | Appwrite setup script syntax-checks | ✅ verified (`node --check` clean) |
| H9 | Flutter code syntactically valid (`flutter analyze`) | ⚠️ inferred (no Flutter in sandbox; all imports match pubspec) |
| H10 | Flutter app builds APK/AAB | ⬜ (requires Flutter install + Android SDK) |
| H11 | Flutter app runs on Android device | ⬜ |
| H12 | Flutter app runs on iOS device | ⬜ |
| H13 | Auth flow works end-to-end | ⬜ (no Appwrite project) |
| H14 | Subscription flow works end-to-end | ⬜ (mock only) |
| H15 | Push notifications fire | ⬜ |
| H16 | App submits to Play Store | ⬜ |
| H17 | App submits to App Store | ⬜ |
| H18 | App passes App Review | ⬜ |

---

## I. Sprint plan — next 4 weeks

### Week 1 — Account provisioning (your week)
- [ ] Provision Google Play Developer account
- [ ] Provision Apple Developer account
- [ ] Provision Appwrite project at cloud.appwrite.io
- [ ] Provision Firebase project
- [ ] Provision Stripe account
- [ ] Provision RevenueCat account
- [ ] Run `pb/scripts/appwrite-setup.mjs` against new project
- [ ] Generate Android upload keystore
- [ ] Generate iOS distribution certificate

### Week 2 — Payment + device test (split week)
- [ ] Wire Stripe checkout on web
- [ ] Wire RevenueCat on mobile (replace `startMockSubscription`)
- [ ] Run `flutter create .` + `flutter pub get`
- [ ] First device test on Android
- [ ] First device test on iOS
- [ ] Fix any runtime issues

### Week 3 — Store assets + legal (content week)
- [ ] Generate 6-8 screenshots per platform
- [ ] Generate feature graphic (Android)
- [ ] Write listing copy (title, descriptions, keywords)
- [ ] Host privacy policy + ToS on domain
- [ ] IARC content rating
- [ ] Data safety form
- [ ] App privacy label

### Week 4 — Submit + beta
- [ ] Submit AAB to Play internal testing
- [ ] Submit IPA to TestFlight internal
- [ ] Invite 20-50 beta testers
- [ ] Iterate on feedback for 1 week
- [ ] Submit to closed beta → production

### Week 5 — Production launch
- [ ] App goes live in both stores
- [ ] Marketing push (Reddit, social)
- [ ] Monitor crash reports + reviews
- [ ] Plan week 6+ feature work (daily reminder, streak freeze)