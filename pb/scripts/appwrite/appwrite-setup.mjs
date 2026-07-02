#!/usr/bin/env node
/**
 * RiseUP — Appwrite setup
 *
 * Creates the user-data side of the app:
 *   • Database:   riseup
 *   • Collections: user_progress, user_achievements, user_favorites,
 *                  user_subscriptions, user_settings
 *   • Attributes, indexes, and permissions
 *
 * PB handles static content. Appwrite handles EVERYTHING per-user.
 *
 * Usage:
 *   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
 *   APPWRITE_PROJECT_ID=...
 *   APPWRITE_API_KEY=...           # server key with databases.write, users.read
 *   node appwrite-setup.mjs
 *
 * Idempotent: re-running skips collections/attributes/indexes that already exist.
 */

import {
  Client,
  Databases,
  IndexType,
  Permission,
  Role,
  ID,
} from 'node-appwrite';

const ENDPOINT = process.env.APPWRITE_ENDPOINT || 'https://cloud.appwrite.io/v1';
const PROJECT_ID = process.env.APPWRITE_PROJECT_ID;
const API_KEY = process.env.APPWRITE_API_KEY;
const DATABASE_ID = process.env.APPWRITE_DATABASE_ID || 'riseup';

if (!PROJECT_ID || !API_KEY) {
  console.error('Missing APPWRITE_PROJECT_ID or APPWRITE_API_KEY env var.');
  console.error('Create a project at https://cloud.appwrite.io, then:');
  console.error('  1. Settings → API Keys → Create key with scopes:');
  console.error('     databases.write, collections.write, attributes.write, indexes.write, documents.write');
  console.error('  2. Set the env vars and re-run.');
  process.exit(1);
}

const log = (...a) => console.log('[appwrite]', ...a);

// ---------- client ----------
const client = new Client();
client.setEndpoint(ENDPOINT).setProject(PROJECT_ID).setKey(API_KEY);
const db = new Databases(client);

// ---------- helpers ----------
async function ensureDatabase() {
  try {
    await db.get({ databaseId: DATABASE_ID });
    log(`exists   database ${DATABASE_ID}`);
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.create({ databaseId: DATABASE_ID, name: 'RiseUP' });
    log(`created  database ${DATABASE_ID}`);
  }
}

async function ensureCollection(id, name) {
  try {
    const r = await db.getCollection({ databaseId: DATABASE_ID, collectionId: id });
    log(`exists   collection ${id}`);
    return r;
  } catch (e) {
    if (e.code !== 404) throw e;
    const r = await db.createCollection({
      databaseId: DATABASE_ID,
      collectionId: id,
      name,
      // Only the document owner can read/write. Anonymous can't access.
      permissions: [],
      documentSecurity: true,
    });
    log(`created  collection ${id}`);
    return r;
  }
}

