# RiseUP — Sign-up Flow Review + Fix

> The current sign-up flow is the bare minimum. It works but it does NOT
> meet App Store / GDPR / general user-trust baseline. This is the spec for
> what's needed.

Last reviewed: 2026-07-02

---

## TL;DR

**Have been fixed?** No.

The flow ships in v0.1 but it doesn't have:
- Terms / Privacy checkbox
- Password strength indicator
- Forgot password
- Post-signup welcome
- Apple Sign In (App Store strongly recommended)
- Email verification

This sprint ships: terms + privacy, password strength, forgot password, welcome screen.

Next sprint: Apple Sign In (iOS-only, requires Apple Developer setup).

Future: Google sign in, magic-link / OTP, email verification.

---

## Current flow

```
Home (anonymous)
  └─→ Tap "Profile"
       └─→ Tap "Sign in"
            ├─→ Sign-in screen
            │    ├─ Email + password
            │    ├─ "Sign in" button (creates account if new email)
            │    ├─ Toggle to "Create account" → + name field
            │    └─ "Continue without signing in"
            └─→ Returns to Profile
```

Issues:
- Bare form, no explanation of what signing up gives you
- "Continue without signing in" — anonymous users have no progress, no favorites, no journal
- No terms acceptance (legally required in EU, increasingly elsewhere)
- No password hint (typing a 1-char password silently fails on server, or worse, succeeds)
- No way to recover a forgotten password
- After sign-in, the user is dropped back to Profile with no acknowledgement

---

## Target flow (v1 launch)

```
Home (anonymous)
  └─→ Tap "Profile"
       └─→ Tap "Sign in or create account"
            └─→ Sign-in screen
                 ├─ Email + password
                 ├─ Toggle to "Create account" → + display name
                 ├─ Password strength meter (sign-up only)
                 ├─ Forgot password? link
                 ├─ [Apple] [Google] sign-in (v1.1+)
                 ├─ ☐ I agree to Terms + Privacy (sign-up only)
                 ├─ ☐ Send me product updates (sign-up only, opt-in)
                 └─ "Continue" button
                      └─ On sign-up → Welcome screen (one-shot)
                           ├─ "Welcome, {name}."
                           ├─ "Today's lesson is ready."
                           └─ [Begin] → Home (with today's lesson highlighted)
                      └─ On sign-in → Profile (silent)
```

---

## Screen-by-screen

### Sign-in screen (`/auth/signin`)

#### Email field
- Auto-detect email format (use case-insensitive match, trim whitespace).
- Show "Looks good" hint after first keystroke is valid.
- Show "Hmm, that doesn't look like an email" after invalid.

#### Password field
- Eye-toggle to show/hide password.
- On sign-up: live password strength meter (weak / OK / strong).
- On sign-in: just the field, no meter.

#### Display name field (sign-up only)
- Optional. Defaults to email prefix (`alice@…` → "Alice").
- Min 2 chars, max 30.

#### Forgot password link
- Tap → modal "Reset password":
  - "We'll send a recovery link to {email}."
  - Field is pre-filled with the entered email (or empty).
  - "Send link" → calls `appwrite.account.createRecovery(email, url)`.
  - "Check your inbox." success state.
  - Note: Appwrite sends an email with a recovery link. The URL must point to a hosted page that calls `appwrite.account.updateRecovery(...)`. For v1, point to `https://riseup.app/recover` (a static PB-served HTML page that does the recovery form).

#### Terms + Privacy checkbox (sign-up only)
- Pre-check is illegal in EU — must be unchecked by default.
- Tap the label to open the privacy policy in a WebView (for now: in-app browser sheet).
- If unchecked and user taps Continue, button is disabled (not error).

#### Marketing consent (sign-up only)
- Pre-checked is illegal. Default OFF.
- Stored as `marketingOptIn: bool` in `user_settings` (PB field).

#### Apple / Google sign-in (v1.1+)
- Apple: required if you offer any other social login on iOS (per App Store guideline 4.8).
- Google: optional but expected on Android.
- Both via Firebase Auth + Appwrite's "createOAuth2Session".

#### "Continue" button states
| State | Label | Disabled |
|-------|-------|----------|
| Empty form | "Continue" | ✅ |
| Sign-up, terms unchecked | "Continue" | ✅ |
| Sign-up, weak password, terms checked | "Choose a stronger password" | ✅ |
| All valid | "Continue" | ❌ |
| Submitting | "…" + spinner | ✅ |

### Welcome screen (`/auth/welcome`) — one-shot

Shown only the first time the user signs up (not on sign-in of existing accounts). Removed from back stack.

```
┌──────────────────────────────────────┐
│                                      │
│   Welcome, {name}.                   │
│                                      │
│   Your first lesson is ready.        │
│                                      │
│   Each morning, take 5 minutes       │
│   with a Stoic. Carry the quote      │
│   through the day.                   │
│                                      │
│   ────────────────────────           │
│                                      │
│   Today's lesson                     │
│                                      │
│   [lesson card preview]              │
│                                      │
│   [    Begin    ]                    │
│                                      │
└──────────────────────────────────────┘
```

