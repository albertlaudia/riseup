#!/usr/bin/env node
/**
 * RiseUP PocketBase Bootstrap (v0.39)
 *
 * - Creates the full `rup_*` schema (authors, works, categories, quotes,
 *   lessons, achievements, users, progress, achievements-log, favorites,
 *   settings) with proper rules.
 * - Indexes are added in a follow-up PATCH (PB requires columns to exist
 *   before it can index them).
 * - Relation fields use the actual pbc_xxx id of the target collection.
 *
 * Idempotent: re-running is safe — it skips existing collections and just
 * refreshes the rules.
 *
 * Usage:
 *   PB_URL=https://pocketbase.scaleupcrm.com \
 *   PB_IDENTITY=minimax@scaleupcrm.com \
 *   PB_PASSWORD='your-password' \
 *   node pb-bootstrap.mjs
 */

const PB_URL = process.env.PB_URL || 'https://pocketbase.scaleupcrm.com';
const PB_IDENTITY = process.env.PB_IDENTITY;
const PB_PASSWORD = process.env.PB_PASSWORD;

if (!PB_IDENTITY || !PB_PASSWORD) {
  console.error('Missing PB_IDENTITY or PB_PASSWORD env var.');
  process.exit(1);
}

const log = (...a) => console.log('[riseup]', ...a);

// ---------- HTTP helpers ----------
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