async function ensureAttrString(colId, key, { size = 255, required = false, default_ = null } = {}) {
  try {
    await db.getAttribute({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createStringAttribute({ databaseId: DATABASE_ID, collectionId: colId, key, size, required, default: default_ });
    log(`+attr    ${colId}.${key} (string)`);
  }
}
async function ensureAttrEmail(colId, key, { required = false } = {}) {
  try {
    await db.getAttribute({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createEmailAttribute({ databaseId: DATABASE_ID, collectionId: colId, key, required });
    log(`+attr    ${colId}.${key} (email)`);
  }
}
async function ensureAttrBool(colId, key, { required = false, default_ = null } = {}) {
  try {
    await db.getAttribute({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createBooleanAttribute({ databaseId: DATABASE_ID, collectionId: colId, key, required, default: default_ });
    log(`+attr    ${colId}.${key} (bool)`);
  }
}
async function ensureAttrInt(colId, key, { required = false, default_ = null, min = null, max = null } = {}) {
  try {
    await db.getAttribute({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createIntegerAttribute({ databaseId: DATABASE_ID, collectionId: colId, key, required, default: default_, min, max });
    log(`+attr    ${colId}.${key} (int)`);
  }
}
async function ensureAttrDateTime(colId, key, { required = false } = {}) {
  try {
    await db.getAttribute({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createDatetimeAttribute({ databaseId: DATABASE_ID, collectionId: colId, key, required });
    log(`+attr    ${colId}.${key} (datetime)`);
  }
}

async function ensureIndex(colId, key, type, attrs) {
  try {
    await db.getIndex({ databaseId: DATABASE_ID, collectionId: colId, key });
  } catch (e) {
    if (e.code !== 404) throw e;
    await db.createIndex({ databaseId: DATABASE_ID, collectionId: colId, key, type, attributes: attrs });
    log(`+index   ${colId}.${key}`);
  }
}

// ---------- collections ----------
// Note: Appwrite auth is on the `users` collection. Our user-data collections
// reference the user by `userId` (a string of their Appwrite user id).

const COLLECTIONS = [
  {
    id: 'user_progress',
    name: 'User Progress',
    attrs: [
      { kind: 'str', key: 'userId', required: true, size: 64 },
      { kind: 'str', key: 'lessonSlug', required: true, size: 128 },
      { kind: 'int', key: 'xpEarned', required: false, default_: 0, min: 0, max: 100000 },
      { kind: 'dt', key: 'completedAt', required: true },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Key, attrs: ['userId'] },
      { key: 'idx_user_lesson', type: IndexType.Unique, attrs: ['userId', 'lessonSlug'] },
    ],
  },
  {
    id: 'user_achievements',
    name: 'User Achievements (unlocked)',
    attrs: [
      { kind: 'str', key: 'userId', required: true, size: 64 },
      { kind: 'str', key: 'achievementCode', required: true, size: 64 },
      { kind: 'dt', key: 'unlockedAt', required: true },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Key, attrs: ['userId'] },
      { key: 'idx_user_ach', type: IndexType.Unique, attrs: ['userId', 'achievementCode'] },
    ],
  },
  {
    id: 'user_favorites',
    name: 'User Favorites',
    attrs: [
      { kind: 'str', key: 'userId', required: true, size: 64 },
      { kind: 'str', key: 'kind', required: true, size: 16 }, // "quote" | "lesson"
      { kind: 'str', key: 'targetId', required: true, size: 64 }, // PB id or slug
      { kind: 'dt', key: 'createdAt', required: true },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Key, attrs: ['userId'] },
      { key: 'idx_user_target', type: IndexType.Unique, attrs: ['userId', 'kind', 'targetId'] },
    ],
  },
  {
    id: 'user_subscriptions',
    name: 'User Subscriptions',
    attrs: [
      { kind: 'str', key: 'userId', required: true, size: 64 },
      { kind: 'str', key: 'planCode', required: true, size: 64 },
      { kind: 'str', key: 'status', required: true, size: 32 },     // active | cancelled | expired | trial | past_due
      { kind: 'str', key: 'source', required: true, size: 32 },     // stripe | apple | google | admin | trial
      { kind: 'str', key: 'externalId', required: false, size: 255 },
      { kind: 'dt',  key: 'startedAt', required: true },
      { kind: 'dt',  key: 'expiresAt', required: false },
      { kind: 'dt',  key: 'cancelledAt', required: false },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Key, attrs: ['userId'] },
      { key: 'idx_user_status', type: IndexType.Key, attrs: ['userId', 'status'] },
    ],
  },
  {
    id: 'user_settings',
    name: 'User Settings',
    attrs: [
      { kind: 'str', key: 'userId', required: true, size: 64 },
      { kind: 'str', key: 'theme', required: false, size: 16, default_: 'auto' },     // light | dark | auto
      { kind: 'bool', key: 'notifications', required: false, default_: true },
      { kind: 'str', key: 'dailyReminderTime', required: false, size: 5 },           // "HH:MM"
      { kind: 'str', key: 'fontSize', required: false, size: 16, default_: 'medium' },// small | medium | large
      { kind: 'str', key: 'tier', required: false, size: 16, default_: 'free' },     // free | pro (cached for fast UI; subscription is the source of truth)
      { kind: 'int', key: 'streakFreezesUsed', required: false, default_: 0 },
      { kind: 'dt',  key: 'streakFreezesResetAt', required: false },
      { kind: 'str', key: 'fcmToken', required: false, size: 255 },
      { kind: 'str', key: 'fcmTokenUpdatedAt', required: false, size: 32 },
      { kind: 'bool', key: 'marketingOptIn', required: false, default_: false },
      { kind: 'str', key: 'displayName', required: false, size: 64 },
      { kind: 'int', key: 'quotesRead', required: false, default_: 0 },
      { kind: 'dt', key: 'onboardingCompletedAt', required: false },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Unique, attrs: ['userId'] },
    ],
  },
  {
    id: 'user_journal',
    name: 'User Journal (reflection entries)',
    attrs: [
      { kind: 'str',  key: 'userId', required: true, size: 64 },
      { kind: 'str',  key: 'lessonSlug', required: true, size: 128 },
      { kind: 'str',  key: 'promptText', required: true, size: 500 },
      { kind: 'str',  key: 'responseText', required: false, size: 500 },
      { kind: 'dt',   key: 'createdAt', required: true },
    ],
    indexes: [
      { key: 'idx_user', type: IndexType.Key, attrs: ['userId'] },
      { key: 'idx_user_date', type: IndexType.Key, attrs: ['userId', '-createdAt'] },
    ],
  },
];

// ---------- main ----------
async function main() {
  log(`target: ${ENDPOINT}  project: ${PROJECT_ID}`);
  await ensureDatabase();

  for (const col of COLLECTIONS) {
    await ensureCollection(col.id, col.name);

    for (const a of col.attrs) {
      switch (a.kind) {
        case 'str':  await ensureAttrString(col.id, a.key, a); break;
        case 'email': await ensureAttrEmail(col.id, a.key, a); break;
        case 'bool': await ensureAttrBool(col.id, a.key, a); break;
        case 'int':  await ensureAttrInt(col.id, a.key, a); break;
        case 'dt':   await ensureAttrDateTime(col.id, a.key, a); break;
      }
    }

    for (const ix of col.indexes) {
      await ensureIndex(col.id, ix.key, ix.type, ix.attrs);
    }

    // Per-document permissions: each row is owned by the user. The user's
    // userId is stored on the row; the Flutter app sets these when creating.
    // We do NOT set collection-level permissions — documentSecurity is on, so
    // each doc carries its own.
    //
    // Recommended per-doc permissions (set by client when creating):
    //   read:    [Role.user(userId)]
    //   write:   [Role.user(userId)]
    //   delete:  [Role.user(userId)]
    log(`         ${col.id} ready — use document-level perms on insert`);
  }

  log('done.');
  log('summary:');
  for (const col of COLLECTIONS) log(`  - ${col.id.padEnd(24)} (${col.attrs.length} attrs, ${col.indexes.length} indexes)`);
  log('');
  log('next:');
  log('  1. Enable Email/Password (and Apple/Google) auth in Appwrite Auth.');
  log('  2. In your Flutter app, set the following in .env or build --dart-define:');
  log('       APPWRITE_ENDPOINT, APPWRITE_PROJECT_ID');
  log('  3. On document create, set permissions to:');
  log('       [Permission.read(Role.user(<userId>)), Permission.write(Role.user(<userId>)), Permission.delete(Role.user(<userId>))]');
}

main().catch((e) => {
  console.error('setup failed:', e);
  if (e.response) console.error(JSON.stringify(e.response, null, 2));
  process.exit(1);
});
