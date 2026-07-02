# RiseUP — Flutter app

The mobile client. Lives inside the [riseup monorepo](../). Reads static
content from PocketBase; reads/writes user data via Appwrite.

## Stack

- Flutter 3.22+ / Dart 3.4+
- Riverpod for state
- go_router for navigation
- PocketBase (lessons, quotes, plans, achievements)
- Appwrite (auth, progress, favorites, journal, subscriptions, settings)
- flutter_local_notifications (daily reminder; FCM-ready for server push)

## First-time setup

```bash
bash scripts/setup.sh
```

This generates platform glue (`ios/Runner.xcodeproj`, Android gradle wrapper),
copies local config templates, runs `flutter pub get`, generates launcher
icons and splash screens, and runs `flutter analyze`.

## Build

```bash
flutter run                                              # connected device
flutter run -d "iPhone 15"                               # iOS simulator
flutter build apk --release                              # Android
flutter build ios --release --no-codesign                # iOS (unsigned IPA)
```

## Project layout

```
app/
├── lib/
│   ├── main.dart                   # entry, app boot, theme provider
│   ├── config/                     # AppConstants (single source of truth)
│   ├── models/                     # Lesson, Quote, Author, Plan, Achievement, UserState
│   ├── providers/                  # Riverpod state — auth, content, favorites, journal
│   ├── router/                     # go_router config
│   ├── screens/                    # 14 screens (home, library, lesson, quotes, profile, …)
│   ├── services/                   # PocketBase + Appwrite + Notifications
│   ├── theme/                      # Walrus paper / Ink / Accent design tokens
│   ├── utils/                      # formatAuthError, passwordStrength
│   └── widgets/                    # reusable UI — LessonCard, EmptyState, Confetti, …
├── android/                        # Android platform glue (gradle, Kotlin, manifest, icons)
├── ios/                            # iOS platform glue (Info.plist, AppDelegate, Podfile)
├── assets/                         # icons, splash, onboarding illustrations
├── scripts/setup.sh                # one-shot bootstrap
└── pubspec.yaml                    # deps + flutter_native_splash + flutter_launcher_icons
```

## Configuration

Build-time configuration via `--dart-define`:

| Var | Default | What |
|-----|---------|------|
| `APPWRITE_PROJECT_ID` | empty | Appwrite project (set this!) |
| `APPWRITE_ENDPOINT` | `https://cloud.appwrite.io/v1` | Appwrite API endpoint |
| `POCKETBASE_URL` | `https://pocketbase.scaleupcrm.com` | Static content server |

These can also live in `android/local.properties` (Android) or be set in
Xcode scheme env vars (iOS).

## Key flows

| Flow | Entry point | Docs |
|------|-------------|------|
| Sign up | `SigninScreen` | `docs/SIGNUP-FLOW.md` |
| Daily reminder | `NotificationService` + `ReminderScheduler` | `docs/PRODUCTION.md` |
| Mark lesson complete | `LessonDetailScreen._markComplete` | `lib/screens/lesson_detail_screen.dart` |
| Achievement auto-unlock | `UnlockedAchievementsNotifier.evaluateAndUnlock` | `lib/providers/favorites_provider.dart` |
| Streak bump | `UserNotifier.markLessonToday` | `lib/providers/auth_providers.dart` |

## Testing

```bash
flutter test                       # unit + widget tests
flutter analyze                    # static analysis
```

(Currently 0 tests written — sprint-1 task. Spec at `docs/GAP-AUDIT.md`.)

## Documentation

Comprehensive planning + audit docs in `../docs/`:

- `ARCHITECTURE.md` — overall system architecture
- `PRODUCTION.md` — production deployment playbook
- `BUSINESS-PLAN.md` — pricing, unit economics, launch sequence
- `UX-AUDIT.md` — UX review, what feels robotic, what's missing
- `HARDCODES.md` — every literal that should become configuration
- `CACHE-AND-DOWNLOADS.md` — offline + audio + smart download spec
- `SIGNUP-FLOW.md` — current vs target sign-up, Apple/Google auth
- `GAP-AUDIT.md` — what works, what's broken, what's deferred
- `TASKS.md` — master task list

## License

This app is part of the RiseUP monorepo. See top-level `LICENSE`.