# RiseUP — Gap Audit (what's actually missing/broken)

> Real audit as of 2026-07-02. I went through the live codebase, PB schema,
> and live Appwrite state. This is what's actually true, not what the
> commit log implies.

## 🚨 Critical (production-breaking)

### B1. Reflection sheet never shows after lesson completion
**File:** `app/lib/screens/lesson_detail_screen.dart:45`
```dart
// After completion: show reflection sheet if we have a prompt for this lesson
final prompt = await ref.read(pocketBaseProvider).getPromptForLesson(lesson.id);
```
**Bug:** `lesson` is undefined in this scope. `lesson` only exists inside `lessonAsync.when(...)`'s data callback. The reflection sheet, the most important post-lesson engagement hook, **never fires**.

**Fix:** Capture the lesson from `lessonAsync.valueOrNull` before entering `_markComplete`, or fetch the lesson by slug from PB at the start of `_markComplete`.

### B2. Free-tier lesson limit isn't enforced
**Constant:** `AppConstants.freeLessonsPerWeek = 4`
**Reality:** Defined but never read anywhere. Anonymous users can read all 15 lessons freely. Free-tier users (signed in, not Pro) can read all Pro lessons too.

**Fix:** Add a guard in `lesson_detail_screen` and `lesson_card` that checks `freeLessonsPerWeek` against `user.completedThisWeek`. Or read from PB plan record (limits.per_week).

### B3. PB schema mismatch on lessons: `xp_reward`
**Files:** `pb/scripts/seed.mjs:219` writes `xp_reward: a.xp_reward` to lessons, but `pb/scripts/pb-bootstrap.mjs` doesn't include `xp_reward` in `rup_lessons` schema. The field is only on `rup_achievements`.

**Result:** Every lesson in PB has no `xp_reward`. Hardcoded `xpEarned: 10` everywhere in the app.

**Fix:** Either add `xp_reward` to `rup_lessons` schema OR remove the `xp_reward` write from `seed.mjs` and accept the constant.

---

## 🟠 Major (visible gaps)

### M1. Payment is mocked
**File:** `app/lib/services/appwrite_service.dart:240` — `startMockSubscription()` creates a row but doesn't charge anything. User clicks "Buy Pro" → instant Pro access, no money moves. Paywall screen openly says "mock checkout".

**Fix path:**
- Web: Stripe Checkout (Payment Links for v1, full Checkout for v2)
- iOS/Android: RevenueCat (handles App Store + Play Store)
- Appwrite function or Cloudflare Worker that verifies Stripe webhook → updates `user_subscriptions.status = 'active'`

### M2. No Restore Purchases button
**File:** `app/lib/screens/paywall_screen.dart`
- **App Store guideline 2.1** requires this for any subscription. Currently absent.
- Fix: add a button (greyed out until RC is wired).

### M3. Streak tracking is fake
**File:** `app/lib/providers/auth_providers.dart:103` — `_refresh` doesn't touch `streakCurrent` or `streakLongest` at all. They're always `0` from the constructor default.

**Result:** Every signed-in user has `streak = 0` forever. The Streak Flame widget always says "0 d" or hidden. The biggest engagement lever in the app is broken.

**Fix:**
- Add `user_streaks` collection in Appwrite (`userId`, `currentStreak`, `longestStreak`, `lastActiveDate`).
- `markLessonComplete` updates it: if `lastActiveDate == yesterday`, increment; if `today`, no-op; else reset to 1.
- `_refresh` reads it.

### M4. Favorites UI doesn't exist
**Files:** `lesson_card.dart`, `quote_card.dart`, `library_screen.dart`
- The `user_favorites` collection is in Appwrite.
- The service has `getFavorites`, `addFavorite`, `removeFavorite`.
- **There is no button on any lesson card or quote card to favorite it.**
- Library has no "Favorites" tab.

**Fix:** Add bookmark icon to `LessonCard` + `QuoteCard` (with haptic + immediate UI flip), add Favorites tab to Library.

### M5. No way to view past journal entries
**File:** `reflection_sheet.dart` saves entries to `user_journal`. `appwrite_service.dart:374` has `getJournalEntries(limit: 14)`.
- **Nothing calls it.** Users write reflections that are immediately invisible.

**Fix:** Add a "Journal" tab to Library that lists past entries (newest first, paginated).

### M6. No search
**Files:** `library_screen.dart`, `quotes_screen.dart`
- The data is there (15 lessons, 53 quotes). There's no search UI anywhere.
- Fix: search bar in Library + Quotes. Server-side filter by title/text/author.

### M7. No onboarding illustrations
**Files:** `app/assets/` — only contains `README.md`.
- Onboarding cards in PB have `illustration` fields that point to images.
- The Flutter `onboarding_screen` doesn't render them.

**Fix:** Add illustrations to assets, render in onboarding.

### M8. No audio for lessons or quotes
- The whole "audio sprint" from `CACHE-AND-DOWNLOADS.md` is not started.
- TTS pipeline (MiniMax TTS → R2 CDN) is unwritten.
- `rup_lessons` and `rup_quotes` have no `audioUrlLo` / `audioUrlHi` fields.

**Fix:** Full sprint per spec doc. Pre-generate for the 15 lessons + 53 quotes = ~$2 one-time.

### M9. Server-push notifications never deployed
- `server/notifications/src/index.ts` is local-only scaffold.
- Cloudflare Worker never deployed.
- FCM never integrated in Flutter app.
- Server-push is a documented "Year 2" feature, but the seam is half-built.

**Fix:** Wire `firebase_messaging` into Flutter, deploy Worker, configure FCM service account. Deferred per plan.

### M10. Quote sharing missing
**File:** `app/lib/widgets/quote_card.dart`
- Tap a quote card → `incrementQuotesRead`. No "share to Twitter/Instagram" option.
- This is the lowest-effort viral hook we have.

**Fix:** Add a `share_plus` integration with a context menu on long-press.

### M11. Notification permission not requested at onboarding
- `permission_handler` is in `pubspec.yaml` but `requestPermission()` is only called from notification_service if scheduled. iOS users get a generic notification prompt or no prompt at all.
- Android 13+ requires runtime prompt.

**Fix:** After onboarding card 3 (Welcome screen), trigger `requestPermission()`. If denied, continue silently.

---

## 🟡 Polish / UX gaps

### P1. No confetti on lesson completion
- `lib/widgets/confetti.dart` exists but is never invoked.
- Hook it into `_markComplete` on success.

### P2. No achievement auto-unlock
- `user_achievements` collection exists. `Achievement.conditionType` has values like `first_lesson`, `streak`, `lessons_completed`.
- **Nothing checks these conditions after a lesson is marked complete.**
- Users complete 5 lessons but no "5 Lessons Completed" achievement fires.

**Fix:** After `markLessonComplete`, run a check-engine that evaluates `Achievement` rows against user state and inserts into `user_achievements` on first match. Trigger confetti + haptic on unlock.

### P3. Daily reminder copy is generic
**File:** `reminder_scheduler.dart:115`
- Body = "5 minutes. Today's practice."
- For Year 1, we want A/B testable variants in PB. Defer.

### P4. Settings theme switcher is decorative
**File:** `settings_screen.dart:177`
- `_onThemeChanged` saves the value but `MaterialApp.themeMode` doesn't read it.
- App stays in light mode regardless.

**Fix:** Wrap `MaterialApp` in a `ConsumerWidget`, read themeMode from `SharedPreferences`, pass to `MaterialApp.themeMode`.

### P5. No offline indicator
- App dies silently with "Could not load" when offline.
- No banner that says "You're offline, showing cached."

**Fix:** Add `connectivity_plus`, show a top banner when offline. (Defer to cache sprint.)

### P6. No error logging / Sentry
- `debugPrint` in `notification_service.dart:151` — only fires in debug mode. In production, errors vanish.
- No Sentry, no Bugsnag, no Rollbar, nothing.

**Fix:** Add `sentry_flutter`. Wire to global error handlers. (Defer.)

### P7. No analytics
- No events tracked. We can't answer "what % of users open the app 3+ times in week 1?"
- Fix: add PostHog or Plausible. (Defer.)

### P8. No app icon set
**File:** `app/assets/` — no `icon.png`, no adaptive icon files.
- `flutter_native_splash` will use whatever is in `flutter_launcher_icons` config.
- Without it, the app will compile with default Flutter logo.

**Fix:** Add icon to assets, configure `flutter_launcher_icons` in `pubspec.yaml`.

### P9. No splash screen
- App opens → white flash → home. Not on-brand.
- Fix: `flutter_native_splash` configured with `AppColors.paper` + logo.

### P10. No i18n
- 100% English. Per BUSINESS-PLAN.md, target market includes SG/MY/JP — non-English markets.
- Fix: `.arb` files + `flutter_localizations`. (Defer to post-launch.)

### P11. Anonymous users can read everything
- `lesson.isPro` only blocks the UI element. Tapping it doesn't gatekeep.

**Fix:** Already in M2 territory. Server-side enforcement needed.

### P12. No real device tested
- `flutter create .` not run yet (no `ios/`, no `android/` platform glue).
- No simulator build, no real device test.

---

## 🔵 Architectural gaps

### A1. No offline cache layer
- Every screen does `ref.watch(allLessonsProvider)` which is a network call.
- Open the app on a flight → blank screen.

**Fix:** Drift-based content cache. (Sprint 1 of CACHE-AND-DOWNLOADS.md.)

### A2. No background sync queue
- User marks a lesson complete while offline → `markLessonComplete` fails → snackbar shown.
- The local write isn't queued.

**Fix:** Sync queue in drift. (Same sprint.)

### A3. No crash safety on Appwrite schema migration
- `appwrite-setup.mjs` adds new fields but won't re-run cleanly if a field already exists.
- The fields added last sprint (`marketingOptIn`, `quotesRead`, `onboardingCompletedAt`) may not actually exist on the live Appwrite instance. Need to re-run the setup script + verify.

**Fix:** Verify on live instance, add idempotency check.

### A4. PB auth creds in setup script
**File:** `pb/scripts/appwrite/appwrite-setup.mjs` — uses URL endpoint + project. Live creds are exposed in PB env vars but not in the script itself. Good.

### A5. `flutter create .` not run
**Files:** no `app/ios/`, no `app/android/{gradle,kotlin}/`
- We have `app/android/app/src/main/AndroidManifest.xml` (hand-written) but no gradle files.
- No `app/ios/Runner.xcodeproj/`.

**Fix:** `cd app && flutter create .` to generate platform glue. Verify bundle id (`com.albertlaudia.riseup`).

### A6. No signing config
**File:** `app/android/key.properties` — missing.
- Release builds will fail without a keystore.

**Fix:** Generate keystore, create `key.properties`, configure `android/app/build.gradle`.

---

## 📊 What % is production-ready?

| Area | % | Notes |
|------|---|-------|
| Static content (lessons, quotes, authors, plans) | 95% | All seeded, all rendering, just missing audio + cover images |
| Auth (sign up / sign in / sign out / forgot) | 85% | Appwrite Email/Password works. Missing Apple/Google/magic-link. Missing email verification. |
| Profile / settings | 70% | Real data, friendly errors, danger zone. Missing actual theme switch. Missing data export. |
| Home / library / quotes | 80% | Real data, friendly copy, branching greetings. Missing search/filter. |
| Daily reminder | 75% | Local scheduling works. Server-push scaffold only. |
| Paywall | 30% | Plans render. Mock checkout. No Stripe/RevenueCat. |
| Engagement (streak, favorites, journal, achievements) | 40% | Schema in Appwrite, but no UI/automation. Streak is permanently 0. |
| Audio downloads / smart download | 0% | Spec only. |
| Offline cache | 5% | Some local prefs but no real content cache. |
| Analytics / crash reporting | 0% | None. |
| i18n | 0% | English only. |

**Overall: 50-60% production-ready for a v0.1 closed beta. 30-40% ready for public launch.**

The biggest gaps that aren't "deferred to a future sprint" but are actively broken:
1. Streak tracking (B/M3) — always 0
2. Favorites UI (M4) — invisible despite data model existing
3. Journal view (M5) — entries write but nothing reads
4. Reflection sheet doesn't fire (B1)
5. Achievement auto-unlock (P2)

These are all "the data layer is built but the UI/automation isn't wired." That's the sweet spot to fix next.