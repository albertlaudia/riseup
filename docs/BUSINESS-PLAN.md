# RiseUP — Commercial & business plan

**Date:** 2026-06-29
**Version:** v0.1.0
**Owner:** Albert Laudia (founder)

---

## 1. The product

**RiseUP** is a daily Stoic practice app for iOS, Android, and web. One
short lesson in the morning. One quote to carry through the day. A streak
that doesn't care about your mood.

It is built around a simple premise: most of what we call motivation is
really just attention. Pay attention, on purpose, to the right things, for
thirty seconds a day, and the rest of the day behaves differently.

The free tier is generous on purpose — 4 beginner lessons, the daily quote,
basic streak tracking — so the app has real value even before any
subscription. Pro unlocks the deeper lessons, daily reminders, favorites
sync, offline reading.

---

## 2. Market

### TAM / SAM / SOM

| Tier | Definition | Size (estimate) |
|---|---|---|
| TAM | Global adults interested in Stoicism, mindfulness, self-improvement | ~50M |
| SAM | English-speaking smartphone owners in that audience | ~5M |
| SOM (Year 1) | Addressable paying users in our launch markets | ~10K |
| SOM (Year 3) | Same, after i18n + content partnerships | ~100K |

### Competitive landscape

| App | Niche | Pricing | Notes |
|---|---|---|---|
| Calm | General meditation | $14.99/mo | Established, large content budget, B2B |
| Headspace | General meditation | $12.99/mo | Same |
| Oak | Meditation + breath | Free / $9.99/mo | Smaller, design-forward |
| stoic.app | Stoic-only | Free / $6.99/mo | Closest direct competitor |
| The Daily Stoic (book + app) | Stoic + content | Book + free app | Different angle — book-led |
| Reflect | Journaling | $11.99/mo | Adjacent — they own journaling |

**RiseUP's wedge:** stoic-only + lesson-led (not quote-only) + generous free
tier + cheap yearly. Closest competitor is stoic.app; we differentiate by
being more *lesson-focused* (not just quotes) and by a stronger free tier.

### Why now

- "Stoicism" Google search interest has been climbing 2018-2026 (per Google
  Trends). The audience is growing, not shrinking.
- The post-pandemic mental-health app market has cooled (Calm, Headspace
  layoffs in 2023-24) — the audience is fatigued on meditation. A focused,
  no-nonsense practice has room.
- Personal AI / on-device inference is exploding in 2026 — agents that
  deliver *one thing well* are eating general-purpose apps. RiseUP is one
  thing, done well.

---

## 3. Product strategy

### Free tier (the wedge)

The free tier is the funnel. It needs to:
1. Deliver genuine value (4 lessons is enough to start a practice)
2. Build the daily habit (the streak is the hook)
3. Show, not tell, what Pro unlocks (locked content is visible, not hidden)

Locked content shows as a "Pro" chip + the card stays visible but blurred
behind a "Tap to unlock" overlay. The user knows exactly what they're
missing.

### Pro tier (the moat)

Pro adds the things that turn a daily visit into a daily practice:
- 11 more lessons (intermediate + advanced)
- Daily reminder notification
- Favorites sync across devices
- Offline reading
- Premium themes

### Pricing

| Tier | Price | Margin (after store cut) | Notes |
|---|---|---|---|
| Free | $0 | — | funnel |
| Pro Monthly | $5.99 | $4.20 (70%) | lowest-friction entry |
| Pro Yearly | $49.99 | $34.99 (70%) | best value, marked in paywall |

**No lifetime tier.** Lifetime creates a long-tail liability that doesn't
match operational reality — if we ever shut down or migrate to a
different platform, we owe refunds or continuation, which is awkward to
defend. Year-2+ options if the model proves out:

- **Family plan** ($99/yr, up to 5 seats) — better unit economics, multiplies LTV per account.
- **Founders Edition** — limited run (first 500 users), positioned as "thank the early believers". Explicit terms: if we ever shut down, founders get a pro-rata refund. Reframes lifetime as a *bond*, not a *subscription*.

App stores take 30% on the first $1M, 15% after. RevenueCat's small fee on
top, then Stripe on web. Net is roughly 70% to us.

---

## 4. Distribution

### Channels