// ---------- collection definitions ----------
const DEFS = [
  {
    name: 'rup_authors',
    relTargets: [],
    fields: () => [
      { name: 'name', type: 'text', required: true },
      { name: 'slug', type: 'text', required: true },
      { name: 'era', type: 'text', required: false },
      { name: 'bio', type: 'text', required: false },
      { name: 'avatar_url', type: 'url', required: false },
      { name: 'order', type: 'number', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_authors_slug ON rup_authors (slug)'],
  },
  {
    name: 'rup_works',
    relTargets: ['rup_authors'],
    fields: (ids) => [
      { name: 'author', type: 'relation', required: true, collectionId: ids['rup_authors'], maxSelect: 1, cascadeDelete: false },
      { name: 'title', type: 'text', required: true },
      { name: 'slug', type: 'text', required: true },
      { name: 'description', type: 'text', required: false },
      { name: 'year', type: 'number', required: false },
      { name: 'cover_url', type: 'url', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_works_slug ON rup_works (slug)'],
  },
  {
    name: 'rup_categories',
    relTargets: [],
    fields: () => [
      { name: 'name', type: 'text', required: true },
      { name: 'slug', type: 'text', required: true },
      { name: 'icon', type: 'text', required: false },
      { name: 'color', type: 'text', required: false },
      { name: 'description', type: 'text', required: false },
      { name: 'order', type: 'number', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_categories_slug ON rup_categories (slug)'],
  },
  {
    name: 'rup_quotes',
    relTargets: ['rup_authors', 'rup_works', 'rup_categories'],
    fields: (ids) => [
      { name: 'text', type: 'text', required: true },
      { name: 'author', type: 'relation', required: false, collectionId: ids['rup_authors'], maxSelect: 1, cascadeDelete: false },
      { name: 'work', type: 'relation', required: false, collectionId: ids['rup_works'], maxSelect: 1, cascadeDelete: false },
      { name: 'theme', type: 'relation', required: false, collectionId: ids['rup_categories'], maxSelect: 1, cascadeDelete: false },
      { name: 'reflection', type: 'text', required: false },
      { name: 'is_featured', type: 'bool', required: false },
      { name: 'is_pro', type: 'bool', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
  },
  {
    name: 'rup_lessons',
    relTargets: ['rup_authors', 'rup_categories'],
    fields: (ids) => [
      { name: 'title', type: 'text', required: true },
      { name: 'slug', type: 'text', required: true },
      { name: 'author', type: 'relation', required: false, collectionId: ids['rup_authors'], maxSelect: 1, cascadeDelete: false },
      { name: 'theme', type: 'relation', required: false, collectionId: ids['rup_categories'], maxSelect: 1, cascadeDelete: false },
      { name: 'intro', type: 'text', required: false },
      { name: 'content', type: 'text', required: true },
      { name: 'key_takeaway', type: 'text', required: false },
      { name: 'action_step', type: 'text', required: false },
      { name: 'read_time_min', type: 'number', required: false },
      { name: 'difficulty', type: 'select', required: false, values: ['beginner', 'intermediate', 'advanced'] },
      { name: 'order', type: 'number', required: false },
      { name: 'is_featured', type: 'bool', required: false },
      { name: 'is_pro', type: 'bool', required: false },
      { name: 'cover_url', type: 'url', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_lessons_slug ON rup_lessons (slug)'],
  },
  {
    name: 'rup_achievements',
    relTargets: [],
    fields: () => [
      { name: 'code', type: 'text', required: true },
      { name: 'title', type: 'text', required: true },
      { name: 'description', type: 'text', required: false },
      { name: 'icon', type: 'text', required: false },
      { name: 'xp_reward', type: 'number', required: false },
      { name: 'condition_type', type: 'select', required: false, values: ['streak', 'lessons_completed', 'themes_explored', 'favorites', 'first_lesson', 'quote_read'] },
      { name: 'condition_value', type: 'number', required: false },
      { name: 'order', type: 'number', required: false },
      { name: 'is_pro', type: 'bool', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_achievements_code ON rup_achievements (code)'],
  },

  // ---------- subscription plans (static catalog) ----------
  {
    name: 'rup_plans',
    relTargets: [],
    fields: () => [
      { name: 'code', type: 'text', required: true },
      { name: 'name', type: 'text', required: true },
      { name: 'tagline', type: 'text', required: false },
      { name: 'description', type: 'text', required: false },
      { name: 'price_cents', type: 'number', required: false },     // 0 for free, 599 for $5.99
      { name: 'currency', type: 'text', required: false },          // "USD"
      { name: 'interval', type: 'select', required: false, values: ['free', 'monthly', 'yearly', 'lifetime'] },
      { name: 'features', type: 'json', required: false },          // array of feature codes
      { name: 'highlight', type: 'bool', required: false },
      { name: 'order', type: 'number', required: false },
      { name: 'active', type: 'bool', required: false },
      { name: 'created_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_plans_code ON rup_plans (code)'],
  },

  // ---------- user-scoped (DEPRECATED — user data lives in Appwrite) ----------
  // The collections below are no longer created by this bootstrap.
  // They still exist in the live PB instance from the previous run but are
  // unused by the app. User data now lives in Appwrite (see scripts/appwrite-setup.mjs).
  /* KEEPING THESE AS REFERENCE — DO NOT UNCOMMENT
  {
    name: 'rup_users',
    relTargets: [],
    fields: () => [
      { name: 'firebase_uid', type: 'text', required: true },
      { name: 'email', type: 'email', required: false },
      { name: 'display_name', type: 'text', required: false },
      { name: 'avatar_url', type: 'url', required: false },
      { name: 'xp', type: 'number', required: false },
      { name: 'level', type: 'number', required: false },
      { name: 'streak_current', type: 'number', required: false },
      { name: 'streak_longest', type: 'number', required: false },
      { name: 'last_active_date', type: 'date', required: false },
      { name: 'total_lessons', type: 'number', required: false },
      { name: 'total_quotes_read', type: 'number', required: false },
      { name: 'joined_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_users_firebase_uid ON rup_users (firebase_uid)'],
  },
  {
    name: 'rup_user_progress',
    relTargets: ['rup_users', 'rup_lessons'],
    fields: (ids) => [
      { name: 'user', type: 'relation', required: true, collectionId: ids['rup_users'], maxSelect: 1, cascadeDelete: true },
      { name: 'lesson', type: 'relation', required: true, collectionId: ids['rup_lessons'], maxSelect: 1, cascadeDelete: false },
      { name: 'xp_earned', type: 'number', required: false },
      { name: 'completed_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_user_progress_user_lesson ON rup_user_progress (user, lesson)'],
  },
  {
    name: 'rup_user_achievements',
    relTargets: ['rup_users', 'rup_achievements'],
    fields: (ids) => [
      { name: 'user', type: 'relation', required: true, collectionId: ids['rup_users'], maxSelect: 1, cascadeDelete: true },
      { name: 'achievement', type: 'relation', required: true, collectionId: ids['rup_achievements'], maxSelect: 1, cascadeDelete: false },
      { name: 'unlocked_at', type: 'date', required: false },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_user_achievements_user_ach ON rup_user_achievements (user, achievement)'],
  },
  {
    name: 'rup_favorites',
    relTargets: ['rup_users', 'rup_quotes', 'rup_lessons'],
    fields: (ids) => [
      { name: 'user', type: 'relation', required: true, collectionId: ids['rup_users'], maxSelect: 1, cascadeDelete: true },
      { name: 'quote', type: 'relation', required: false, collectionId: ids['rup_quotes'], maxSelect: 1, cascadeDelete: true },
      { name: 'lesson', type: 'relation', required: false, collectionId: ids['rup_lessons'], maxSelect: 1, cascadeDelete: true },
      { name: 'created_at', type: 'date', required: false },
    ],
  },
  {
    name: 'rup_settings',
    relTargets: ['rup_users'],
    fields: (ids) => [
      { name: 'user', type: 'relation', required: true, collectionId: ids['rup_users'], maxSelect: 1, cascadeDelete: true },
      { name: 'theme', type: 'select', required: false, values: ['light', 'dark', 'auto'] },
      { name: 'notifications', type: 'bool', required: false },
      { name: 'daily_reminder_time', type: 'text', required: false },
      { name: 'font_size', type: 'select', required: false, values: ['small', 'medium', 'large'] },
    ],
    indexes: ['CREATE UNIQUE INDEX idx_rup_settings_user ON rup_settings (user)'],
  },
  */
];

// ---------- rules ----------
// Static content: public read, no client writes.
// User data lives in Appwrite now — PB doesn't carry user collections.
const RULES = {
  rup_authors:       { list: '', view: '', create: null, update: null, delete: null },
  rup_works:         { list: '', view: '', create: null, update: null, delete: null },
  rup_categories:    { list: '', view: '', create: null, update: null, delete: null },
  rup_quotes:        { list: '', view: '', create: null, update: null, delete: null },
  rup_lessons:       { list: '', view: '', create: null, update: null, delete: null },
  rup_achievements:  { list: '', view: '', create: null, update: null, delete: null },
  rup_plans:         { list: '', view: '', create: null, update: null, delete: null },
};

function userScoped(relField) {
  return {
    list:   `@request.auth.collectionId = '_superusers' || ${relField}.firebase_uid = @request.auth.id`,
    view:   `@request.auth.collectionId = '_superusers' || ${relField}.firebase_uid = @request.auth.id`,
    create: `${relField}.firebase_uid = @request.auth.id || @request.auth.collectionId = '_superusers'`,
    update: `${relField}.firebase_uid = @request.auth.id || @request.auth.collectionId = '_superusers'`,
    delete: `${relField}.firebase_uid = @request.auth.id || @request.auth.collectionId = '_superusers'`,
  };
}

// ---------- main ----------
async function getCollectionId(name) {
  try {
    const r = await A(`/api/collections/${name}`);
    return r.id;
  } catch (e) {
    if (e.status === 404) return null;
    throw e;
  }
}

async function getCollectionMeta(name) {
  try {
    return await A(`/api/collections/${name}`);
  } catch (e) {
    if (e.status === 404) return null;
    throw e;
  }
}

async function createCollection(def, ids) {
  const rules = RULES[def.name];
  const body = {
    name: def.name,
    type: 'base',
    fields: def.fields(ids),
    listRule: rules.list,
    viewRule: rules.view,
    createRule: rules.create,
    updateRule: rules.update,
    deleteRule: rules.delete,
  };
  const r = await A('/api/collections', { method: 'POST', body: JSON.stringify(body) });
  if (def.indexes && def.indexes.length) {
    await A(`/api/collections/${r.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ indexes: def.indexes }),
    });
  }
  log(`created  ${def.name} (${r.id})`);
  return r.id;
}

async function applyRules(name) {
  const rules = RULES[name];
  const id = await getCollectionId(name);
  await A(`/api/collections/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({
      listRule: rules.list,
      viewRule: rules.view,
      createRule: rules.create,
      updateRule: rules.update,
      deleteRule: rules.delete,
    }),
  });
  log(`rules    ${name}`);
}

async function main() {
  log(`target: ${PB_URL}`);
  await auth();
  log('auth ok');

  // 1. Resolve existing ids and verify completeness
  const ids = {};
  for (const def of DEFS) {
    const meta = await getCollectionMeta(def.name);
    if (meta) {
      ids[def.name] = meta.id;
      const haveFields = new Set((meta.fields || []).map((f) => f.name));
      const wantFields = new Set(def.fields({}).map((f) => f.name));
      wantFields.delete('id');
      const missing = [...wantFields].filter((n) => !haveFields.has(n));
      if (missing.length) {
        log(`repair   ${def.name}  (missing: ${missing.join(', ')})`);
        // PATCH with the full field set (PB PATCH replaces the list).
        const fieldsForPatch = def.fields(ids);
        await A(`/api/collections/${meta.id}`, {
          method: 'PATCH',
          body: JSON.stringify({ fields: fieldsForPatch }),
        });
      }
    }
  }

  // 2. Create missing in declaration order (relTargets guarantees ordering)
  for (const def of DEFS) {
    if (ids[def.name]) {
      log(`exists   ${def.name}`);
      continue;
    }
    for (const t of def.relTargets) {
      if (!ids[t]) throw new Error(`Refusing to create ${def.name}: ${t} not yet created.`);
    }
    ids[def.name] = await createCollection(def, ids);
  }

  // 3. Re-apply rules everywhere
  for (const def of DEFS) {
    await applyRules(def.name);
  }

  log('done.');
  log('collections:');
  for (const def of DEFS) {
    const id = ids[def.name];
    const meta = await A(`/api/collections/${def.name}`);
    const fieldCount = (meta.fields || []).length;
    const indexCount = (meta.indexes || []).length;
    log(`  - ${def.name.padEnd(24)} ${id}  (${fieldCount} fields, ${indexCount} indexes)`);
  }
}

main().catch((e) => {
  console.error('bootstrap failed:', e.message);
  if (e.body) console.error(JSON.stringify(e.body, null, 2));
  process.exit(1);
});
