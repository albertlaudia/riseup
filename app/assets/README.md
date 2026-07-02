# RiseUP — assets

## Folders

- `icons/`     — app icon (1024x1024 source for iOS / Play Store)
- `splash/`    — splash screen image (1242x2688 for iOS, drawable for Android)
- `onboarding/` — three onboarding illustrations (800x600)

## Format

PNG, transparent or solid background. The current files are
**placeholder solid-color blocks** — designed properly by a designer
before public launch.

## How the splash + icon get applied

- **Android**: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
  adaptive icon (uses paper background + accent foreground vector).
  The legacy `mipmap-{mdpi,hdpi,...}/ic_launcher.png` are solid-color
  placeholders so pre-Android-8 builds succeed.
- **iOS**: assets are in `ios/Runner/Assets.xcassets/`. The
  `Contents.json` references them. On `flutter create .` regeneration,
  replace with designed assets.

## Onboarding illustrations

Loaded by `OnboardingScreen` from these paths. The 3 cards map to:
- `01.png` — "Five minutes each morning"
- `02.png` — "A quote for the day"
- `03.png` — "A streak that doesn't need motivation"

Use a warm minimal style — paper background, ink line drawings.