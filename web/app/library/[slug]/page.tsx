import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getAuthors, getCategories, getLessonBySlug, getLessons, getQuotes } from '@/lib/pb';
import { renderMarkdown } from '@/lib/markdown';
import { ThemePill } from '@/components/ThemePill';
import { AuthorMark } from '@/components/AuthorMark';
import { LessonCard } from '@/components/LessonCard';
import { QuoteCard } from '@/components/QuoteCard';

export const revalidate = 600;
export const dynamic = 'force-static';
export const dynamicParams = false;

export async function generateStaticParams() {
  const lessons = await getLessons();
  return lessons.map((l) => ({ slug: l.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const lesson = await getLessonBySlug(slug);
  if (!lesson) return { title: 'Lesson not found — RiseUP' };
  return {
    title: `${lesson.title} — RiseUP`,
    description: lesson.intro || lesson.key_takeaway || 'A Stoic lesson on practice.',
  };
}

export default async function LessonPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const [lesson, authors, categories, allLessons, allQuotes] = await Promise.all([
    getLessonBySlug(slug),
    getAuthors(),
    getCategories(),
    getLessons(),
    getQuotes(),
  ]);
  if (!lesson) notFound();

  const authorMap = new Map(authors.map((a) => [a.id, a]));
  const categoryMap = new Map(categories.map((c) => [c.id, c]));
  const author = typeof lesson.author === 'string' ? authorMap.get(lesson.author) || null : lesson.author;
  const theme = typeof lesson.theme === 'string' ? categoryMap.get(lesson.theme) || null : lesson.theme;

  // Quotes by the same author (or sharing the same theme) — pulled from the pool.
  const relatedQuotes = allQuotes
    .filter((q) => {
      const a = typeof q.author === 'string' ? q.author : q.author?.id;
      const t = typeof q.theme === 'string' ? q.theme : q.theme?.id;
      return (author && a === author.id) || (theme && t === theme.id);
    })
    .slice(0, 3);

  // Other lessons in the same theme.
  const moreFromTheme = allLessons
    .filter((l) => l.id !== lesson.id && l.theme && (typeof l.theme === 'string' ? l.theme === theme?.id : l.theme.id === theme?.id))
    .slice(0, 3);

  return (
    <article className="mx-auto max-w-3xl px-5 py-10 sm:py-14">
      {/* Breadcrumb */}
      <nav className="mb-8 flex items-center gap-2 text-sm text-ink-mute">
        <Link href="/library" className="hover:text-ink">Library</Link>
        <span aria-hidden>/</span>
        {theme ? (
          <>
            <Link href={`/library?theme=${theme.slug}`} className="hover:text-ink">{theme.name}</Link>
            <span aria-hidden>/</span>
          </>
        ) : null}
        <span className="text-ink">{lesson.title}</span>
      </nav>

      {/* Header */}
      <header className="mb-10">
        <div className="flex flex-wrap items-center gap-3">
          {theme && <ThemePill category={theme} />}
          {lesson.difficulty && (
            <span className="rounded-full bg-ink/5 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-ink-mute">
              {lesson.difficulty}
            </span>
          )}
          {lesson.read_time_min && (
            <span className="text-xs text-ink-mute">⏱ {lesson.read_time_min} min read</span>
          )}
        </div>
        <h1 className="mt-5 font-display text-4xl font-medium leading-tight text-ink sm:text-5xl">
          {lesson.title}
        </h1>
        {lesson.intro && (
          <p className="mt-5 text-xl leading-relaxed text-ink-soft">{lesson.intro}</p>
        )}
        <div className="mt-6">
          <AuthorMark author={author} size="md" />
        </div>
      </header>

      {/* Body */}
      <div
        className="prose-reading"
        dangerouslySetInnerHTML={{ __html: renderMarkdown(lesson.content) }}
      />

      {/* Takeaway + Action */}
      {(lesson.key_takeaway || lesson.action_step) && (
        <section className="mt-12 space-y-6">
          {lesson.key_takeaway && (
            <div className="rounded-2xl border-l-4 border-accent bg-paper-warm/60 p-5">
              <p className="text-xs font-semibold uppercase tracking-wider text-accent">Key takeaway</p>
              <p className="mt-2 font-display text-lg leading-snug text-ink">{lesson.key_takeaway}</p>
            </div>
          )}
          {lesson.action_step && (
            <div className="rounded-2xl border border-ink/5 bg-paper-card p-5 shadow-soft">
              <p className="text-xs font-semibold uppercase tracking-wider text-ink-mute">Action step</p>
              <p className="mt-2 text-base leading-relaxed text-ink-soft">{lesson.action_step}</p>
            </div>
          )}
        </section>
      )}

      {/* Related quotes */}
      {relatedQuotes.length > 0 && (
        <section className="mt-14">
          <h2 className="mb-5 font-display text-2xl font-medium text-ink">Carry these with you</h2>
          <div className="grid gap-5 md:grid-cols-3">
            {relatedQuotes.map((q) => (
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

      {/* More from theme */}
      {moreFromTheme.length > 0 && theme && (
        <section className="mt-14">
          <div className="mb-5 flex items-end justify-between">
            <h2 className="font-display text-2xl font-medium text-ink">More on {theme.name}</h2>
            <Link href={`/library?theme=${theme.slug}`} className="text-sm text-ink-mute hover:text-ink">All →</Link>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {moreFromTheme.map((l) => (
              <LessonCard
                key={l.id}
                lesson={l}
                author={typeof l.author === 'string' ? authorMap.get(l.author) || null : l.author}
                theme={typeof l.theme === 'string' ? categoryMap.get(l.theme) || null : l.theme}
              />
            ))}
          </div>
        </section>
      )}
    </article>
  );
}
