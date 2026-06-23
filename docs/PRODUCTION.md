# Production release checklist

Everything you need before pushing to Play Store / App Store / production web.
Updated as of June 2026.

## ✅ Already done

- [x] **Repo on GitHub** — public, `albertlaudia/riseup`
- [x] **License** — MIT
- [x] **Root README + docs** — `README.md`, `docs/ARCHITECTURE.md`, `docs/PRODUCTION.md`
- [x] **CI** — `.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` + `web build` on every push
- [x] **Static content** — 6 authors, 10 works, 8 themes, 53 quotes, 15 lessons, 12 achievements, 4 plans seeded in PB
- [x] **Subscription schema** — `rup_plans` static catalog + Appwrite `user_subscriptions` for per-user state
- [x] **Paywall** — fully wired, mock checkout working (replace `startMockSubscription` for real money)
- [x] **Web deployment** — Next.js static export deploys to any CDN; live URL configured
- [x] **App icon** — generated (192/512 + adaptive layers)
- [x] **PWA manifest** — for TWA fallback
- [x] **Branding** — warm-paper / ink / accent palette consistent across web + app

## 🔲 Before Play Store (Android)

| What | Owner | Notes |
|---|---|---|
| **Google Play Developer account** | you | $25 one-time, ID verification (days/weeks) |
| **App Bundle signing key** | you | `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` |
| **AAB upload to Play Console** | you | `flutter build appbundle --release` |
| **App listing** | you | Title, short description, long description, icon, feature graphic, screenshots |
| **Screenshots** | you | 1080×1920 minimum, 4-8 per device class (phone, 7" tablet, 10" tablet) |
| **Content rating** | you | IARC questionnaire — "Education" or "Health & Fitness" depending on angle |
| **Data safety form** | you | PB is read-only, no PII collected. Appwrite: email + auth, optional daily reminder opt-in |
| **App access** | you | If account-only, provide a test login for reviewers |
| **Target API level** | you | 34+ (Android 14). Flutter default is fine. |
| **Privacy policy URL** | you | Host on the same domain as the app. Plain HTML page. |
| **Internal testing track** | you | First upload → internal testers → fix → closed beta → production |

### Fast Play Store path

```bash
# 1. Generate signing key (one time)
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# 2. Set up key.properties with the passwords
# 3. Build the AAB
flutter build appbundle --release \
  --dart-define=PB_URL=https://pocketbase.scaleupcrm.com \
  --dart-define=APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=...
# 4. Upload to Play Console → Internal testing
```

## 🔲 Before App Store (iOS)

| What | Owner | Notes |
|---|---|---|
| **Apple Developer account** | you | $99/yr |
| **App ID + provisioning profile** | you | in Apple Developer portal |
| **Xcode archive → IPA** | you | `flutter build ipa --release` |
| **App Store Connect listing** | you | Same fields as Play Store plus a privacy "nutrition label" |
| **Screenshots** | you | 6.7" (iPhone 15 Pro Max), 6.5" (iPhone 11 Pro Max), 5.5" (iPhone 8 Plus), iPad |
| **TestFlight internal** | you | Required before App Review |
| **App Review submission** | you | Apple reviews in 24-48h typically |
| **Privacy policy URL** | you | Same as Android |

## 🔲 Backend / infra

| What | Where | Status |
|---|---|---|
| **PocketBase production instance** | you | Currently on Dokploy — fine for now; for scale, move to managed PB Cloud or your own VPS |
| **Appwrite production project** | you | Create at cloud.appwrite.io (free tier has limits, $15/mo gets you 75K MAUs) |
| **Daily backup** | you | PB has a built-in backup cron — set it. Appwrite has DB backups via API. |
| **Custom domain** | you | Point a domain at your CDN for the web app. CNAME works. |
| **HTTPS everywhere** | you | Cloudflare handles this for free. |
| **Email auth rate limits** | Appwrite | Default is fine for MVP. Watch for abuse. |
| **CORS / auth origins** | Appwrite | Add your web + app domains to the allowed list. |

## 🔲 Real payments (replace `startMockSubscription`)

```dart
// lib/services/appwrite_service.dart
Future<void> startMockSubscription(String userId, String planCode, ...) async {
  // 1. Call your backend (e.g. POST /api/checkout)
  // 2. Backend creates Stripe checkout session → returns URL
  // 3. Client opens URL in webview / browser
  // 4. User pays → Stripe webhook hits your backend
  // 5. Backend creates user_subscriptions row (via server SDK with API key)
}
```

| What | Where |
|---|---|
| **Stripe account** | you — https://dashboard.stripe.com |
| **Stripe products + prices** | match `rup_plans` codes: `pro_monthly`, `pro_yearly`, `pro_lifetime` |
| **Stripe webhook** | your backend → on `checkout.session.completed` → write Appwrite row |
| **RevenueCat account** | you — handles App Store + Play Store receipts. Single SDK for iOS + Android. |
| **App Store Server Notifications** | you → RevenueCat → your backend → Appwrite |
| **Play Store Real-time Developer Notifications** | you → RevenueCat → your backend → Appwrite |

## 🔲 Engagement features (in priority order)

The app already has the core loop working. Below are the additions that will
move "users who try it" to "users who come back every day".

