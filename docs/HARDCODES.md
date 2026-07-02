# RiseUP — Hardcoded Values Inventory

> Every literal in the codebase that should become configuration, constant,
> or backend-driven. Sorted by blast radius and fix cost.

Last reviewed: 2026-07-02

---

## Severity legend

- 🟠 **Must fix before App Store submission** — visible to user / wrong on real data
- 🟡 **Should fix before launch** — embarrassing but not blocking
- 🟢 **Acceptable as-is** — design tokens, internal constants

---

## 🟠 Must fix

### Demo profile hardcodes
**File:** `app/lib/screens/profile_screen.dart`
```dart
Text('Quotes read',     value: '0', icon: '📜'),     // <-- never changes
Text('Longest streak', value: '${user?.streakLongest ?? 0} d', icon: '🏔️'),
```
- "Quotes read" is literally hardcoded to `'0'` — a user who has read 50 quotes sees `0`.
- Fix: track in user_state via `quotesRead` field, persist via Appwrite.

**Action:** Add `quotesRead` to `UserState` and `user_progress`. Increment on quote view.

### Notification reminder time options
**File:** `app/lib/screens/settings_screen.dart:182-185`
```dart
options: const [
  ('06:00', '6:00'),
  ('07:00', '7:00'),
  ('08:00', '8:00'),
  ('21:00', '21:00'),
],
```
- Only 4 time options. US users will want `5:00`, `9:00`, etc.
- Fix: move to PB `rup_settings` collection OR keep 4 presets but add a custom time picker.

**Action:** Add a "Custom" option that opens a time picker.

### App identifier inconsistency
**Files:**
- `app/android/app/build.gradle` — needs to be set (currently uses default `com.example.app`)
- `app/ios/Runner/Info.plist` — `PRODUCT_BUNDLE_IDENTIFIER`
- `app/lib/config.dart` — comment says `com.albertlaudia.riseup`

```bash
# Verify with:
grep -rn "applicationId\|namespace\|PRODUCT_BUNDLE_IDENTIFIER" app/
```

**Action:** Lock in `com.albertlaudia.riseup` across all platforms.

### App version in About screen
**File:** `app/lib/screens/about_screen.dart`
- Doesn't show version. App Store requires it for support tickets.
- Fix: read from `package_info_plus` → `PackageInfo.fromPlatform()`.

**Action:** Add `package_info_plus` dep, render version on About.

### Privacy / Terms URLs
**File:** `app/lib/screens/about_screen.dart`
- Currently no links.
- Fix: add `https://riseup.app/privacy` and `https://riseup.app/terms` (host wherever — PocketBase has a static-files endpoint).

**Action:** Add to PB static files + render links in About.

### Support email
**File:** `app/lib/screens/about_screen.dart` (and sign-in error copy)
- No support email anywhere. Users with problems have nowhere to go.
- Fix: `support@riseup.app` — create the inbox OR set up a Zendesk / Crisp / Formspree redirect.

**Action:** Set up support email, add `mailto:` link in About + Settings.

### Restore-purchases button (paywall)
**File:** `app/lib/screens/paywall_screen.dart`
- App Store **requires** "Restore Purchases" if you have a subscription.
- Fix: add button, wire to RevenueCat `Purchases.restorePurchases()` once integrated.

**Action:** Add button now (disabled until RC wired); label says "Coming soon" until then.

### Delete-account flow (settings)
**File:** `app/lib/screens/settings_screen.dart`
- GDPR / CCPA / App Store guideline: users must be able to delete their account.
- Fix: add "Delete account" button with confirmation → `appwrite.account.delete()`.

**Action:** Add to Settings → Danger zone.

### Export-my-data
- Same as above — GDPR right to data portability.
- Fix: button → query all collections for `userId=$self`, JSON.stringify, share.

**Action:** Add to Settings → Danger zone.

---

## 🟡 Should fix

### Lesson XP reward
**File:** `app/lib/screens/lesson_detail_screen.dart`
- "+10 XP" after completion — should be per-difficulty in PB.
- Fix: read `xpReward` from PB lesson.

**Action:** Add `xp_reward` field to `rup_lessons` (5/10/20 by difficulty), update `user_progress` accordingly.

### Streak freeze message
**File:** `app/lib/services/reminder_scheduler.dart` (and onboarding)
- "Streak freezes available" — count `streakFreezesUsed` in user_settings but no UI.
- Fix: surface in profile (small stat), settings (reset).

**Action:** Add to ProfileScreen stats row.

### Onboarding last card missing CTA
**File:** `app/lib/screens/onboarding_screen.dart`
- Third card: "Begin" → home, but no "Open today's lesson" deep-link.
- Fix: last card button → push home with auto-scroll to today's lesson + brief highlight pulse.

