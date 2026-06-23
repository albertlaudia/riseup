#!/usr/bin/env node
/**
 * RiseUP PocketBase Seed
 *
 * - Idempotent: skips records that already exist (matched by slug / code).
 * - Resolves `*_slug` references to PB record ids.
 * - Run after `pb-bootstrap.mjs`.
 *
 * Usage:
 *   PB_URL=https://pocketbase.scaleupcrm.com \
 *   PB_IDENTITY=minimax@scaleupcrm.com \
 *   PB_PASSWORD='your-password' \
 *   node seed.mjs
 */

import { AUTHORS } from './seed/authors.mjs';
import { WORKS } from './seed/works.mjs';
import { CATEGORIES } from './seed/categories.mjs';
import { QUOTES } from './seed/quotes.mjs';
import { LESSONS } from './seed/lessons.mjs';
import { ACHIEVEMENTS } from './seed/achievements.mjs';
import { PLANS } from './seed/plans.mjs';

const PB_URL = process.env.PB_URL || 'https://pocketbase.scaleupcrm.com';
const PB_IDENTITY = process.env.PB_IDENTITY;
const PB_PASSWORD = process.env.PB_PASSWORD;

if (!PB_IDENTITY || !PB_PASSWORD) {
  console.error('Missing PB_IDENTITY or PB_PASSWORD env var.');
  process.exit(1);
}

const log = (...a) => console.log('[riseup:seed]', ...a);

