# RiseUP — Appwrite setup

User data lives in Appwrite, not PocketBase. This script creates the database
and collections that hold everything per-user.

## One-time setup

1. **Create a project** at https://cloud.appwrite.io (or self-host)
2. **Get a server API key**:
   - Project → Settings → API Keys → Create
   - Scopes needed: `databases.write`, `collections.write`, `attributes.write`, `indexes.write`, `documents.write`, `users.read`
   - Copy the key + the project ID
3. **Run the setup:**
   ```bash
   npm install
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
   APPWRITE_PROJECT_ID=your-project-id \
   APPWRITE_API_KEY=your-server-key \
   node appwrite-setup.mjs
   ```

The script is **idempotent** — re-running won't break anything.

## What it creates

| Collection | Purpose | Key fields |
|---|---|---|
| `user_progress` | Lessons the user has completed | userId, lessonSlug, xpEarned, completedAt |
| `user_achievements` | Achievements unlocked | userId, achievementCode, unlockedAt |
| `user_favorites` | Saved quotes / lessons | userId, kind (quote\|lesson), targetId |
| `user_subscriptions` | Active / past subscriptions | userId, planCode, status, source, externalId, expiresAt |
| `user_settings` | Per-user preferences | userId (unique), theme, notifications, dailyReminderTime, fontSize, tier |

Plus indexes for fast lookups (`userId`, `userId+lessonSlug`, etc).

## Permissions model

Document-level security. When the Flutter app creates a row, it sets:
- `Permission.read(Role.user(<userId>))`
- `Permission.write(Role.user(<userId>))`
- `Permission.delete(Role.user(<userId>))`

This way each user only sees their own data. The collection-level permissions
stay empty — no anonymous read, no cross-user leakage.

## Subscription source-of-truth

The `user_subscriptions` collection holds all the records. The Flutter app
derives the user's current `tier` by:
1. Find subscriptions where `userId = me` and `status IN ('active', 'trial')`
2. If `expiresAt` is in the future (or null for lifetime), the user is **pro**
3. Otherwise, **free**

You can also write `tier` into `user_settings` as a denormalized cache for
fast UI checks, but the subscription table is the source of truth.

## How a checkout flow plugs in

Stripe web (web app), RevenueCat (iOS/Android), or both. On a successful
purchase:
1. Server verifies the receipt with the provider
2. Server creates a `user_subscriptions` row with the right `source` and `externalId`
3. Flutter app refreshes its subscription state and unlocks pro content

The Flutter app's paywall screen reads `user_subscriptions` to decide whether
to show the upsell or the "you're pro" message.

## Auth

Appwrite Auth is the source of truth for identity. The Flutter app uses
`account.create()`, `account.createEmailSession()`, and the JWT it returns
for all subsequent requests.
