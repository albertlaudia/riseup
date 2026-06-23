export const metadata = { title: 'About — RiseUP' };

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-reading px-5 py-12 sm:py-16">
      <header className="mb-10">
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-ink-mute">About</p>
        <h1 className="mt-2 font-display text-4xl font-medium text-ink sm:text-5xl">Why RiseUP exists</h1>
      </header>

      <div className="space-y-5 text-lg leading-relaxed text-ink-soft">
        <p>
          <em className="font-display text-2xl text-ink">RiseUP</em> is a daily Stoic practice app. A short lesson
          in the morning. A quote to carry through the day. A streak that doesn&apos;t care about your mood.
        </p>
        <p>
          It is built on a simple premise: most of what we call <em>motivation</em> is really just
          <em> attention</em>. Pay attention, on purpose, to the right things, for thirty seconds a day,
          and the rest of the day behaves differently.
        </p>
        <p>
          We took the core practices of the ancient Stoics — Marcus Aurelius, Seneca, Epictetus,
          Musonius Rufus — and a few thoughtful modern voices, and we made a small, deliberately unflashy
          app for doing them.
        </p>
      </div>

      <hr className="my-10 border-ink/10" />

      <h2 className="font-display text-2xl font-medium text-ink">What&apos;s inside</h2>
      <ul className="mt-4 list-disc space-y-2 pl-6 text-ink-soft">
        <li><strong className="text-ink">15 lessons</strong> across 8 themes — Dichotomy of Control, Memento Mori, Perspective, Resilience, Discipline, Mindfulness, Amor Fati, and Virtue.</li>
        <li><strong className="text-ink">53 quotes</strong> from Marcus, Seneca, Epictetus, Musonius, Ryan Holiday, and William Irvine.</li>
        <li><strong className="text-ink">12 achievements</strong> for streaks, lessons, themes explored, and favorites.</li>
        <li><strong className="text-ink">Daily lesson + daily quote</strong> that change every day, deterministically.</li>
      </ul>

      <h2 className="mt-10 font-display text-2xl font-medium text-ink">How it&apos;s built</h2>
      <p className="mt-3 text-ink-soft">
        RiseUP is a Next.js 15 web app reading from a PocketBase backend. All static content
        (authors, works, lessons, quotes, achievements) lives in the <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-sm">rup_*</code> collection family.
        User-scoped data (XP, streaks, favorites, settings) lives in user-scoped collections
        with rules that match records to the signed-in Firebase user.
      </p>

      <h2 className="mt-10 font-display text-2xl font-medium text-ink">What comes next</h2>
      <p className="mt-3 text-ink-soft">
        The public, unauthenticated surface (lessons, quotes, library, quotes wall) is fully live.
        To enable auth, XP, and streaks:
      </p>
      <ol className="mt-3 list-decimal space-y-2 pl-6 text-ink-soft">
        <li>Set up a Firebase project and add the web SDK to <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-sm">web/</code>.</li>
        <li>Verify the Firebase ID token on the server (via REST) and look up / create the matching <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-sm">rup_users</code> row.</li>
        <li>Use the <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-sm">firebase_uid</code> as the link between auth and PB records.</li>
        <li>Mark lessons complete by writing a <code className="rounded bg-paper-warm px-1.5 py-0.5 font-mono text-sm">rup_user_progress</code> row (PB will increment XP and update the streak on insert).</li>
      </ol>

      <h2 className="mt-10 font-display text-2xl font-medium text-ink">A small request</h2>
      <p className="mt-3 text-ink-soft">
        Use it for thirty days. Do the morning page. Read the lesson. Carry the quote. Notice whether
        the practice — not the app, the <em>practice</em> — is doing anything. The rest will take care of itself.
      </p>
    </div>
  );
}