Implementation:
- `user_settings.onboardingCompletedAt` field added.
- Router redirects `/auth/welcome` if `onboardingCompletedAt` is null.
- "Begin" sets `onboardingCompletedAt = now` + pushes to home with `?highlight=today-lesson`.

### Highlight on first launch

After tapping Begin on Welcome, home screen briefly highlights the "Today's lesson" card:

```dart
// home_screen.dart
class _HighlightedTodayCard extends StatefulWidget { ... }

// Wraps the today's lesson card with a soft pulsing border for 8 seconds.
// Dismisses on tap, on any scroll, or after the timer.
// Only fires when ?highlight=today-lesson is in the URI.
```

This is the nudge we talked about in UX-AUDIT.

---

## Field changes

### PB / Appwrite

`user_settings`:
- `marketingOptIn: bool` (optional, default false)
- `onboardingCompletedAt: datetime` (optional)
- `displayName: string` (optional, override email prefix)

### user_progress

- Add `signupMethod: string` (enum: 'email', 'apple', 'google', 'anonymous') for analytics.

---

## Error copy

Replace raw `state.error` displays:

| Raw error | Friendly copy |
|-----------|---------------|
| `user_invalid_credentials` | "That email and password don't match. Try again, or tap 'Forgot password?'" |
| `user_already_exists` | "An account with that email already exists. Sign in instead?" |
| `password_recently_used` | "Pick a password you haven't used here before." |
| `password_too_short` | "Passwords need at least 8 characters." |
| `email_invalid` | "That doesn't look like an email. Check the spelling." |
| `general_rate_limit` | "Too many tries. Take a breath, try again in a minute." |
| `network` | "No connection. Check Wi-Fi or mobile data, then retry." |
| `unknown` | "Something went sideways. We're looking into it." |

Implementation: a `formatAuthError(Object e)` function in `lib/utils/errors.dart`.

---

## Acceptance criteria

A new user should be able to:
1. Tap "Sign in" from Profile.
2. Enter email + password + name.
3. See password strength meter respond in real-time.
4. Check Terms + Privacy.
5. Tap Continue.
6. See a Welcome screen.
7. Tap Begin.
8. Land on Home with today's lesson highlighted.
9. Tap it, read it, mark complete.
10. Tap Profile, see their name + level 1 + 1 lesson completed.

A returning user should be able to:
1. Tap "Sign in".
2. Enter email + password.
3. Tap Continue.
4. Land on Profile silently (no welcome screen).
5. See their progress preserved.

A user who forgot their password should be able to:
1. Tap "Forgot password?" on sign-in screen.
2. Enter email.
3. Tap "Send link".
4. See "Check your inbox." success state.
5. Open email on phone.
6. Tap recovery link.
7. Set new password.
8. Return to app, sign in.

---

## Open questions

1. **Email provider.** Appwrite needs an SMTP server configured to send the recovery email. Options:
   - SendGrid (free tier 100/day, then $15/mo)
   - Mailgun (free tier 100/day, then $35/mo)
   - AWS SES ($0.10 per 1000)
   - Resend (free tier 100/day, then $20/mo)
   Recommend Resend or SES — cheapest at scale.

2. **Recovery landing page.** The recovery link in the email points to a URL we control. Options:
   - `https://riseup.app/recover` — static HTML page hosted on Cloudflare Pages (PB static files work too)
   - Deep link `riseup://recover?…` — opens the app directly (better UX, needs Universal Links / App Links)

   For v1, the static page is simpler. Deep links later.

3. **Apple Sign In setup.** Requires:
   - Apple Developer account ($99/yr) — assumed user has
   - App ID with Sign In capability
   - Service ID for "Sign in with Apple" → Appwrite
   - Firebase Auth configured with Apple provider
   - iOS-only — Android needs Google

4. **Email verification.** Appwrite supports it but it's friction. Trade-off:
   - Skip verification → easier sign-up, more spam accounts
   - Require verification → less spam, ~10% drop-off
   Recommend: skip for now, add rate-limiting + email-blacklist instead.

5. **Marketing consent vs. transactional email.** Make sure these are separate:
   - Transactional: password recovery, payment receipts — no consent needed
   - Marketing: weekly digest, new-lesson announcements — requires consent
   - System: app updates, ToS changes — soft consent (user is told at sign-up)

---

## Implementation order

### This sprint

1. ✅ Constants (`app_constants.dart`) with `privacyUrl`, `termsUrl`, `supportEmail`
2. ✅ `lib/utils/errors.dart` — `formatAuthError()`
3. ✅ Sign-in screen rewrite: terms + privacy checkbox, password strength meter, forgot-password modal
4. ✅ Welcome screen (`/auth/welcome`)
5. ✅ Home highlight on first launch
6. ✅ PB field additions (`marketingOptIn`, `onboardingCompletedAt`, `displayName`)
7. ✅ Router: redirect to Welcome on first sign-up; back-stack cleanup

### Next sprint

- Apple Sign In (requires Firebase Auth setup)
- Google Sign In (requires Firebase Auth setup)
- Magic-link / OTP

### Future

- Email verification (if spam becomes a problem)
- Hosted recovery page at `https://riseup.app/recover`