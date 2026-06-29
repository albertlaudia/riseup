// Subscription plans — static catalog. Lives in PB.
// `features` is a JSON array of feature codes that this plan unlocks.
//
// NOTE: pro_lifetime was removed in 2026-06-29. Lifetime created a long-tail
// liability that doesn't match operational reality (services may change/stop).
// If the model proves out (Year 2+), we can ship a "Founders Edition" instead —
// limited run, refundable pro-rata if we ever shut down.

export const PLANS = [
  {
    code: 'free',
    name: 'Free',
    tagline: 'Start the practice.',
    description: 'A daily lesson, a quote, and a streak. The basics, forever.',
    price_cents: 0,
    currency: 'USD',
    interval: 'free',
    features: [
      'read_daily_lesson',
      'quote_of_the_day',
      'streak_tracking',
      'basic_themes',
    ],
    highlight: false,
    order: 1,
    active: true,
  },
  {
    code: 'pro_monthly',
    name: 'Pro Monthly',
    tagline: 'Everything, every month.',
    description: 'Full library, all quotes, favorites, offline reading, daily reminders.',
    price_cents: 599,
    currency: 'USD',
    interval: 'monthly',
    features: [
      'unlimited_lessons',
      'unlimited_quotes',
      'favorites_sync',
      'offline_reading',
      'daily_reminders',
      'premium_themes',
      'premium_quotes',
      'premium_lessons',
      'priority_support',
    ],
    highlight: false,
    order: 2,
    active: true,
  },
  {
    code: 'pro_yearly',
    name: 'Pro Yearly',
    tagline: 'Save 30%. A year of practice.',
    description: 'Everything in Pro Monthly, billed yearly. The best value for a committed practice.',
    price_cents: 4999,
    currency: 'USD',
    interval: 'yearly',
    features: [
      'unlimited_lessons',
      'unlimited_quotes',
      'favorites_sync',
      'offline_reading',
      'daily_reminders',
      'premium_themes',
      'premium_quotes',
      'premium_lessons',
      'priority_support',
    ],
    highlight: true,
    order: 3,
    active: true,
  },
];