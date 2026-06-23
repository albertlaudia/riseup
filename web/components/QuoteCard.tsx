import type { Quote, Author, Category } from '@/lib/types';
import { ThemePill } from './ThemePill';
import { AuthorMark } from './AuthorMark';

export function QuoteCard({
  quote,
  author,
  theme,
  size = 'md',
}: {
  quote: Quote;
  author?: Author | null;
  theme?: Category | null;
  size?: 'sm' | 'md' | 'lg';
}) {
  const isLg = size === 'lg';
  const isSm = size === 'sm';
  return (
    <article
      className={[
        'group relative flex h-full flex-col rounded-2xl border border-ink/5 bg-paper-card p-6 shadow-soft transition-shadow hover:shadow-[0_2px_4px_rgba(31,29,26,0.05),0_12px_32px_rgba(31,29,26,0.08)]',
        isLg ? 'p-8' : '',
        isSm ? 'p-5' : '',
      ].join(' ')}
    >
      <span aria-hidden className="absolute -top-3 left-6 font-display text-5xl leading-none text-accent/30">“</span>
      <blockquote
        className={[
          'flex-1 font-display text-ink',
          isLg ? 'text-2xl leading-snug md:text-3xl' : isSm ? 'text-base leading-relaxed' : 'text-xl leading-snug',
        ].join(' ')}
      >
        {quote.text}
      </blockquote>
      {quote.reflection && !isSm && (
        <p className="mt-4 border-t border-ink/5 pt-4 text-sm leading-relaxed text-ink-mute">
          {quote.reflection}
        </p>
      )}
      <div className="mt-5 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          <AuthorMark author={author} />
          {theme && !isSm && <ThemePill category={theme} size="sm" />}
        </div>
        {quote.is_featured && (
          <span className="inline-flex items-center gap-1 rounded-full bg-gold/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-gold">
            Featured
          </span>
        )}
      </div>
    </article>
  );
}
