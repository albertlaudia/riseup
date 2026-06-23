'use client';

import { useMemo } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import type { Author, Category, Lesson } from '@/lib/types';
import { LessonCard } from '@/components/LessonCard';

interface Props {
  lessons: Lesson[];
  authors: Author[];
  categories: Category[];
}

export function LibraryClient({ lessons, authors, categories }: Props) {
  const params = useSearchParams();
  const activeTheme = params.get('theme');
  const activeAuthor = params.get('author');
  const activeDifficulty = params.get('difficulty');

  const authorMap = useMemo(() => new Map(authors.map((a) => [a.id, a])), [authors]);
  const categoryMap = useMemo(() => new Map(categories.map((c) => [c.id, c])), [categories]);
  const categoryBySlug = useMemo(() => new Map(categories.map((c) => [c.slug, c])), [categories]);
  const authorBySlug = useMemo(() => new Map(authors.map((a) => [a.slug, a])), [authors]);

  let visible = lessons;
  if (activeTheme) {
    const cat = categoryBySlug.get(activeTheme);
    if (cat) visible = visible.filter((l) => l.theme === cat.id);
  }
  if (activeAuthor) {
    const a = authorBySlug.get(activeAuthor);
    if (a) visible = visible.filter((l) => l.author === a.id);
  }
  if (activeDifficulty) {
    visible = visible.filter((l) => l.difficulty === activeDifficulty);
  }

  const byDifficulty = {
    beginner: visible.filter((l) => l.difficulty === 'beginner'),
    intermediate: visible.filter((l) => l.difficulty === 'intermediate'),
    advanced: visible.filter((l) => l.difficulty === 'advanced'),
  };

  // Build hrefs that preserve existing filters when adding/removing one.
  const buildHref = (key: 'theme' | 'author' | 'difficulty', value: string | null) => {
    const next = new URLSearchParams(params.toString());
    if (value === null) next.delete(key);
    else next.set(key, value);
    const s = next.toString();
    return s ? `/library?${s}` : '/library';
  };

  return (
    <div className="mx-auto max-w-6xl px-5 py-10 sm:py-14">
      <header className="mb-10">
        <h1 className="font-display text-4xl font-medium text-ink sm:text-5xl">The library</h1>
        <p className="mt-3 max-w-2xl text-ink-soft">
          {visible.length} {visible.length === 1 ? 'lesson' : 'lessons'}
          {activeTheme && categoryBySlug.get(activeTheme) ? ` in ${categoryBySlug.get(activeTheme)!.name}` : ''}
          {activeAuthor && authorBySlug.get(activeAuthor) ? ` by ${authorBySlug.get(activeAuthor)!.name}` : ''}
          {activeDifficulty ? ` · ${activeDifficulty}` : ''}.
        </p>
      </header>

      {/* Filters */}
      <div className="mb-8 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-semibold uppercase tracking-wider text-ink-mute">Theme</span>
          <Link
            href={buildHref('theme', null)}
            className={[
              'rounded-full px-3 py-1 text-sm transition-colors',
              !activeTheme ? 'bg-ink text-paper' : 'bg-paper-warm/80 text-ink-soft hover:bg-paper-warm',
            ].join(' ')}
          >
            All
          </Link>
          {categories.map((c) => (
            <Link
              key={c.id}
              href={buildHref('theme', c.slug)}
              className={[
                'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-sm transition-colors',
                activeTheme === c.slug
                  ? 'bg-ink text-paper'
                  : 'bg-paper-warm/80 text-ink-soft hover:bg-paper-warm',
              ].join(' ')}
              style={activeTheme === c.slug ? undefined : { color: c.color || undefined }}
            >
              <span aria-hidden>{c.icon}</span>
              <span>{c.name}</span>
            </Link>
          ))}
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-semibold uppercase tracking-wider text-ink-mute">Author</span>
          <Link
            href={buildHref('author', null)}
            className={[
              'rounded-full px-3 py-1 text-sm transition-colors',
              !activeAuthor ? 'bg-ink text-paper' : 'bg-paper-warm/80 text-ink-soft hover:bg-paper-warm',
            ].join(' ')}
          >
            All
          </Link>
          {authors.map((a) => (
            <Link
              key={a.id}
              href={buildHref('author', a.slug)}
              className={[
                'rounded-full px-3 py-1 text-sm transition-colors',
                activeAuthor === a.slug
                  ? 'bg-ink text-paper'
                  : 'bg-paper-warm/80 text-ink-soft hover:bg-paper-warm',
              ].join(' ')}
            >
              {a.name}
            </Link>
          ))}
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-semibold uppercase tracking-wider text-ink-mute">Difficulty</span>
          {['all', 'beginner', 'intermediate', 'advanced'].map((d) => (
            <Link
              key={d}
              href={d === 'all' ? buildHref('difficulty', null) : buildHref('difficulty', d)}
              className={[
                'rounded-full px-3 py-1 text-sm capitalize transition-colors',
                (d === 'all' && !activeDifficulty) || activeDifficulty === d
                  ? 'bg-ink text-paper'
                  : 'bg-paper-warm/80 text-ink-soft hover:bg-paper-warm',
              ].join(' ')}
            >
              {d}
            </Link>
          ))}
        </div>
      </div>

      <div className="space-y-12">
        {(['beginner', 'intermediate', 'advanced'] as const).map((level) =>
          byDifficulty[level].length > 0 ? (
            <section key={level}>
              <h2 className="mb-4 font-display text-xl font-semibold capitalize text-ink">
                {level} <span className="text-sm font-normal text-ink-mute">({byDifficulty[level].length})</span>
              </h2>
              <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
                {byDifficulty[level].map((l) => (
                  <LessonCard
                    key={l.id}
                    lesson={l}
                    author={typeof l.author === 'string' ? authorMap.get(l.author) || null : l.author}
                    theme={typeof l.theme === 'string' ? categoryMap.get(l.theme) || null : l.theme}
                  />
                ))}
              </div>
            </section>
          ) : null,
        )}
        {visible.length === 0 && (
          <div className="rounded-2xl border border-ink/5 bg-paper-card p-10 text-center text-ink-mute">
            No lessons match this filter.
          </div>
        )}
      </div>
    </div>
  );
}
