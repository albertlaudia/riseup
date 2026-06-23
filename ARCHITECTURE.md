# RiseUP — Architecture (post-split)

> Static content lives in **PocketBase**. User data lives in **Appwrite**.
> The Flutter app talks to both. The web app talks only to PB (read-only).

## Data flow

```
                       ┌──────────────┐
   authors / lessons   │              │   public read-only
   quotes / plans  ───►│  PocketBase  │◄──── web app (Next.js)
   categories          │   (static)   │◄──── Flutter app
                       │              │
                       └──────────────┘

                       ┌──────────────┐
   auth / progress     │              │   per-user, document-level
   favorites / subs ──►│   Appwrite   │◄──── Flutter app only
   settings            │  (per-user)  │
                       │              │
                       └──────────────┘
```

## PocketBase collections (`rup_` prefix)

| Collection | What it is | Public read | Client write |
|---|---|---|---|
| `rup_authors` | Marcus Aurelius, Seneca, … | ✅ | ❌ |
| `rup_works` | Meditations, Letters, … | ✅ | ❌ |
| `rup_categories` | 8 themes | ✅ | ❌ |
| `rup_quotes` | 53 quotes (some `is_pro`) | ✅ | ❌ |
| `rup_lessons` | 15 lessons (orders 5-15 `is_pro`) | ✅ | ❌ |
| `rup_achievements` | 12 achievement defs (4 `is_pro`) | ✅ | ❌ |
| `rup_plans` | 4 plans: free, pro_monthly, pro_yearly, pro_lifetime | ✅ | ❌ |

> The user-scoped collections (`rup_users`, `rup_user_progress`, …) are
> **no longer created** by the bootstrap. They still exist in the live
> instance from the previous version but are unused.

## Appwrite collections (user's project)

Created by `scripts/appwrite/appwrite-setup.mjs`. Lives in the user's own
Appwrite project. Each row is owned by the user — document-level
permissions set on insert.

| Collection | What it is | Indexes |
|---|---|---|
| `user_progress` | Lessons completed (slug + xp + date) | `userId`, unique(`userId`, `lessonSlug`) |
| `user_achievements` | Unlocked achievements | `userId`, unique(`userId`, `achievementCode`) |
| `user_favorites` | Saved quotes / lessons | `userId`, unique(`userId`, `kind`, `targetId`) |
| `user_subscriptions` | Active / past subscriptions (source of truth for tier) | `userId`, `userId+status` |
| `user_settings` | Theme / notifications / font / tier cache | unique(`userId`) |

## Subscription state machine

```
                              ┌─────────────────────────┐
                              │  startMockSubscription  │  (admin, dev, or webhook)
                              └────────┬────────────────┘
                                       ▼
        ┌──────────────────────────────────────────────────────┐
        │  user_subscriptions row:                             │
        │  userId  planCode  status="active"  startedAt  exp   │
        └─────┬──────────────────────────────────┬─────────────┘
              │                                  │
        cancel via                            expires
        profile →                            ──► status flips
        "Manage sub"                              to "expired"
              │                                  │
              ▼                                  ▼
        status="cancelled"                  user.tier → free
        (access stays until exp)
```

The user's current tier is derived in `userStateProvider`:

```dart
final active = await aw.activeSubscription(userId);
final tier = active == null ? UserTier.free : UserTier.pro;
```

`activeSubscription` returns a non-null result only if there's a row with
`status = 'active'` whose `expiresAt` is in the future (or null for
lifetime).

## What the user pays for (current scope)

| Tier | Price | What you get |
|---|---|---|
| Free | $0 | Daily lesson, quote of the day, basic themes, streak tracking. Free lessons only. |
| Pro Monthly | $5.99/mo | Everything in Free + all pro lessons, all pro quotes, favorites sync, offline reading, daily reminders, premium themes, priority support. |
| Pro Yearly | $49.99/yr | Same as Monthly, save 30%. Highlighted as "Best value". |
| Pro Lifetime | $199 once | Same as Yearly, forever. |

11 of 15 lessons and 15 of 53 quotes are gated as `is_pro`. The free
lessons are the first 4 (beginner). The pro lessons are intermediate +
advanced. This means a free user gets a real, useful app — not a
shameless upsell.

## Future hooks

- **Stripe (web)** → your backend → creates `user_subscriptions` row
- **RevenueCat (iOS / Android)** → your backend → creates `user_subscriptions` row
- **FCM (push)** → uses `user_settings.notifications` + `dailyReminderTime`
- **flutter_local_notifications** → local delivery (when network is off)
- **drift / hive** → offline reading cache for lessons
- **Sentry** → error reporting (wire it in `services/`)