// ---------- HTTP ----------
async function pb(path, opts = {}) {
  const res = await fetch(`${PB_URL}${path}`, {
    ...opts,
    headers: { 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  const text = await res.text();
  let body;
  try { body = text ? JSON.parse(text) : null; } catch { body = text; }
  if (!res.ok) {
    const msg = body?.message || body?.error?.message || res.statusText;
    const err = new Error(`${opts.method || 'GET'} ${path} → ${res.status} ${msg}`);
    err.status = res.status;
    err.body = body;
    throw err;
  }
  return body;
}

let token = null;
async function auth() {
  const r = await pb('/api/collections/_superusers/auth-with-password', {
    method: 'POST',
    body: JSON.stringify({ identity: PB_IDENTITY, password: PB_PASSWORD }),
  });
  token = r.token;
  return token;
}
const A = (path, opts = {}) =>
  pb(path, { ...opts, headers: { ...(opts.headers || {}), Authorization: token } });

// ---------- helpers ----------
async function listAll(collection, query = '') {
  // PB paginates at 500/page by default; for our seed sizes we won't hit it,
  // but be safe: ask for up to 1000.
  const r = await A(`/api/collections/${collection}/records?perPage=1000&${query}`);
  return r.items || [];
}

function pickExisting(items, key) {
  const m = new Map();
  for (const it of items) m.set(it[key], it.id);
  return m;
}

async function createIfMissing(collection, payload, matchKey) {
  const items = await listAll(collection);
  if (items.find((it) => it[matchKey] === payload[matchKey])) {
    return { id: items.find((it) => it[matchKey] === payload[matchKey]).id, created: false };
  }
  const r = await A(`/api/collections/${collection}/records`, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  return { id: r.id, created: true };
}

// ---------- main ----------
async function main() {
  log(`target: ${PB_URL}`);
  await auth();
  log('auth ok');

  // ----- authors -----
  log('seeding rup_authors');
  const authorIds = new Map();
  for (const a of AUTHORS) {
    const { id, created } = await createIfMissing('rup_authors', {
      name: a.name,
      slug: a.slug,
      era: a.era,
      bio: a.bio,
      avatar_url: a.avatar_url,
      order: a.order,
      created_at: new Date().toISOString(),
    }, 'slug');
    authorIds.set(a.slug, id);
    log(`  ${created ? '+' : '='} ${a.slug} → ${id}`);
  }

  // ----- works -----
  log('seeding rup_works');
  for (const w of WORKS) {
    const authorId = authorIds.get(w.author_slug);
    if (!authorId) throw new Error(`Unknown author_slug: ${w.author_slug}`);
    const { id, created } = await createIfMissing('rup_works', {
      author: authorId,
      title: w.title,
      slug: w.slug,
      description: w.description,
      year: w.year,
      created_at: new Date().toISOString(),
    }, 'slug');
    log(`  ${created ? '+' : '='} ${w.slug} → ${id}`);
  }

  // ----- categories -----
  log('seeding rup_categories');
  const catIds = new Map();
  for (const c of CATEGORIES) {
    const { id, created } = await createIfMissing('rup_categories', {
      name: c.name,
      slug: c.slug,
      icon: c.icon,
      color: c.color,
      description: c.description,
      order: c.order,
      created_at: new Date().toISOString(),
    }, 'slug');
    catIds.set(c.slug, id);
    log(`  ${created ? '+' : '='} ${c.slug} → ${id}`);
  }

  // ----- works already seeded; re-fetch for ids -----
  const workItems = await listAll('rup_works');
  const workIds = pickExisting(workItems, 'slug');

  // ----- quotes -----
  log('seeding rup_quotes');
  let qCreated = 0, qSkipped = 0;
  // For quotes we don't have a slug — use text as the dedupe key (first 80 chars).
  const quoteItems = await listAll('rup_quotes');
  const quoteTextSet = new Set(quoteItems.map((q) => q.text));
  for (const q of QUOTES) {
    if (quoteTextSet.has(q.text)) { qSkipped++; continue; }
    const payload = {
      text: q.text,
      reflection: q.reflection || null,
      is_featured: !!q.is_featured,
      created_at: new Date().toISOString(),
    };
    if (q.author_slug) payload.author = authorIds.get(q.author_slug);
    if (q.work_slug)   payload.work   = workIds.get(q.work_slug);
    if (q.theme_slug)  payload.theme  = catIds.get(q.theme_slug);
    await A('/api/collections/rup_quotes/records', { method: 'POST', body: JSON.stringify(payload) });
    qCreated++;
  }
  log(`  +${qCreated} new, =${qSkipped} already present`);

  // ----- lessons -----
  log('seeding rup_lessons');
  const lessonItems = await listAll('rup_lessons');
  const lessonSlugSet = new Set(lessonItems.map((l) => l.slug));
  let lCreated = 0, lSkipped = 0;
  for (const l of LESSONS) {
    if (lessonSlugSet.has(l.slug)) { lSkipped++; continue; }
    const payload = {
      title: l.title,
      slug: l.slug,
      intro: l.intro,
      content: l.content,
      key_takeaway: l.key_takeaway,
      action_step: l.action_step,
      read_time_min: l.read_time_min,
      difficulty: l.difficulty,
      order: l.order,
      is_featured: !!l.is_featured,
      cover_url: l.cover_url || null,
      created_at: new Date().toISOString(),
    };
    if (l.author_slug) payload.author = authorIds.get(l.author_slug);
    if (l.theme_slug)  payload.theme  = catIds.get(l.theme_slug);
    await A('/api/collections/rup_lessons/records', { method: 'POST', body: JSON.stringify(payload) });
    lCreated++;
  }
  log(`  +${lCreated} new, =${lSkipped} already present`);

  // ----- achievements -----
  log('seeding rup_achievements');
  let aCreated = 0, aSkipped = 0;
  const achItems = await listAll('rup_achievements');
  const achCodeSet = new Set(achItems.map((a) => a.code));
  for (const a of ACHIEVEMENTS) {
    if (achCodeSet.has(a.code)) { aSkipped++; continue; }
    await A('/api/collections/rup_achievements/records', {
      method: 'POST',
      body: JSON.stringify({
        code: a.code,
        title: a.title,
        description: a.description,
        icon: a.icon,
        xp_reward: a.xp_reward,
        condition_type: a.condition_type,
        condition_value: a.condition_value,
        order: a.order,
        created_at: new Date().toISOString(),
      }),
    });
    aCreated++;
  }
  log(`  +${aCreated} new, =${aSkipped} already present`);

  // ----- plans (subscription catalog) -----
  log('seeding rup_plans');
  let pCreated = 0, pSkipped = 0;
  const planItems = await listAll('rup_plans');
  const planCodeSet = new Set(planItems.map((p) => p.code));
  for (const p of PLANS) {
    if (planCodeSet.has(p.code)) { pSkipped++; continue; }
    await A('/api/collections/rup_plans/records', {
      method: 'POST',
      body: JSON.stringify({
        code: p.code,
        name: p.name,
        tagline: p.tagline,
        description: p.description,
        price_cents: p.price_cents,
        currency: p.currency,
        interval: p.interval,
        features: p.features,
        highlight: p.highlight,
        order: p.order,
        active: p.active,
        created_at: new Date().toISOString(),
      }),
    });
    pCreated++;
  }
  log(`  +${pCreated} new, =${pSkipped} already present`);

  log('done.');
}

main().catch((e) => {
  console.error('seed failed:', e.message);
  if (e.body) console.error(JSON.stringify(e.body, null, 2));
  process.exit(1);
});
