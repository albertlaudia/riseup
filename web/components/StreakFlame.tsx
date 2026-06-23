export function StreakFlame({ days }: { days: number }) {
  return (
    <div className="inline-flex items-center gap-2.5 rounded-full border border-ink/5 bg-paper-card px-4 py-2 shadow-soft">
      <span aria-hidden className="text-xl leading-none">🔥</span>
      <div className="flex flex-col leading-none">
        <span className="font-display text-lg font-semibold text-ink">{days}</span>
        <span className="mt-0.5 text-[10px] uppercase tracking-wider text-ink-mute">day streak</span>
      </div>
    </div>
  );
}