| Channel | Why | Target |
|---|---|---|
| **App Store search** (ASO) | High-intent, free | Primary |
| **Reddit r/Stoicism** | Direct audience match | Primary |
| **Daily Stoic / Stoa cross-promo** | Borrowed audience | Primary |
| **Twitter / X "Stoic Twitter"** | Vocal niche | Secondary |
| **Product Hunt launch** | Day-1 spike | Secondary |
| **YouTube sponsorships** | Stoic / philosophy channels | Tertiary |
| **TikTok** | Visual short-form quotes | Experimental |
| **Paid ads (Apple Search Ads, Google UAC)** | Once profitable | Phase 2 |

### Anti-channels

- Influencer marketing on general "wellness" — wrong audience
- Podcast ads on general business podcasts — too expensive, low conversion
- App store search ads for "meditation" — too competitive

### Phased rollout

| Phase | What | When |
|---|---|---|
| **0. Internal** | TestFlight + Play internal, 10-20 testers | Pre-launch |
| **1. Closed beta** | 50 testers, 2 weeks feedback | Pre-launch |
| **2. Soft launch** | 1-2 markets (Singapore, US, CA), 2-4 weeks | Launch week |
| **3. Full launch** | Worldwide, paid + organic push | After soft-launch metrics are healthy |

The soft-launch markets matter because: Singapore = the founder's home
(quick iteration), US/CA = the primary English-language market. SKIP the
EU until GDPR compliance is verified.

---

## 5. Unit economics

### Customer Acquisition Cost (CAC)

| Channel | CAC estimate | Notes |
|---|---|---|
| Organic (ASO, Reddit, cross-promo) | $2-5 | realistic at small scale |
| Apple Search Ads | $10-15 | competitive for "stoic" |
| Google UAC | $8-12 | competitive for "stoic meditation" |
| Influencer (small Stoic creators) | $1-3 per install | bartering in early days |

Target blended CAC: **$5-8**.

### Lifetime Value (LTV)

Assuming:
- 5% of free users convert to paid within 30 days
- 60% annual retention for paid users
- Average paid tenure: 8 months (mix of monthly churn + annual renewals)

LTV per free user: $5.99 × 0.05 × 8 = **$2.40**
LTV per paid user (annual plan mix): **~$32**

CAC payback: $5-8 / $32 = **2-4 months** (paid user). Healthy.

### The funnel math

| Stage | Top → Next | Goal |
|---|---|---|
| Store impression → install | 5% | Strong ASO + screenshots |
| Install → first launch → onboarding → first lesson | 70% | Smooth onboarding + great first lesson |
| First lesson → second day return | 40% | Daily reminder (when shipped) |
| 7-day return | 25% | Streak + reflection loop |
| 30-day return | 15% | Becomes a habit |
| Free → paid | 5% | Paywall + content gating |
| Paid → 12-month retention | 60% | Continuous content drops |

---

## 6. SMART goals

### Year 1 — Launch & prove the model

**Goal 1.1: Ship to both stores within 90 days**

- **Specific:** Submit AAB to Play Store and IPA to TestFlight.
- **Measurable:** Both stores show "Ready for Sale" / "Available".
- **Achievable:** Code is done; remaining work is provisioning accounts + store assets.
- **Relevant:** Without it, no users.
- **Time-bound:** 90 days from 2026-06-29 (i.e., by 2026-09-27).

**Goal 1.2: 1,000 downloads in first 30 days post-launch**

- **Specific:** Reach 1,000 cumulative downloads.
- **Measurable:** App Store Connect + Play Console live counters.
- **Achievable:** 1k downloads in 30 days from a small launch + Reddit cross-promo is realistic.
- **Relevant:** Validates the funnel works.
- **Time-bound:** 30 days after launch.

**Goal 1.3: 50 paying users in first 90 days post-launch**

- **Specific:** 50 active Pro subscriptions.
- **Measurable:** RevenueCat / Stripe dashboards.
- **Achievable:** 5% conversion of 1,000 = 50. (Note: launch installs may be higher by then.)
- **Relevant:** Validates willingness to pay.
- **Time-bound:** 90 days post-launch.

**Goal 1.4: $1,500 MRR by end of Year 1**

- **Specific:** Monthly recurring revenue of at least $1,500.
- **Measurable:** Stripe + RevenueCat combined.
- **Achievable:** 50 monthly subscribers × $5.99 = $300 MRR from monthly alone, plus annual / lifetime conversions bringing it to ~$1,500.
- **Relevant:** Proves the unit economics.
- **Time-bound:** 2026-12-31.

