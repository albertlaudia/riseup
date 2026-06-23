#!/bin/bash
# RiseUP Flutter app — first-time setup.
# Run from the riseup_app/ directory.
#
# What it does:
#   1. flutter create .            — generates android/, ios/, web/ shells
#   2. flutter pub get            — install dart deps
#   3. flutter pub run build_runner build — if you add code-gen later
#
# Pre-requisites: Flutter 3.22+ on PATH. See https://docs.flutter.dev/get-started/install.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "▶ flutter --version"
flutter --version

echo ""
echo "▶ flutter create (android, ios, web)"
flutter create \
  --project-name riseup \
  --org com.albertlaudia \
  --platforms=android,ios,web \
  --description "RiseUP — a daily Stoic practice app." \
  .

echo ""
echo "▶ flutter pub get"
flutter pub get

echo ""
echo "▶ Sanity check: flutter analyze (lib/)"
flutter analyze --no-fatal-infos lib/ || echo "  (analyze reported issues — see above)"

cat <<'NEXT'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Setup complete.

Next steps:

  1. Create an Appwrite project at https://cloud.appwrite.io
     - Get project ID + create an API key with the right scopes
     - Enable Email/Password auth

  2. Create the Appwrite collections:
     $ cd ../riseup/scripts/appwrite
     $ npm install
     $ APPWRITE_ENDPOINT=... APPWRITE_PROJECT_ID=... APPWRITE_API_KEY=... \
         node appwrite-setup.mjs

  3. Run the app:
     $ flutter run \
         --dart-define=APPWRITE_PROJECT_ID=your-project-id

For more, see README.md.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEXT
