#!/usr/bin/env node
/**
 * One-off migration: mark ~15 featured quotes + 11 lessons (orders 5-15) as
 * `is_pro: true` so the paywall has real content to gate.
 *
 * Idempotent: re-running updates the same records.
 */

const PB_URL = process.env.PB_URL || 'https://pocketbase.scaleupcrm.com';
const PB_IDENTITY = process.env.PB_IDENTITY;
const PB_PASSWORD = process.env.PB_PASSWORD;

if (!PB_IDENTITY || !PB_PASSWORD) {
  console.error('Missing PB_IDENTITY or PB_PASSWORD env var.');
  process.exit(1);
}

const log = (...a) => console.log('[riseup:pro]', ...a);

let token = null;
async function auth() {
  const r = await fetch(`${PB_URL}/api/collections/_superusers/auth-with-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ identity: PB_IDENTITY, password: PB_PASSWORD }),
  });
  const d = await r.json();
  token = d.token;
}
const A = (path, opts = {}) =>
  fetch(`${PB_URL}${path}`, {
    ...opts,
    headers: { 'Content-Type': 'application/json', ...(opts.headers || {}), Authorization: token },
  }).then((r) => r.json());

async function main() {
  await auth();
  log('auth ok');

  // ----- lessons: orders 5-15 are pro -----
  const lessons = await A('/api/collections/rup_lessons/records?perPage=500&sort=order');
  for (const l of lessons.items || []) {
    if ((l.order ?? 0) < 5) continue;     // 1-4 are free (beginner), 5-15 are pro
    if (l.is_pro) continue;
    await A(`/api/collections/rup_lessons/records/${l.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ is_pro: true }),
    });
    log(`  lesson  ${l.slug} (order ${l.order}) → is_pro`);
  }

  // ----- quotes: ~15 featured ones are pro (the ones with reflections + modern voices) -----
  const quotes = await A('/api/collections/rup_quotes/records?perPage=500&filter=is_featured=true');
  let i = 0;
  for (const q of quotes.items || []) {
    if (i >= 15) break;
    if (q.is_pro) { i++; continue; }
    await A(`/api/collections/rup_quotes/records/${q.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ is_pro: true }),
    });
    log(`  quote   "${q.text.slice(0, 40)}..." → is_pro`);
    i++;
  }

  // ----- achievements: the high-end ones are pro-only (100/365 day streaks, sage) -----
  const proCodes = ['century', 'devoted', 'stoic_scholar', 'philosopher'];
  const allAch = await A('/api/collections/rup_achievements/records?perPage=500');
  for (const a of allAch.items || []) {
    if (!proCodes.includes(a.code)) continue;
    if (a.is_pro) continue;
    await A(`/api/collections/rup_achievements/records/${a.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ is_pro: true }),
    });
    log(`  ach     ${a.code} → is_pro`);
  }

  log('done.');
}

main().catch((e) => { console.error('failed:', e); process.exit(1); });
