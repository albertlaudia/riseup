import type { Author } from '@/lib/types';
import Link from 'next/link';

export function AuthorMark({ author, size = 'sm' }: { author?: Author | null; size?: 'sm' | 'md' }) {
  if (!author) return null;
  const sz = size === 'sm' ? 'text-xs' : 'text-sm';
  return (
    <Link
      href={`/library?author=${author.slug}`}
      className={`inline-flex items-center gap-2 italic text-ink-mute hover:text-ink ${sz}`}
    >
      <span aria-hidden className="h-1 w-1 rounded-full bg-ink-mute" />
      <span>{author.name}</span>
    </Link>
  );
}
