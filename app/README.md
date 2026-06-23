# RiseUP — Flutter app

A daily Stoic practice app. Lessons, quotes, streaks, and a paywall that doesn't beg.

```
┌────────────────────────────────────────────────────────────────┐
│  PocketBase  (https://pocketbase.scaleupcrm.com)               │
│    STATIC content only (read-only):                            │
│      rup_authors · rup_works · rup_categories                   │
│      rup_quotes · rup_lessons · rup_achievements                │
│      rup_plans  (subscription catalog)                         │
│                                                                │
│  Appwrite  (user's project — see scripts/appwrite/)            │
│    USER data (auth + per-user):                                │
│      user_progress · user_achievements                         │
│      user_favorites · user_subscriptions · user_settings       │
└────────────────────────────────────────────────────────────────┘
            ▲                                       ▲
            │  read                                 │  read / write
            │                                       │
┌───────────┴───────────────────────────────────────┴─────────────┐
│  Flutter (this repo)                                           │
│    / (home) · /library · /library/[slug]                       │
│    /quotes · /profile · /settings · /paywall · /about          │
│    /signin  (Appwrite email/password)                          │
└────────────────────────────────────────────────────────────────┘
```

## Architecture

| Layer | File(s) | Notes |
|---|---|---|
| **Theme** | `lib/theme/` | Warm-paper / ink / accent palette, Cormorant Garamond + Inter via Google Fonts. |
| **Models** | `lib/models/` | Plain Dart classes with `fromRecord` factories. |
| **Services** | `lib/services/pocketbase_service.dart`, `lib/services/appwrite_service.dart` | One per backend. PB is read-only. Appwrite owns auth + writes. |
| **Providers** | `lib/providers/app_providers.dart`, `lib/providers/auth_providers.dart` | Riverpod. PB content is `FutureProvider`; user state is a `StateNotifier`. |
| **Router** | `lib/router/app_router.dart` | `go_router` with a bottom-nav `ShellRoute` and pushed detail routes. |
| **Screens** | `lib/screens/` | One file per top-level destination. |
| **Widgets** | `lib/widgets/` | `LessonCard`, `QuoteCard`, `PlanCard`, `ProBadge`, `LockedOverlay`, `AchievementBadge`, `StreakFlame`, `StatCard`, `ThemePill`, `ShellScaffold`. |

## The paywall is wired

- PB stores the **plan catalog** (`rup_plans`) and a static `is_pro` flag on lessons / quotes / achievements.
- The Flutter app reads `rup_plans` and renders the paywall.
- Appwrite stores the **per-user subscription** (`user_subscriptions`). The source of truth is the row, not the user's settings.
- The user's current tier is derived from `user_subscriptions` filtered by `status = 'active'` and not-yet-expired.
- For now, "checkout" is a `startMockSubscription` call that inserts a row with `source = 'admin'`. Real Stripe / RevenueCat plugs in here:

```dart
// lib/services/appwrite_service.dart → startMockSubscription(...)
// Real version: call your backend → it calls Stripe/RevenueCat → webhook → backend
// creates the user_subscriptions row.
```

## First-time setup

### 1. Install Flutter (one-time)

https://docs.flutter.dev/get-started/install

Pick your platform (macOS / Windows / Linux) and follow the steps. Confirm with:

```bash
flutter --version    # should print 3.22 or higher
flutter doctor       # all green
```

### 2. Generate the platform shells

`flutter create` writes the iOS / Android / macOS / Windows / Linux boilerplate that this repo doesn't track (because it's huge and platform-specific).

```bash
cd riseup_app
flutter create --project-name riseup --org com.albertlaudia --platforms=android,ios,web .
```

This is safe to re-run; it overwrites any missing platform files.

### 3. Add the INTERNET permission to Android

The default `flutter create` doesn't always set this for the right places. Verify
`android/app/src/main/AndroidManifest.xml` has:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.INTERNET" />
  <application
      android:label="RiseUP"
      android:icon="@mipmap/ic_launcher"
      android:usesCleartextTraffic="false">
    ...
  </application>
</manifest>
```

### 4. Set up Appwrite

```bash
# In scripts/appwrite/
npm install
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
APPWRITE_PROJECT_ID=your-project-id-here \
APPWRITE_API_KEY=your-server-key \
node appwrite-setup.mjs
```

This creates 5 collections in your Appwrite project (`user_progress`,
`user_achievements`, `user_favorites`, `user_subscriptions`, `user_settings`).
Re-runnable; safe.

Then enable Email/Password auth in Appwrite Console → Auth → Settings.

### 5. Wire the env vars

You can pass them at build time so you don't bake secrets into the binary:

```bash
flutter run \
  --dart-define=PB_URL=https://pocketbase.scaleupcrm.com \
  --dart-define=APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=your-project-id
```

Or set them once in your shell:

```bash
export PB_URL=https://pocketbase.scaleupcrm.com
export APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
export APPWRITE_PROJECT_ID=your-project-id
```

(See `lib/config.dart` for the defaults.)

### 6. Run it

```bash
flutter pub get
flutter run
```

Pick a device. The app boots, the home screen loads the daily lesson + quote
from PB, and the profile screen shows a banner to sign in (via Appwrite).

## Build for distribution

```bash
# Android (AAB for Play Store)
flutter build appbundle --release \
  --dart-define=PB_URL=... \
  --dart-define=APPWRITE_ENDPOINT=... \
  --dart-define=APPWRITE_PROJECT_ID=...

# iOS (IPA for App Store)
flutter build ipa --release \
  --dart-define=... \
  ...

# Web (PWA)
flutter build web --release \
  --dart-define=... \
  ...
```

## What's left to wire (post-MVP)

- **RevenueCat** for in-app purchases on iOS / Android. The Flutter app has
  a single integration point: `startMockSubscription` in
  `lib/services/appwrite_service.dart`. Replace its body with a call to your
  backend, which validates the receipt with RevenueCat and writes the
  `user_subscriptions` row.
- **Stripe** for web. Same shape: a checkout page on your domain, webhook
  hits your backend, backend writes the Appwrite row.
- **flutter_local_notifications** + FCM for the daily reminder (the slot is
  already reserved in `SettingsScreen`).
- **Offline reading** — cache the lessons list in `shared_preferences` (or
  drift) and serve from cache when offline.

## Repo map

```
riseup_app/
├── pubspec.yaml
├── analysis_options.yaml
├── assets/
└── lib/
    ├── main.dart
    ├── config.dart                 build-time env vars
    ├── theme/                      colors + text styles + ThemeData
    ├── models/                     Author, Work, Category, Quote, Lesson, Achievement, Plan, UserState
    ├── services/
    │   ├── pocketbase_service.dart   static content
    │   ├── appwrite_service.dart     user data (auth, progress, favorites, subs, settings)
    │   └── daily_pick.dart           deterministic "lesson of the day" index
    ├── providers/                  Riverpod (PB content + Appwrite auth)
    ├── router/                     go_router
    ├── screens/                    one per top-level destination
    ├── widgets/                    shared cards, pills, badges, shell
    └── utils/
        └── markdown_renderer.dart  styled MarkdownBody for lesson bodies
```

## How the seed got there

PB has:
- 6 authors · 10 works · 8 categories
- 53 quotes (~15 marked `is_pro`)
- 15 lessons (orders 1-4 free, 5-15 `is_pro`)
- 12 achievements (4 of the high-end ones `is_pro`)
- 4 plans (free, pro_monthly, pro_yearly, pro_lifetime)

Re-seed any time:

```bash
# (from /workspace/riseup)
node scripts/seed.mjs
node scripts/mark-pro.mjs
```

Both are idempotent.

## Why this split

- **PB is great for static content** — fast reads, simple admin UI, zero auth, your
  content team can edit records directly.
- **Appwrite is great for user data** — first-class auth, real-time,
  document-level security, serverless functions for Stripe / RevenueCat webhooks.
- One Flutter codebase, two backends, one mental model.

If you ever want to consolidate later, the seam is `pocketBaseProvider` /
`appwriteProvider` in `lib/providers/app_providers.dart` — swap them, no other
file changes.
