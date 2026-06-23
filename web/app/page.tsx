import Link from 'next/link';
import {
  getAuthors,
  getCategories,
  getFeaturedLessons,
  getFeaturedQuotes,
  getLessons,
  pickDailyLesson,
  pickDailyQuote,
} from '@/lib/pb';
import { LessonCard } from '@/components/LessonCard';
import { QuoteCard } from '@/components/QuoteCard';
import { StreakFlame } from '@/components/StreakFlame';

export const revalidate = 300;
export const dynamic = 'force-static';

export default async function Home() {
  const [authors, categories, featuredLessons, lessons, featuredQuotes] = await Promise.all([
    getAuthors(),
    getCategories(),
    getFeaturedLessons(),
    getLessons(),
    getFeaturedQuotes(),
  ]);

  const authorMap = new Map(authors.map((a) => [a.id, a]));
  const categoryMap = new Map(categories.map((c) => [c.id, c]));

  const daily = pickDailyLesson(featuredLessons.length ? featuredLessons : lessons) || lessons[0] || null;
  const dailyQuote = pickDailyQuote(featuredQuotes) || featuredQuotes[0] || null;

  const recent = lessons.filter((l) => l.id !== daily?.id).slice(0, 6);
  const recentQuotes = featuredQuotes.filter((q) => q.id !== dailyQuote?.id).slice(0, 3);

  return (
    <div className="mx-auto max-w-6xl px-5 py-10 sm:py-14">
      {/* Hero */}
      <section className="grid gap-6 md:grid-cols-[2fr,1fr] md:gap-8">
        <div className="flex flex-col justify-center">
          <p className="inline-flex w-fit items-center gap-2 rounded-full border border-ink/10 bg-paper-warm/80 px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] text-ink-mute">
            <span className="h-1.5 w-1.5 rounded-full bg-accent" />
            Today, again
          </p>
          <h1 className="mt-5 font-display text-4xl font-medium leading-[1.05] text-ink sm:text-5xl md:text-6xl">
            Rise above <br className="hidden sm:block" />
            <em className="not-italic text-accent">the mood of the moment.</em>
          </h1>
          <p className="mt-5 max-w-xl text-lg leading-relaxed text-ink-soft">
            A daily lesson from the Stoics. A small, deliberate practice. A streak that doesn&apos;t care about your mood.
          </p>
          <div className="mt-7 flex flex-wrap items-center gap-4">
            <Link
              href={daily ? `/library/${daily.slug}` : '/library'}
              className="inline-flex items-center gap-2 rounded-full bg-ink px-5 py-2.5 text-sm font-medium text-paper shadow-soft transition-transform hover:-translate-y-0.5"
            >
              Open today&apos;s lesson <span aria-hidden>→</span>
            </Link>
            <Link
              href="/library"
              className="inline-flex items-center gap-2 rounded-full border border-ink/15 px-5 py-2.5 text-sm font-medium text-ink-soft hover:border-ink/30 hover:text-ink"
            >
              Browse the library
            </Link>
            <StreakFlame days={1} />
          </div>
        </div>

        {daily && (
          <div>
            <LessonCard
              lesson={daily}
              author={typeof daily.author === 'string' ? authorMap.get(daily.author) || null : daily.author}
              theme={typeof daily.theme === 'string' ? categoryMap.get(daily.theme) || null : daily.theme}
              variant="hero"
            />
          </div>
        )}
      </section>

      {/* Quote of the day */}
      {dailyQuote && (
        <section className="mt-16 sm:mt-20">
          <div className="mb-6 flex items-end justify-between">
            <h2 className="font-display text-2xl font-medium text-ink sm:text-3xl">Quote of the day</h2>
            <Link href="/quotes" className="text-sm text-ink-mute hover:text-ink">All quotes →</Link>
          </div>
          <QuoteCard
            quote={dailyQuote}
            author={typeof dailyQuote.author === 'string' ? authorMap.get(dailyQuote.author) || null : dailyQuote.author}
            theme={typeof dailyQuote.theme === 'string' ? categoryMap.get(dailyQuote.theme) || null : dailyQuote.theme}
            size="lg"
          />
        </section>
      )}

      {/* Lessons grid */}
      <section className="mt-16 sm:mt-20">
        <div className="mb-6 flex items-end justify-between">
          <div>
            <h2 className="font-display text-2xl font-medium text-ink sm:text-3xl">The library</h2>
            <p className="mt-1 text-sm text-ink-mute">Fifteen lessons across eight themes. Start anywhere.</p>
          </div>
          <Link href="/library" className="text-sm text-ink-mute hover:text-ink">All lessons →</Link>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {recent.map((lesson) => (
            <LessonCard
              key={lesson.id}
              lesson={lesson}
              author={typeof lesson.author === 'string' ? authorMap.get(lesson.author) || null : lesson.author}
              theme={typeof lesson.theme === 'string' ? categoryMap.get(lesson.theme) || null : lesson.theme}
            />
          ))}
        </div>
      </section>

      {/* Themes */}
      <section className="mt-16 sm:mt-20">
        <div className="mb-6">
          <h2 className="font-display text-2xl font-medium text-ink sm:text-3xl">Eight themes</h2>
          <p className="mt-1 text-sm text-ink-mute">Pick what the day needs.</p>
        </div>
        <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-4">
          {categories.map((c) => (
            <Link
              key={c.id}
              href={`/library?theme=${c.slug}`}
              className="group flex items-start gap-3 rounded-2xl border border-ink/5 bg-paper-card p-4 shadow-soft transition-all hover:-translate-y-0.5 hover:shadow-[0_2px_4px_rgba(31,29,26,0.05),0_12px_28px_rgba(31,29,26,0.08)]"
            >
              <span
                className="grid h-10 w-10 flex-none place-items-center rounded-full text-lg"
                style={{ backgroundColor: `${c.color}22`, color: c.color || undefined }}
                aria-hidden
              >
                {c.icon}
              </span>
              <div>
                <h3 className="font-display text-base font-semibold text-ink group-hover:text-accent">{c.name}</h3>
                {c.description && <p className="mt-0.5 line-clamp-2 text-xs text-ink-mute">{c.description}</p>}
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* More quotes */}
      {recentQuotes.length > 0 && (
        <section className="mt-16 sm:mt-20">
          <div className="mb-6 flex items-end justify-between">
            <h2 className="font-display text-2xl font-medium text-ink sm:text-3xl">More to carry with you</h2>
            <Link href="/quotes" className="text-sm text-ink-mute hover:text-ink">All quotes →</Link>
          </div>
          <div className="grid gap-5 md:grid-cols-3">
            {recentQuotes.map((q) => (
              <QuoteCard
                key={q.id}
                quote={q}
                author={typeof q.author === 'string' ? authorMap.get(q.author) || null : q.author}
                theme={typeof q.theme === 'string' ? categoryMap.get(q.theme) || null : q.theme}
                size="sm"
              />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
