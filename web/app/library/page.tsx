import { getAuthors, getCategories, getLessons } from '@/lib/pb';
import { LibraryClient } from './library-client';

export const metadata = { title: 'Library — RiseUP' };
export const dynamic = 'force-static';

// Fully static: render the full library, then let the client filter via URL params.
export default async function LibraryPage() {
  const [authors, categories, lessons] = await Promise.all([
    getAuthors(),
    getCategories(),
    getLessons(),
  ]);
  return <LibraryClient lessons={lessons} authors={authors} categories={categories} />;
}
