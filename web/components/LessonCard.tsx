import Link from 'next/link';
import type { Lesson, Author, Category } from '@/lib/types';
import { ThemePill } from './ThemePill';
import { AuthorMark } from './AuthorMark';

export function LessonCard({
  lesson,
  author,
  theme,
  variant = 'default',
}: {
  lesson: Lesson;
  author?: Author | null;
  theme?: Category | null;
  variant?: 'default' | 'compact' | 'hero';
}) {
  if (variant === 'hero') {
    return (
      <Link
        href={`/library/${lesson.slug}`}
        className="group relative block overflow-hidden rounded-3xl border border-ink/5 bg-gradient-to-br from-paper-card via-paper-warm to-paper p-8 shadow-soft transition-shadow hover:shadow-[0_2px_4px_rgba(31,29,26,0.05),0_16px_40px_rgba(31,29,26,0.10)] sm:p-10"
      >
        <div className="flex items-center gap-3">
          {theme && <ThemePill category={theme} size="sm" />}
          <span className="inline-flex items-center gap-1 rounded-full bg-accent/10 px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-wider text-accent">
            ✦ Today
          </span>
        </div>
        <h2 className="mt-6 font-display text-3xl font-medium leading-tight text-ink sm:text-4xl md:text-5xl">
          {lesson.title}
        </h2>
        {lesson.intro && (
          <p className="mt-4 max-w-2xl text-lg leading-relaxed text-ink-soft">{lesson.intro}</p>
        )}
        <div className="mt-6 flex flex-wrap items-center gap-4 text-sm text-ink-mute">
          <AuthorMark author={author} />
          {lesson.read_time_min && (
            <span className="inline-flex items-center gap-1.5">
              <span aria-hidden>⏱</span> {lesson.read_time_min} min read
            </span>
          )}
          {lesson.difficulty && (
            <span className="capitalize">· {lesson.difficulty}</span>
          )}
        </div>
        <div className="mt-8 inline-flex items-center gap-2 text-sm font-medium text-accent group-hover:gap-3 group-hover:text-ink transition-all">
          Open the lesson
          <span aria-hidden>→</span>
        </div>
      </Link>
    );
  }

  if (variant === 'compact') {
    return (
      <Link
        href={`/library/${lesson.slug}`}
        className="group block rounded-xl border border-ink/5 bg-paper-card p-4 shadow-soft transition-all hover:border-ink/10 hover:shadow-[0_2px_4px_rgba(31,29,26,0.05),0_8px_20px_rgba(31,29,26,0.08)]"
      >
        <div className="flex items-start gap-3">
          {theme && (
            <span
              className="mt-1 inline-flex h-7 w-7 flex-none items-center justify-center rounded-full text-sm"
              style={{ backgroundColor: `${theme.color}1f` }}
              aria-hidden
            >
              {theme.icon}
            </span>
          )}
          <div className="min-w-0">
            <h3 className="truncate font-display text-base font-medium text-ink group-hover:text-accent">{lesson.title}</h3>
            <p className="mt-0.5 truncate text-xs text-ink-mute">
              {author?.name || 'Anonymous'} · {lesson.read_time_min || 4} min
            </p>
          </div>
        </div>
      </Link>
    );
  }

  return (
    <Link
      href={`/library/${lesson.slug}`}
      className="group flex h-full flex-col rounded-2xl border border-ink/5 bg-paper-card p-6 shadow-soft transition-all hover:-translate-y-0.5 hover:shadow-[0_2px_4px_rgba(31,29,26,0.05),0_12px_28px_rgba(31,29,26,0.08)]"
    >
      <div className="flex items-center gap-2">
        {theme && <ThemePill category={theme} size="sm" />}
        {lesson.difficulty && (
          <span className="rounded-full bg-ink/5 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-ink-mute">
            {lesson.difficulty}
          </span>
        )}
      </div>
      <h3 className="mt-4 font-display text-xl font-medium leading-snug text-ink group-hover:text-accent">{lesson.title}</h3>
      {lesson.intro && (
        <p className="mt-2 line-clamp-2 text-sm leading-relaxed text-ink-soft">{lesson.intro}</p>
      )}
      <div className="mt-5 flex flex-1 items-end justify-between text-xs text-ink-mute">
        <AuthorMark author={author} />
        <span>{lesson.read_time_min || 4} min</span>
      </div>
    </Link>
  );
}
