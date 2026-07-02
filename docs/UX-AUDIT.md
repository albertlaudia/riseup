# RiseUP — UX Audit

> Reviewing the app the way a careful user would, and the way a Stoic would.
> Goal: nothing should feel like a system prompt. Every interaction should feel
> like a thoughtful human hand.

Last reviewed: 2026-07-02

---

## TL;DR — what needs to change

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Demo profile hardcodes (`xp: 240`, `level: 3`, etc.) | 🟠 | ✅ Fixed |
| 2 | Raw error strings surfaced to user (`Sign-in failed: ${state.error}`) | 🟠 | ✅ Fixed |
| 3 | No empty states (favorites, journal, completed lessons) | 🟠 | ✅ Fixed |
| 4 | No skeleton loaders (CircularProgressIndicator everywhere) | 🟠 | ✅ Fixed |
| 5 | Sign-up missing: terms checkbox, password strength, welcome screen | 🟠 | ✅ Fixed |
| 6 | No haptics (interactions feel like buttons, not touchpoints) | 🟡 | ✅ Fixed |
| 7 | "Quotes read: 0" hardcoded | 🟡 | ✅ Fixed |
| 8 | Anonymous user gets an empty streak flame → reads as bug | 🟡 | ✅ Fixed |
| 9 | Returning-vs-first-time home copy not branching | 🟠 | ✅ Fixed |
| 10 | Splash screen is default white flash | 🟡 | ✅ Fixed |
| 11 | No system-info / debug screen | 🟡 | ✅ Fixed |
| 12 | Notifications: cold-start reschedule can race auth bootstrap | 🟢 | ⬜ Defer |
| 13 | Onboarding copy has no tie-back to first action (no "Open today's lesson") | 🟡 | ⬜ Defer |
| 14 | No first-rating prompt (after 7 days, after 5 lessons) | 🟡 | ⬜ Defer |
| 15 | No feedback widget | 🟡 | ⬜ Defer |
| 16 | Achievements "Unlocked as you practice" is static — should react on unlock | 🟠 | ⬜ Defer |
| 17 | Offline mode: app dies without network (no cache layer) | 🟠 | ⬜ Defer to offline sprint |
| 18 | No audio downloads / smart downloads | 🟠 | ⬜ Defer to audio sprint |

Severity legend: 🟠 user-visible, 🟡 nice-to-have, 🟢 edge case

---

## What makes the app feel like a system (not a human)

These are the specific patterns where the app reads as "made by a backend":

### 1. **Cold "system" error display**
`signin_screen.dart:46`:
```dart
SnackBar(content: Text('Sign-in failed: ${state.error}'))
```
A user signs up, types a bad password, sees:
> "Sign-in failed: AppwriteException[type: user_invalid_credentials]"

That's an HTTP status code in human clothing. **A Stoic app would say:**
> "That email and password don't match an account. Try again, or create one."

### 2. **Loading that doesn't load anything**
The home screen used to show a `CircularProgressIndicator` while PB fetched lessons. That's the universal symbol for "system working". Better: a **paper-textured skeleton** that looks like the lesson card already loaded but is just shimmering. The user sees the *shape* of what's coming.

### 3. **Demo data in production paths**
`profile_screen.dart`:
```dart
Text('Quotes read', value: '0', icon: '📜'),
```
The literal value `'0'` is hardcoded. **A user who has never read a quote** sees this. A user who has read 5 quotes also sees `0`. The system is lying.

### 4. **Anonymous streak that says "0 d"**
```dart
StreakFlame(days: user.streakCurrent)  // when anonymous, streakCurrent=0
```
The flame widget renders for an anonymous user with `days=0`. That looks like a bug. Either hide it for anonymous, or show a friendly "Sign in to start your streak" hint.

### 5. **Returning users treated identically to first-time users**
The home greeting doesn't check `lastVisit`. After the second open, "Today, again" should warm up:
- Day 2: "Back for day 2."
- Day 7: "A week in."
- Day 30: "You've shown up 30 times now."
- Returning after 3+ days: "Welcome back. Your streak is still at N."

### 6. **Onboarding ends and dumps you on home**
Three cards, "Begin", home screen. No "today's lesson is waiting" tie-back. User has to figure out what to do next. Should auto-route to today's lesson, or show a soft "Tap 'Today' above to begin" hint.

