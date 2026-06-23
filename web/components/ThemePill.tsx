import Link from 'next/link';
import type { Category } from '@/lib/types';

export function ThemePill({ category, size = 'md' }: { category: Category; size?: 'sm' | 'md' }) {
  const sz = size === 'sm' ? 'text-xs px-2.5 py-0.5' : 'text-sm px-3 py-1';
  return (
    <Link
      href={`/library?theme=${category.slug}`}
      className={`inline-flex items-center gap-1.5 rounded-full bg-paper-warm/80 font-medium text-ink-soft transition-colors hover:bg-paper-warm ${sz}`}
      style={{ color: category.color || undefined }}
    >
      <span aria-hidden>{category.icon || '✦'}</span>
      <span>{category.name}</span>
    </Link>
  );
}