| Priority | Feature | Status | What it adds |
|---|---|---|---|
| 🔴 P0 | **Daily reminder notification** | Slot reserved | Wake users up at their preferred time with "Today's lesson is live" |
| 🔴 P0 | **Streak freeze** | needs build | 1 free freeze/month prevents harsh streak loss after a missed day |
| 🟠 P1 | **Onboarding flow** | needs build | 3 screens explaining the practice + the streak + the value |
| 🟠 P1 | **Reflection prompt after each lesson** | needs build | "What will you try today?" → 1-line journal entry, stored in Appwrite |
| 🟠 P1 | **Quick practice mode** | needs build | 60-second scroll of curated wisdom for busy days |
| 🟡 P2 | **Re-engagement banner** | needs build | "You've been away 2 days. Here's your spot." |
| 🟡 P2 | **Achievement celebration animation** | needs build | Confetti / haptic when an achievement unlocks |
| 🟢 P3 | **Share quote as image** | needs build | "Share" button on every quote card → image generation |
| 🟢 P3 | **Lock screen widget** | needs build | Quote of the day on the home screen (Android: AppWidget; iOS: WidgetKit) |
| 🟢 P3 | **Audio narration (TTS)** | possible with MiniMax TTS | "Listen to today's lesson" — 5 min audio per lesson |
| 🟢 P3 | **Streak sharing** | needs build | "Share my 30-day streak" → image card |
| ⚪ P4 | **Wear OS / WatchOS** | future | Quick glance: today\'s quote |
| ⚪ P4 | **Accountability partner** | future | Share streak with a friend (opt-in) |
| ⚪ P4 | **Weekly digest** | future | "This week: 4 lessons, 3 quotes" email on Sunday |
| ⚪ P4 | **On-this-day** | future | "1 year ago today you read X" |

### Daily reminder — full spec

1. `flutter_local_notifications` for local delivery (works offline)
2. **Server push** via FCM for time-zone-aware delivery (user can change time zones while traveling)
3. Notification body varies: "Today\'s lesson is *" + lessonTitle + "*"  with a deep link
4. Quiet hours (default 22:00 - 07:00) — respect
5. A/B test the time of day (morning vs evening) — but later

### Onboarding — spec

- 3 cards, swipeable, "Skip" button always visible
- Card 1: "The practice" — what a daily lesson is, why it works
- Card 2: "The streak" — visual of a 7-day streak, "1 day missed = streak intact if you have a freeze"
- Card 3: "Your settings" — when to be reminded, sign in (or skip)
- Persisted via `shared_preferences` (just a `bool hasOnboarded`)
- Gate: shown on first launch only

### Reflection prompt — spec

- After completing a lesson, bottom sheet appears: "What will you try today?"
- One text field, max 280 chars
- Save to Appwrite `rup_journal` (new collection — see schema below)
- Empty reply = dismiss
- Show the user's last 7 entries on the profile screen (so the practice feels cumulative)

### Quick practice — spec

- A new mode accessible from the home screen: a 60-second scroll of 5-7 small wisdom cards
- Each card: a quote + a 1-line action
- No login required
- "Continue with a full lesson" CTA at the end

## 🔲 Schema additions for engagement (Appwrite)

Add these collections via `pb/scripts/appwrite/appwrite-setup.mjs` (or directly in Appwrite):

```
rup_journal
  userId         string (indexed, unique per user+date)
  date           string "YYYY-MM-DD" (indexed)
  lessonSlug     string
  promptText     string
  responseText   string (≤ 280 chars)
  createdAt      datetime

rup_streak_freezes
  userId         string (indexed, unique)
  freezesUsed    int
  freezesResetAt date      (next month)
```

Or merge `rup_streak_freezes` into `rup_settings` (freezes used + reset date).

## 🔲 Analytics

Decide between:

| Tool | Cost | Privacy | Notes |
|---|---|---|---|
| **Plausible** | $9/mo | Cookie-less, GDPR-friendly | Good default for an ethical product |
| **PostHog** | Free up to 1M events/mo | Self-host option | More product analytics, funnels |
| **Amplitude** | Free up to 10M events/mo | Good | Heavier, more SaaS-y |
| **None** | $0 | Best | Just watch your PB logs |

For a stoic app, **less tracking is on-brand**. Start with Plausible for the web, none for mobile. If you need funnels later, add PostHog self-hosted.

## 🔲 Legal

- [ ] **Privacy policy** — host on your domain, link from app listings
- [ ] **Terms of service** — same
- [ ] **Data processing agreement** — only if you handle EU users
- [ ] **GDPR / CCPA disclosure** — your privacy policy covers this

The quotes (Stoic text) are public domain. The lesson prose is your own original work. Author bios are factual. The app doesn't collect any PII beyond what Appwrite Auth needs to function.

## 🔲 Pre-launch sanity checks

- [ ] Sign up → sign in → see profile
- [ ] Complete a lesson → see XP go up
- [ ] Cancel a "subscription" (mock) → see tier flip back to free
- [ ] Lock a pro lesson for a free user → see locked overlay
- [ ] Read on flaky network → app doesn't crash (cached content)
- [ ] Read offline → app shows last-seen content
- [ ] Reset password flow works
- [ ] All deep links open the right screen
- [ ] All "Open in browser" links work
- [ ] Time zone changes don't break the daily lesson
- [ ] Daylight Saving Time doesn't break the daily reminder
- [ ] Streak survives 23h59m between sessions (intentional grace)
- [ ] Streak breaks correctly after 25h with no activity

## TL;DR

1. Get the Play Developer account + App Developer account started (background)
2. Build the AAB / IPA, sign, upload to internal testing
3. Replace `startMockSubscription` with a real Stripe / RevenueCat integration
4. Build the 4 P0/P1 engagement features (onboarding, reflection, quick practice, daily reminder)
5. Submit to App Review + Play Review
6. Ship.