### 7. **Settings screen Save button** (fixed in last sprint)
Used to require Save. Now everything reschedules immediately — much more conversational.

---

## Empty-state catalog (the missing UI)

| Screen | When | What to show |
|---|---|---|
| Library → Favorites tab | 0 favorites | "Mark lessons with the bookmark to find them here." + button to today's lesson |
| Library → Journal tab | 0 entries | "Your reflections will appear here. End any lesson with one." |
| Home → Today's lesson | PB down | "Today's lesson hasn't arrived yet. Pull to refresh, or come back later." |
| Achievements | 0 unlocked | "No achievements yet. Finish a lesson to start collecting." |
| Search | no query | "Search lessons, quotes, or authors." |
| Profile → anonymous | no user | "Sign in to save your progress across devices." (with sign-in CTA) |

---

## Sign-up flow (have been fixed? — short answer: no)

### Current state
- Email + password fields
- Toggle to "Create account"
- "Continue without signing in" 
- ❌ No terms-of-service checkbox
- ❌ No privacy-policy checkbox
- ❌ No password strength indicator
- ❌ No "Forgot password" link
- ❌ No email verification
- ❌ No Apple/Google sign-in (Apple Sign In is **required by App Store** if you offer any other social login — and even if you don't, it's strongly recommended)
- ❌ No magic-link / OTP option
- ❌ No "Welcome!" screen after sign-up — user lands on home with no context
- ❌ No marketing-consent checkbox (GDPR / CCPA)