**Action:** Wire deep-link to first lesson.

### Settings: Theme switcher doesn't switch
**File:** `app/lib/screens/settings_screen.dart`
- Theme is set (`auto/light/dark`) but no `ThemeMode` is read.
- Fix: feed into `MaterialApp.themeMode`.

**Action:** Wire themeMode through providers.

### Notification copy
**File:** `app/lib/services/reminder_scheduler.dart`
- `"Today's practice"` + `lesson.title` — fine, but should be A/B testable.
- Fix: move copy variants to PB `rup_settings.notif_copy_variants`.

**Action:** Add collection + read from there.

### Empty-state messages
**File:** `app/lib/screens/library_screen.dart`, `app/lib/screens/profile_screen.dart`, etc.
- Most empty states don't exist.

**Action:** Build `EmptyState` widget, apply to all collections views.

### Pull-to-refresh
- Implemented in some screens (`RefreshIndicator`), missing in others.

**Action:** Audit + add where missing.

---

## 🟢 Acceptable as-is

### Color hex values
**File:** `app/lib/theme/app_colors.dart`
- Intentional design tokens. Should NOT be moved to PB.

### Typography sizes
**File:** `app/lib/theme/app_text_styles.dart`
- Intentional typography. Should NOT be moved to PB.

### Channel ID
**File:** `app/lib/services/notification_service.dart`
- `'riseup_daily_reminder'` — internal, intentional.

### Notification ID
**File:** `app/lib/services/notification_service.dart`
- `1001` — internal.

### API endpoint defaults
**File:** `app/lib/config.dart`
- Default values overridable via `--dart-define`. Good pattern.

### Difficulty enum values
- `'beginner' / 'intermediate' / 'advanced'` — must match PB values for data integrity.

### Achievement codepaths
- `'first_step'`, `'week_warrior'`, etc — must match PB exactly.

### Plan interval values
- `'monthly' / 'yearly'` — must match PB.

### `role: 'pro' / 'free'`
- Must match PB tier values.

### Color hex in marketing
- The whole "Walrus paper / Ink / Accent" palette is by design.

---

## Things that look hardcoded but are actually in PB ✓

- Lessons (title, body, slug, author)
- Quotes (text, source, author)
- Authors (name, bio, era)
- Categories (Stoic / Buddhist / Modern / etc.)
- Achievements (title, condition, xpReward)
- Plans (price, interval, features)
- Onboarding cards (title, body, illustration)
- Quick practices (title, body, duration)
- Reflection prompts
- Free-tier limits (lesson count per week)

These all flow through `lib/services/pocketbase_service.dart` and get cached in providers.

---

## Constants file (`app/lib/config/app_constants.dart`)

Pulling these into one place:

```dart
class AppConstants {
  AppConstants._();

  // Branding
  static const String appName = 'RiseUP';
  static const String appTagline = 'A daily Stoic practice.';
  static const String supportEmail = 'support@riseup.app';
  static const String privacyUrl = 'https://riseup.app/privacy';
  static const String termsUrl = 'https://riseup.app/terms';

  // Bundle
  static const String bundleId = 'com.albertlaudia.riseup';

  // Notifications
  static const String notifChannelId = 'riseup_daily_reminder';
  static const String notifChannelName = 'Daily reminder';
  static const int notifIdDailyReminder = 1001;
  static const String defaultReminderTime = '07:00';
  static const List<String> reminderTimeOptions = ['06:00', '07:00', '08:00', '21:00'];

  // Engagement defaults
  static const int defaultXpReward = 10;
  static const int onboardingFirstLessonHighlightSeconds = 8;
  static const int ratingPromptAfterDays = 7;
  static const int ratingPromptAfterLessons = 5;

  // Limits
  static const int freeLessonsPerWeek = 4;
  static const int freeReflectionPromptsPerWeek = 3;
  static const int maxCachedLessons = 50;
  static const int maxCachedQuotes = 200;
  static const int maxDownloadsBytes = 500 * 1024 * 1024;  // 500 MB

  // Daily pick
  static const DateTime dailyPickStart = DateTime(2024, 1, 1);

  // Deep links
  static const String deepLinkScheme = 'riseup';
}
```

This file ships in this sprint.

---

## Migration path

For each 🟠 item, the order of operations is:

1. **Add PB field / setting** (if backend-driven)
2. **Update `UserState` / model** with the new field
3. **Update `AppwriteService.saveX()`** to write the field
4. **Update the UI** to read from model instead of literal
5. **Test** in the build
6. **Document** the new flow in `docs/PRODUCTION.md`

For pure client-side constants (like notification IDs, time options), just
move to `app_constants.dart`.