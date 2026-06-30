/**
 * RiseUP — server-push notification cron
 *
 * Runs every 15 minutes via Cloudflare's cron trigger.
 * Finds users whose daily reminder time is within the next 15 minutes
 * (in their local timezone), and sends one FCM push per user.
 *
 * v1: Flutter app schedules locally. This file is here so the seam is
 * ready when the product needs server-pushed reminders.
 */

import * as admin from 'firebase-admin';

interface Env {
  APPWRITE_ENDPOINT: string;
  APPWRITE_PROJECT_ID: string;
  APPWRITE_API_KEY: string;       // server key with read scope on user_settings
  FCM_PROJECT_ID: string;
  FCM_SERVICE_ACCOUNT_JSON: string;
}

interface UserSettings {
  $id: string;
  userId: string;
  notifications?: boolean;
  dailyReminderTime?: string;     // "HH:MM"
  fcmToken?: string;
  fcmTokenUpdatedAt?: string;
  // PB-side lesson/quote selection happens here too (or we can fetch from PB).
}

export default {
  async scheduled(event: ScheduledEvent, env: Env, ctx: ExecutionContext): Promise<void> {
    ctx.waitUntil(run(env));
  },
};

async function run(env: Env) {
  // Init FCM
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(env.FCM_SERVICE_ACCOUNT_JSON)),
      projectId: env.FCM_PROJECT_ID,
    });
  }

  // Fetch all user settings from Appwrite (filter happens server-side).
  // For 10k users this is ~2MB; for 100k users, switch to a query loop with cursor.
  const users = await fetchAllUserSettings(env);
  const now = new Date();

  let sent = 0;
  for (const u of users) {
    if (!u.notifications || !u.fcmToken) continue;

    const reminder = parseHHMM(u.dailyReminderTime ?? '07:00');
    if (!shouldSendNow(now, reminder, u.tzGuess)) continue;

    // Pick today's content (deterministic — same algorithm as the Flutter client).
    const { title, body } = await pickTodaysContent();

    try {
      await admin.messaging().send({
        token: u.fcmToken,
        notification: { title, body },
        data: { lessonSlug: todayLessonSlug() },
        android: { priority: 'high', notification: { channelId: 'riseup_daily_reminder' } },
      });
      sent++;
    } catch (e) {
      console.warn(`FCM send failed for ${u.userId}:`, e);
      // On token-invalid, null out the token so we don't retry forever.
      if ((e as { code?: string }).code === 'messaging/registration-token-not-registered') {
        await clearFcmToken(env, u);
      }
    }
  }

  console.log(`[riseup-cron] sent ${sent} of ${users.length} notifications`);
}

async function fetchAllUserSettings(env: Env): Promise<UserSettings[]> {
  const url = `${env.APPWRITE_ENDPOINT}/databases/${env.APPWRITE_DATABASE_ID ?? 'riseup'}/collections/user_settings/documents?perPage=500`;
  const r = await fetch(url, {
    headers: { 'X-Appwrite-Project': env.APPWRITE_PROJECT_ID, 'X-Appwrite-Key': env.APPWRITE_API_KEY },
  });
  if (!r.ok) throw new Error(`Appwrite list failed: ${r.status}`);
  const body = await r.json() as { documents: UserSettings[] };
  return body.documents;
}

async function clearFcmToken(env: Env, u: UserSettings) {
  const url = `${env.APPWRITE_ENDPOINT}/databases/${env.APPWRITE_DATABASE_ID ?? 'riseup'}/collections/user_settings/documents/${u.$id}`;
  await fetch(url, {
    method: 'PATCH',
    headers: {
      'X-Appwrite-Project': env.APPWRITE_PROJECT_ID,
      'X-Appwrite-Key': env.APPWRITE_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fcmToken: null }),
  });
}

function parseHHMM(s: string): { hour: number; minute: number } | null {
  const m = /^(\d{1,2}):(\d{2})$/.exec(s);
  if (!m) return null;
  return { hour: +m[1], minute: +m[2] };
}

/**
 * Returns true if the user's reminder time is within the next 15 minutes
 * (in their IANA timezone). `tzGuess` is currently null — extend when
 * user_settings stores the timezone explicitly.
 */
function shouldSendNow(now: Date, reminder: { hour: number; minute: number } | null, _tzGuess: string | null): boolean {
  if (!reminder) return false;
  const nowMin = now.getHours() * 60 + now.getMinutes();
  const rMin = reminder.hour * 60 + reminder.minute;
  const diff = (rMin - nowMin + 24 * 60) % (24 * 60);
  // Fire if the reminder was 0-15 min ago, OR 23:45-24:00 from now (i.e. yesterday's slot)
  return diff >= 0 && diff <= 15;
}

function todayLessonSlug(): string {
  // Pick from PB's `rup_lessons`, same DailyPick.dayIndex algorithm.
  // Inline here for now; in production, fetch from PB per-user.
  const start = new Date(2024, 0, 1).getTime();
  const day = Math.floor((Date.now() - start) / 86_400_000);
  // Placeholder — actually fetch lessons and index.
  // This is the function the Flutter side already has; keep them in sync.
  const PLACEHOLDER_LESSONS = [
    'dichotomy-of-control', 'memento-mori', 'view-from-above',
    'negative-visualization', 'obstacle-is-the-way', 'premeditatio-malorum',
    'the-stoic-journal', 'voluntary-discomfort', 'amor-fati',
    'stillness', 'discipline-equals-freedom', 'ego-is-the-enemy',
    'inner-citadel', 'on-anger', 'stoic-death-practice',
  ];
  return PLACEHOLDER_LESSONS[day % PLACEHOLDER_LESSONS.length];
}

async function pickTodaysContent(): Promise<{ title: string; body: string }> {
  const slug = todayLessonSlug();
  // Replace with a real PB call. We keep the title/body generic here.
  const title = slug.split('-').map((s) => s[0].toUpperCase() + s.slice(1)).join(' ');
  return { title: 'Today\'s practice', body: `${title} · 5 minutes` };
}