### Fix priority (this sprint)
1. ✅ Terms + Privacy checkbox on sign-up
2. ✅ Password strength meter on sign-up
3. ✅ Forgot-password flow (writes to `appwrite.recovery()`)
4. ✅ Post-signup Welcome screen ("Welcome, {name}. Your first lesson is ready.")
5. ⬜ Apple Sign In (iOS-only — needs entitlements + Firebase/Auth connector)
6. ⬜ Google Sign In (optional — bigger infra)
7. ⬜ Magic link (uses Appwrite's magic URL — but needs email provider)
8. ⬜ Email verification

---

## Tone audit — places where the app still feels mechanical

| Location | Current | Suggested |
|----------|---------|-----------|
| Home empty hero | "Rise above" (good) | keep |
| Home returning user | (nothing — same greeting) | "Back for day {n}." or "Welcome back." |
| Paywall headline | "Rise with us" | keep |
| Paywall bullet | "Unlimited lessons, journal, all personas" | keep, but lead with benefit not feature |
| Reflection sheet | "What stood out?" (good) | keep |
| Lesson complete | "Lesson complete · +10 XP" | "Saved. +10 XP." (less mechanical) |
| Error: no network | nothing (blank screen) | "No connection. Showing your last cached lesson." |
| Settings: notifications off | nothing | "Quiet for now. We'll be here." |
| Achievement unlock | (just unlocks) | Tiny confetti + "You earned {title}." |
| Onboarding skip | "Skip" | keep, but the skipped user gets a brief "You can revisit from Settings." on home |

---

## What about animations & haptics?

Animations should serve clarity, not flash. Recommendations:

| Where | Animation | Haptic |
|-------|-----------|--------|
| Toggle reminder | 150ms ease | `light` |
| Tap "Mark complete" | confetti + lesson slides up | `medium` |
| Achievement unlock | tiny gold pulse + slide-in | `heavy` |
| Quote swipe | 250ms ease | `selectionClick` |
| Tab change | cross-fade, not slide | `light` |
| Notification arrival | (system) | n/a |
| Pull to refresh | paper-textured spinner | `light` |

Use `HapticFeedback.lightImpact()` etc. Don't over-do it.

---

## What about the very first launch experience?

The current onboarding is **good**: 3 cards, swipe, skip, begin. But after "Begin" the user is dumped on Home with no nudge. Specific issue:

- The home screen shows "Today's lesson" hero card
- But the user might not know to **tap it**
- And the first time, "Today's lesson" is a long thing — they might feel overwhelmed

Fixes:
1. After onboarding, briefly highlight the "Today's lesson" card with a soft pulsing border + "Tap to begin" label that fades after first interaction
2. On first lesson completion, trigger a celebration moment (small confetti + "First lesson done — that's the hardest one.")
3. After 3 lessons, show "You're starting a habit" → unlock "First Habit" achievement
4. After 7 days, prompt rating (StoreKit / In-App Review API)

---

## What about accessibility?

Currently mostly overlooked:
- ❌ All text sizes hardcoded — should respond to system font scale
- ❌ No semantics labels on icon-only buttons
- ❌ No focus order testing for screen readers
- ❌ Color contrast — `#B9532E` accent on `#FAF6EF` background: 5.1:1 ✓ WCAG AA but AA Large for body text wants 4.5:1 ✓
- ❌ Tap targets: most are 44pt+ but the segmented time picker (6:00 / 7:00 / 8:00 / 21:00) is borderline

Fix priority: make font scaling work first, then audit the rest.

---

## What about i18n / l10n?

Currently 100% English hardcoded. The app is positioned for SEA (per BUSINESS-PLAN.md) but nothing is translated.

If v1 ships English-only:
- ✅ Acceptable for App Store launch
- ❌ Loses the SEA wedge

Plan: l10n via `flutter_localizations` + `.arb` files. Defer to post-launch. **For now**, design every user-facing string to be wrapped in a function that can be replaced with `S.of(context).string` later.

---

## Detailed review by screen

### Home (`home_screen.dart`)
- ✅ Daily pick deterministic algorithm
- ✅ Streak flame visible
- ✅ Quick practice carousel
- ❌ Same greeting for returning vs new
- ❌ No skeleton loader — `CircularProgressIndicator` flashes
- ❌ No offline banner

### Library (`library_screen.dart`)
- ❌ No empty state
- ❌ No search
- ❌ No sort/filter (newest / most-loved / by author)

### Lesson detail (`lesson_detail_screen.dart`)
- ✅ Markdown renderer
- ✅ Reflection sheet
- ❌ Catch block silently swallows errors
- ❌ No estimated read time shown

### Quotes (`quotes_screen.dart`)
- ❌ No share button
- ❌ No "save to favorites" per quote
- ❌ No audio button (placeholder for audio sprint)

### Profile (`profile_screen.dart`)
- ❌ Hardcoded "Quotes read: 0"
- ❌ No "Edit profile" flow
- ❌ No "Change password"
- ❌ No "Delete account" (required by App Store / GDPR)
- ❌ No "Export my data"

### Settings (`settings_screen.dart`)
- ✅ Reminder reschedule fixed last sprint
- ❌ No "Language" option
- ❌ No "Theme" actually does anything (auto/light/dark set but no theme switcher)
- ❌ No data-export option
- ❌ No data-clear option

### Paywall (`paywall_screen.dart`)
- ❌ Catch block silently swallows
- ❌ No "Restore purchases" button (REQUIRED by App Store)
- ❌ No "Cancel anytime" disclosure
- ❌ No trial period option

### Onboarding (`onboarding_screen.dart`)
- ✅ Cards in PB
- ❌ No tie-back to first action
- ❌ No first-rating prompt later

### Sign-in (`signin_screen.dart`)
- ❌ Terms + privacy checkbox missing
- ❌ Password strength missing
- ❌ Forgot password missing
- ❌ Post-signup welcome missing
- ❌ Apple/Google sign-in missing

### About (`about_screen.dart`)
- ✅ Good copy
- ❌ No version number shown
- ❌ No link to actual privacy / terms URLs (or just to PB-hosted docs)
- ❌ No acknowledgements

---

## What to ship in this sprint (high-impact, low-effort)

1. ✅ Pull hardcoded values into `lib/config/app_constants.dart`
2. ✅ Empty-state + Skeleton + Haptic widget library
3. ✅ Friendly error copy throughout
4. ✅ Remove demo profile hardcodes
5. ✅ Sign-up: terms + privacy + password strength + Forgot password + post-signup Welcome
6. ✅ Home screen branching copy (returning vs new)
7. ✅ Splash screen config
8. ✅ System Info screen (with version, env, sign out, etc.)

## What to defer (need dedicated sprints)

- Offline cache layer (drift + stale-while-revalidate)
- Audio downloads + smart download manager
- Crash reporting (Sentry)
- Analytics
- Apple / Google sign-in
- Magic-link / OTP
- Email verification
- i18n / l10n
- Tablet / landscape layouts
- Widget for home screen
- Achievements auto-unlock engine
- Rating prompt
- Feedback widget
- Confetti on achievement unlock