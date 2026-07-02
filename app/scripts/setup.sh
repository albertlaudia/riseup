#!/bin/bash
# RiseUP Flutter app — first-time setup.
#
# Run from the riseup/app/ directory after cloning:
#
#   bash scripts/setup.sh
#
# What it does:
#   1. Generates any missing Flutter platform glue (Xcode project, AndroidManifest extras)
#   2. Copies local.properties.template -> local.properties (Android)
#   3. Copies key.properties.template -> key.properties (Android signing — leave empty for debug builds)
#   4. Runs `flutter pub get`
#   5. Generates app icon + native splash for iOS + Android
#   6. Runs `flutter analyze` to surface obvious issues
#
# Pre-requisites:
#   - Flutter 3.22+ on PATH (https://docs.flutter.dev/get-started/install)
#   - Xcode 15+ (macOS only, for iOS builds)
#   - Android Studio + Android SDK 34 (for Android builds)

set -euo pipefail

cd "$(dirname "$0")/.."

echo ""
echo "┌────────────────────────────────────────────────────────────┐"
echo "│  RiseUP setup                                               │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ─── 1. Flutter version check ───
echo "▶ Checking Flutter version"
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not on PATH. Install from https://docs.flutter.dev/get-started/install"
  exit 1
fi
flutter --version | head -1

# ─── 2. Platform glue ───
echo ""
echo "▶ Generating missing platform glue (Xcode project, gradle wrapper, web/)"
flutter create \
  --project-name riseup \
  --org com.albertlaudia \
  --platforms=android,ios,web \
  --description "RiseUP — a daily Stoic practice app." \
  .

# ─── 3. local.properties ───
echo ""
echo "▶ Android local.properties"
if [ ! -f android/local.properties ]; then
  cp android/local.properties.template android/local.properties
  echo "  → Created android/local.properties. EDIT THIS FILE with your SDK paths."
  echo "    flutter.sdk = output of: which flutter | xargs readlink -f | sed 's|/bin/flutter||'"
  echo "    sdk.dir     = output of: echo \$ANDROID_HOME  (or \$ANDROID_SDK_ROOT)"
else
  echo "  → android/local.properties already exists, skipping."
fi

# ─── 4. key.properties ───
echo ""
echo "▶ Android signing config"
if [ ! -f android/app/key.properties ]; then
  cp android/app/key.properties.template android/app/key.properties
  echo "  → Created android/app/key.properties. Leave empty for debug builds."
  echo "    Fill in storeFile/keyAlias/storePassword/keyPassword before any release build."
else
  echo "  → android/app/key.properties already exists, skipping."
fi

# ─── 5. CocoaPods ───
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo ""
  echo "▶ CocoaPods (iOS only)"
  if command -v pod &> /dev/null; then
    (cd ios && pod install --silent) || echo "  (pod install had warnings — see above; OK to ignore)"
  else
    echo "  → pod not installed. Run: sudo gem install cocoapods"
  fi
fi

# ─── 6. flutter pub get ───
echo ""
echo "▶ flutter pub get"
flutter pub get

# ─── 7. Native icon + splash ───
echo ""
echo "▶ Generating native launcher icons + splash"
dart run flutter_launcher_icons || echo "  (flutter_launcher_icons warnings — OK to ignore)"
dart run flutter_native_splash:create || echo "  (flutter_native_splash warnings — OK to ignore)"

# ─── 8. Sanity check ───
echo ""
echo "▶ flutter analyze (lib/)"
flutter analyze --no-fatal-infos lib/ || echo "  (analyzer reported issues — see above)"

cat <<'NEXT'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Setup complete.

Try it:

  flutter run                                       # auto-detects connected device

Or run on a specific simulator:

  flutter run -d "iPhone 15"                        # iOS
  flutter run -d emulator-5554                      # Android emulator

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXT STEPS (see docs/PRODUCTION.md for the full playbook):

  1. Add real API keys to local.properties:
     APPWRITE_PROJECT_ID=...
     APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1

  2. Set up the Appwrite backend (idempotent — safe to re-run):
     $ cd ../pb/scripts/appwrite
     $ npm install
     $ APPWRITE_PROJECT_ID=... APPWRITE_API_KEY=... node appwrite-setup.mjs

  3. Sign up → land on Welcome screen → Begin → home

  4. Mark a lesson complete → streak +1 → reflection sheet appears

  5. Settings → toggle Daily reminder → wait for the chosen time

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEXT