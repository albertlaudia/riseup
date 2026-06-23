import Link from 'next/link';

const NAV = [
  { href: '/', label: 'Today' },
  { href: '/library', label: 'Library' },
  { href: '/quotes', label: 'Quotes' },
  { href: '/profile', label: 'Profile' },
  { href: '/about', label: 'About' },
];

export function Header() {
  return (
    <header className="sticky top-0 z-30 border-b border-ink/5 bg-paper/85 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 py-3.5">
        <Link href="/" className="group flex items-center gap-2.5">
          <span className="grid h-8 w-8 place-items-center rounded-full bg-ink text-paper shadow-soft">
            <span className="font-display text-lg leading-none">R</span>
          </span>
          <span className="flex flex-col leading-none">
            <span className="font-display text-xl font-semibold tracking-tight text-ink">RiseUP</span>
            <span className="mt-0.5 text-[10px] uppercase tracking-[0.18em] text-ink-mute">Stoic practice</span>
          </span>
        </Link>
        <nav className="no-scrollbar -mx-2 flex items-center gap-1 overflow-x-auto px-2">
          {NAV.map((n) => (
            <Link
              key={n.href}
              href={n.href}
              className="rounded-full px-3.5 py-1.5 text-sm text-ink-soft transition-colors hover:bg-paper-warm hover:text-ink"
            >
              {n.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
