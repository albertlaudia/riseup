import Link from 'next/link';
import { getAuthors, getCategories, getQuotes } from '@/lib/pb';
import { QuoteCard } from '@/components/QuoteCard';

export const revalidate = 300;
export const dynamic = 'force-static';
export const metadata = { title: 'Quotes — RiseUP' };

export default async function QuotesPage() {
  const [quotes, authors, categories] = await Promise.all([
    getQuotes(),
    getAuthors(),
    getCategories(),
  ]);
  const authorMap = new Map(authors.map((a) => [a.id, a]));
  const categoryMap = new Map(categories.map((c) => [c.id, c]));

  const featured = quotes.filter((q) => q.is_featured);
  const rest = quotes.filter((q) => !q.is_featured);

  return (
    <div className="mx-auto max-w-6xl px-5 py-10 sm:py-14">
      <header className="mb-10">
        <h1 className="font-display text-4xl font-medium text-ink sm:text-5xl">Quotes</h1>
        <p className="mt-3 max-w-2xl text-ink-soft">
          {quotes.length} passages from the Stoics and a few modern voices. Read one in the morning. Carry one all day.
        </p>
      </header>

      {/* Theme filter */}
      <div className="mb-10 flex flex-wrap items-center gap-2">
        <span className="text-xs font-semibold uppercase tracking-wider text-ink-mute">Filter by theme</span>
        {categories.map((c) => (
          <Link
            key={c.id}
            href={`#${c.slug}`}
            className="inline-flex items-center gap-1.5 rounded-full bg-paper-warm/80 px-3 py-1 text-sm text-ink-soft hover:bg-paper-warm"
            style={{ color: c.color || undefined }}
          >
            <span aria-hidden>{c.icon}</span>
            <span>{c.name}</span>
          </Link>
        ))}
      </div>

      {/* Featured */}
      {featured.length > 0 && (
        <section className="mb-14">
          <h2 className="mb-5 font-display text-2xl font-medium text-ink">Featured</h2>
          <div className="grid gap-5 md:grid-cols-2">
            {featured.map((q) => (
              <QuoteCard
                key={q.id}
                quote={q}
                author={typeof q.author === 'string' ? authorMap.get(q.author) || null : q.author}
                theme={typeof q.theme === 'string' ? categoryMap.get(q.theme) || null : q.theme}
              />
            ))}
          </div>
        </section>
      )}

      {/* Group by theme */}
      {categories.map((c) => {
        const inCat = rest.filter((q) => {
          const t = typeof q.theme === 'string' ? q.theme : q.theme?.id;
          return t === c.id;
        });
        if (inCat.length === 0) return null;
        return (
          <section key={c.id} id={c.slug} className="mb-14 scroll-mt-24">
            <div className="mb-5 flex items-center gap-3">
              <span
                className="grid h-9 w-9 place-items-center rounded-full text-lg"
                style={{ backgroundColor: `${c.color}22`, color: c.color || undefined }}
                aria-hidden
              >
                {c.icon}
              </span>
              <h2 className="font-display text-2xl font-medium text-ink">{c.name}</h2>
              <span className="text-sm text-ink-mute">({inCat.length})</span>
            </div>
            <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-3">
              {inCat.map((q) => (
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
        );
      })}
    </div>
  );
}
