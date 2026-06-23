import { getAchievements } from '@/lib/pb';
import { AchievementBadge } from '@/components/AchievementBadge';
import { StatCard } from '@/components/StatCard';
import { StreakFlame } from '@/components/StreakFlame';
import Link from 'next/link';

export const revalidate = 600;
export const dynamic = 'force-static';
export const metadata = { title: 'Profile — RiseUP' };

// Demo profile state. When Firebase auth is wired, this is replaced by
// server-fetched `rup_users` data for the signed-in user.
const DEMO = {
  display_name: 'You',
  xp: 240,
  level: 3,
  streak_current: 7,
  streak_longest: 14,
  total_lessons: 12,
  total_quotes_read: 23,
};

export default async function ProfilePage() {
  const achievements = await getAchievements();

  // Derive unlocked state from the demo metrics. Real version compares against
  // the actual `rup_users` + `rup_user_progress` records.
  const conditions: Record<string, number> = {
    first_step: DEMO.total_lessons,
    quote_curious: DEMO.total_quotes_read,
    week_warrior: DEMO.streak_current,
    month_master: DEMO.streak_current,
    scholar: DEMO.total_lessons,
    sage: DEMO.total_lessons,
    stoic_scholar: DEMO.total_lessons,
    explorer: 3, // demo: 3 themes touched
    philosopher: 3,
    collector: 5,
    century: DEMO.streak_current,
    devoted: DEMO.streak_current,
  };

  return (
    <div className="mx-auto max-w-5xl px-5 py-10 sm:py-14">
      <header className="mb-10 flex flex-wrap items-end justify-between gap-6">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-ink-mute">Profile</p>
          <h1 className="mt-2 font-display text-4xl font-medium text-ink sm:text-5xl">{DEMO.display_name}</h1>
          <p className="mt-3 text-ink-soft">The practice, in numbers.</p>
        </div>
        <StreakFlame days={DEMO.streak_current} />
      </header>

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard label="Level" value={DEMO.level} icon="🌿" hint={`${DEMO.xp} XP earned`} />
        <StatCard label="Lessons" value={DEMO.total_lessons} icon="📖" />
        <StatCard label="Quotes read" value={DEMO.total_quotes_read} icon="📜" />
        <StatCard label="Longest streak" value={`${DEMO.streak_longest} d`} icon="🏔️" />
      </section>

      <section className="mt-14">
        <div className="mb-6 flex items-end justify-between">
          <h2 className="font-display text-2xl font-medium text-ink">Achievements</h2>
          <p className="text-sm text-ink-mute">Unlocked as you practice.</p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {achievements.map((a) => {
            const value = conditions[a.code] ?? 0;
            const target = a.condition_value ?? 1;
            const unlocked = value >= target;
            const progress = unlocked ? 1 : target ? value / target : 0;
            return (
              <AchievementBadge
                key={a.id}
                achievement={a}
                unlocked={unlocked}
                progress={progress}
              />
            );
          })}
        </div>
      </section>

      <section className="mt-14 rounded-2xl border border-ink/5 bg-paper-warm/50 p-6 text-sm leading-relaxed text-ink-soft">
        <p>
          <strong className="font-semibold text-ink">Heads up:</strong> this profile is showing a demo state. Wire up Firebase auth in the web app
          and hook the <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-xs">rup_users</code> +{' '}
          <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-xs">rup_user_progress</code> collections to switch to real data.
          The schema is ready.
        </p>
        <p className="mt-3">
          <Link href="/about" className="text-accent hover:underline">How auth + XP will work →</Link>
        </p>
      </section>
    </div>
  );
}