**Goal 1.5: 4.5+ star rating on both stores**

- **Specific:** Average user rating of 4.5 / 5 or higher.
- **Measurable:** App Store Connect + Play Console.
- **Achievable:** The free tier is generous, the design is intentional, the content is real — the rating should land high. Monitor 1-2 star reviews weekly and respond.
- **Relevant:** Critical for ASO conversion.
- **Time-bound:** End of Year 1.

### Year 2 — Engagement & growth

**Goal 2.1: 30-day retention of 15%+**

- **Specific:** Of users who install in week N, 15%+ are still active in week N+4.
- **Measurable:** PostHog or Amplitude cohort analysis.
- **Achievable:** With daily reminder + onboarding + reflection loop, 15% is industry-average for this category.
- **Relevant:** Retention is the moat for content apps.
- **Time-bound:** 12 months post-launch.

**Goal 2.2: 500 paying users**

- **Specific:** 500 active paid subscriptions.
- **Measurable:** RevenueCat / Stripe.
- **Achievable:** ~5,000 downloads × 10% conversion = 500, with retention improvements.
- **Relevant:** MRR grows with this.
- **Time-bound:** Month 18 (Q1 Year 2).

**Goal 2.3: $15,000 MRR**

- **Specific:** $15K MRR (combined Stripe + RevenueCat).
- **Measurable:** Yes.
- **Achievable:** 500 × ~$30 avg = $15K. Mix of monthly, annual, lifetime.
- **Relevant:** First real milestone for any consumer SaaS.
- **Time-bound:** Month 18.

**Goal 2.4: 2 content partnerships**

- **Specific:** Two formal cross-promo partnerships with established Stoic creators or media (Daily Stoic, Stoa, etc.).
- **Measurable:** Number of signed deals with documented terms.
- **Achievable:** Yes — these communities are collaborative.
- **Relevant:** Distribution + credibility.
- **Time-bound:** Month 18.

### Year 3 — Scale

**Goal 3.1: 50,000 cumulative downloads**

- **Specific:** 50K total downloads across iOS + Android.
- **Measurable:** App Store Connect + Play Console.
- **Achievable:** With paid + organic at scale.
- **Relevant:** Sustainable growth indicator.
- **Time-bound:** Month 36.

**Goal 3.2: 3,000 paying users, $90K MRR**

- **Specific:** 3,000 active paid subscriptions, $90K MRR.
- **Measurable:** Yes.
- **Achievable:** With i18n (4x addressable market), content partnerships, and ongoing retention.
- **Relevant:** Top-line growth.
- **Time-bound:** Month 36.

**Goal 3.3: 1 corporate wellness (B2B) pilot**

- **Specific:** Pilot a B2B / corporate wellness tier with at least one paying company.
- **Measurable:** Signed contract + active seats.
- **Achievable:** B2B is a long sale but the unit economics are obviously better.
- **Relevant:** New revenue line, better LTV.
- **Time-bound:** Month 30.

### Year 4-5 — Platform / exit

If the unit economics hold by end of Year 3, three paths open:

1. **Independent growth** — keep growing, hire, $1M+ ARR, possibly raise
2. **Strategic partnership** — acquire by Calm / Headspace / Substack / similar
3. **B2B pivot** — corporate wellness becomes the dominant line

No decision needed today. The job is to make the Year 3 numbers clean.

---

## 7. Moats (defensibility)

What stops someone else from copying RiseUP tomorrow?

| Moat | How it builds |
|---|---|
| **Content library** | 15 lessons + 53 quotes + 15 prompts + 7 quick practices — written, not aggregated. Not trivially replicable. |
| **Daily habit** | The streak is the moat. Every day a user comes back, switching cost goes up. |
| **Journal data** | Per-user reflection entries in Appwrite. The user's history of what they wrote is the most personal moat — and the hardest to switch away from. |
| **Brand voice** | "Waste no more time arguing what a good man should be. Be one." Specific, not generic. Takes a long time to imitate. |
| **On-device privacy** | Architecture-friendly to offline-first + private; future AI features (TTS, daily journal summary) can run on-device. Real privacy, not marketing privacy. |

---

