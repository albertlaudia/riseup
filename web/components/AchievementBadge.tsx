import type { Achievement } from '@/lib/types';

export function AchievementBadge({
  achievement,
  unlocked,
  progress,
}: {
  achievement: Achievement;
  unlocked: boolean;
  progress?: number;
}) {
  return (
    <div
      className={[
        'relative flex h-full flex-col items-center rounded-2xl border p-5 text-center shadow-soft transition-all',
        unlocked
          ? 'border-gold/30 bg-gradient-to-br from-gold/15 via-paper-card to-paper-card'
          : 'border-ink/5 bg-paper-card/60 opacity-70 grayscale',
      ].join(' ')}
    >
      <div
        className={[
          'grid h-14 w-14 place-items-center rounded-full text-2xl',
          unlocked ? 'bg-gold/20' : 'bg-ink/5',
        ].join(' ')}
        aria-hidden
      >
        {achievement.icon}
      </div>
      <h4 className="mt-3 font-display text-base font-semibold text-ink">{achievement.title}</h4>
      <p className="mt-1 text-xs leading-relaxed text-ink-mute">{achievement.description}</p>
      {achievement.xp_reward && (
        <p className="mt-3 inline-flex items-center gap-1 rounded-full bg-ink/5 px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-ink-mute">
          +{achievement.xp_reward} XP
        </p>
      )}
      {!unlocked && typeof progress === 'number' && progress > 0 && (
        <div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-ink/5">
          <div
            className="h-full rounded-full bg-accent/60"
            style={{ width: `${Math.min(100, Math.round(progress * 100))}%` }}
          />
        </div>
      )}
    </div>
  );
}
