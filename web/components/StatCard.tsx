export function StatCard({
  label,
  value,
  icon,
  hint,
}: {
  label: string;
  value: string | number;
  icon?: string;
  hint?: string;
}) {
  return (
    <div className="rounded-2xl border border-ink/5 bg-paper-card p-5 shadow-soft">
      <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-ink-mute">
        {icon && <span aria-hidden>{icon}</span>}
        <span>{label}</span>
      </div>
      <div className="mt-3 font-display text-3xl font-semibold text-ink">{value}</div>
      {hint && <p className="mt-1 text-xs text-ink-mute">{hint}</p>}
    </div>
  );
}