## 8. Risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Stoicism interest is a fad | Medium | High | The practices are 2000+ years old; "fad" is unlikely. |
| Big player (Calm, etc.) ships a Stoic pack | Medium | Medium | We differentiate by focus; Calm is generalist. |
| Subscription fatigue | High | Medium | Generous free tier + non-aggressive paywall + genuinely useful free content. |
| Burnout / churn after 90 days | High | Medium | Continuous content drops; weekly digest; "on this day" feature. |
| Apple / Google policy change | Low | High | Multi-platform; web is a fallback; localization. |
| Founder burnout | Medium | High | This plan is intentionally conservative on workload. |

---

## 9. What I need from you

If you (the founder) are committing to the Year 1 plan, here is what
needs to happen in the next 4 weeks:

1. **Provision accounts** (1 day, in parallel)
   - Google Play Developer
   - Apple Developer
   - Appwrite
   - Firebase
   - Stripe
   - RevenueCat

2. **Make legal decisions** (1 day)
   - Singapore or US entity? (Affects tax + where revenue lands.)
   - Privacy policy + ToS — hire a lawyer for an hour, or use a generator

3. **Run device tests** (3-5 days)
   - Install Flutter locally
   - `flutter create .` + `flutter pub get`
   - `flutter run` on a phone
   - Walk through every screen, fix what breaks

4. **Approve content** (1 day)
   - Read the 15 lessons — are they what you'd want to read?
   - Read the 53 quotes — accurate attribution?
   - Read the 7 quick practices — voice right?

5. **Submit to stores** (1 day)
   - Build AAB / IPA
   - Upload to Play internal + TestFlight internal
   - Iterate on feedback for a week

6. **Plan launch** (2-3 days)
   - Draft Reddit launch post
   - Identify 2-3 Stoic creators for cross-promo
   - Write 1-pager press release
   - Prepare screenshots + demo video

---

## 10. What I'm committing to

If you greenlight this, here's what I'll deliver in the next 4 weeks:

1. **Real Stripe checkout wired** on the web app
2. **Real RevenueCat wired** on the mobile app (replaces `startMockSubscription`)
3. **Daily reminder** (FCM + flutter_local_notifications) — the biggest single
   engagement win
4. **Streak freeze** — schema is there, I add the UI + monthly reset
5. **Achievement celebration** — confetti / haptic on unlock
6. **Privacy policy + ToS drafts** — minimal, lawyer-reviewable
7. **Store listing copy** — for you to approve + tweak
8. **5-6 screenshots per platform** — mock-ups from real device runs
9. **Feature graphic (Android 1024×500)** — designed
10. **App icon at all sizes** — exported

After launch, the work continues on:
- Engagement iteration (weekly content drops, A/B test reminder copy)
- i18n (zh-CN, ja, ms, ta — Singapore + Asia Pacific)
- B2B tier design
- Year 2 features (TTS narration, widgets, watchOS)

---

## Appendix A: One-page pitch

**RiseUP** is the daily Stoic practice app for people who want a small,
real habit — not another meditation subscription.

The market: ~5M English-speaking adults interested in Stoicism, growing
year-over-year.

The product: free daily lesson + quote + streak. Pro unlocks deeper
lessons, daily reminders, favorites sync, offline reading.

The pricing: $5.99/mo, $49.99/yr, $199 lifetime. Blended margin ~70% after
app store + processor.

The moat: content library (15 lessons, written, not aggregated) + daily
habit (the streak) + journal data (per-user, the most personal moat).

The Year 1 target: 1,000 downloads → 50 paying → $1,500 MRR → 4.5+ stars.

The Year 3 target: 50,000 downloads → 3,000 paying → $90,000 MRR.

The ask: 4 weeks of focused work + the 6 accounts above. Then ship.

---

## Appendix B: Why this can be a real business

1. **The market exists.** stoic.app is making real money. The Daily Stoic
   is a real brand. People pay for this.
2. **The economics work.** 70% margin, 2-4 month CAC payback. Comparable
   to Calm and Headspace.
3. **The moat is real.** Content + habit + journal. Switching cost goes up
   daily.
4. **The market is growing.** Stoicism search interest has been climbing
   for 8 years.
5. **The execution risk is low.** All the technology is built. Remaining
   work is provisioning + legal + content polish.
6. **The downside is bounded.** No inventory, no server-side rendering,
   no high burn rate. Could run as a side project for years.