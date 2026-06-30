# RiseUP — server-push notification cron

> **Status:** scaffold. Currently the Flutter app schedules the daily
> reminder locally (`flutter_local_notifications`). This server is for v2
> when we want server-pushed notifications (better time-zone handling,
> richer copy, multi-device sync).

## What this does

A Cloudflare Worker that runs on a **cron trigger** (every 15 minutes is
fine). On each run it:

1. Queries the Appwrite database for users with
   - `notifications = true`
   - `fcmToken` not null
   - `dailyReminderTime` within ±10 minutes of now (in the user's IANA tz)
2. Determines **today's lesson + quote** using the same deterministic
   algorithm the Flutter app uses (`seed = 2024-01-01`, `index = day % items`).
3. Sends one FCM v1 push per user.

## Why a server?

Local scheduling (`flutter_local_notifications`) is great for v1:
- Zero server cost
- Works offline
- The reminder fires even with no network

But it has gaps:
- If the user changes time zones, the schedule is stale until they open the app
- A copy change requires an app store release
- Multi-device: iPhone gets a reminder but Android tablet (same user) doesn't

The server cron solves all three. Implementation timeline: **Year 2, after the local-only version is in users' hands**.

## How to deploy when ready

```bash
# 1. Get service account JSON from Google Cloud Console
#    (project → IAM → Service Accounts → create → Firebase Admin SDK)
gcloud iam service-accounts keys create riseup-fcm.json \
  --iam-account riseup-fcm@your-project.iam.gserviceaccount.com

# 2. Copy the JSON to ./service-account.json (gitignored) and:
echo "service-account.json" >> .gitignore

# 3. Deploy the worker
npm install -g wrangler
wrangler publish
```

Configure the cron trigger in `wrangler.toml`:

```toml
[triggers]
crons = ["*/15 * * * *"]   # every 15 minutes
```

Set the secrets:

```bash
wrangler secret put APPWRITE_ENDPOINT
wrangler secret put APPWRITE_PROJECT_ID
wrangler secret put APPWRITE_API_KEY
wrangler secret put FCM_PROJECT_ID
# The service-account.json content:
wrangler secret put FCM_SERVICE_ACCOUNT_JSON
```

## Files

- `src/index.ts` — the worker
- `wrangler.toml` — config
- `package.json` — deps (just `firebase-admin`)
- `.gitignore` — keep `service-account.json` out of git

## Testing locally

```bash
wrangler dev --test-scheduled
```

This lets you fire the cron trigger manually with a debug event.

## After it's deployed

Replace the local notification scheduling in
`app/lib/services/reminder_scheduler.dart` with a no-op (the server does
the work), or keep both as a safety net.

To re-engage the client for handling taps on server-pushed notifications,
add `firebase_messaging` to the Flutter app's `pubspec.yaml` and wire the
`onMessage` handler to call `NotificationService.instance.emitTap(...)`.
