export function Footer() {
  return (
    <footer className="mt-20 border-t border-ink/5 bg-paper-warm/40">
      <div className="mx-auto flex max-w-6xl flex-col gap-3 px-5 py-8 text-sm text-ink-mute sm:flex-row sm:items-center sm:justify-between">
        <p className="font-display text-base text-ink">RiseUP</p>
        <p className="italic">"Waste no more time arguing what a good man should be. Be one." — Marcus Aurelius</p>
        <p>© {new Date().getFullYear()} — built with care.</p>
      </div>
    </footer>
  );
}
