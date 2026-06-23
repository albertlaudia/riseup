// PocketBase data helpers — read-only on the public `rup_*` content collections.

import type { Author, Category, Lesson, Quote, Achievement, Work } from './types';

const PB_URL =
  process.env.NEXT_PUBLIC_PB_URL || 'https://pocketbase.scaleupcrm.com';

const authToken = process.env.PB_AUTH_TOKEN; // optional superuser token (build-time only)

async function pbGet<T>(path: string): Promise<T> {
  const res = await fetch(`${PB_URL}${path}`, {
    headers: authToken ? { Authorization: authToken } : {},
    // Cache aggressively on the server; client-side fetches are dynamic.
    next: { revalidate: 60 },
  });
  if (!res.ok) {
    throw new Error(`PB ${res.status} ${path}: ${await res.text()}`);
  }
  return res.json() as Promise<T>;
}

interface ListResp<T> {
  items: T[];
  page: number;
  perPage: number;
  totalItems: number;
}

async function pbList<T>(collection: string, query = ''): Promise<T[]> {
  // PB caps perPage at 500; we keep seed sizes small.
  const url = `/api/collections/${collection}/records?perPage=500&${query}`;
  const r = await pbGet<ListResp<T>>(url);
  return r.items;
}

// ---------- authors ----------
export const getAuthors = () => pbList<Author>('rup_authors', 'sort=order,name');

// ---------- categories ----------
export const getCategories = () => pbList<Category>('rup_categories', 'sort=order,name');

// ---------- works ----------
export const getWorks = () => pbList<Work>('rup_works', 'sort=year,title');

// ---------- quotes ----------
export const getQuotes = (filter?: string) =>
  pbList<Quote>('rup_quotes', `sort=-is_featured,text${filter ? `&filter=${encodeURIComponent(filter)}` : ''}`);

export const getFeaturedQuotes = () =>
  pbList<Quote>('rup_quotes', 'filter=is_featured=true&sort=text');

// ---------- lessons ----------
export const getLessons = (filter?: string) =>
  pbList<Lesson>('rup_lessons', `sort=order,title${filter ? `&filter=${encodeURIComponent(filter)}` : ''}`);

export const getFeaturedLessons = () =>
  pbList<Lesson>('rup_lessons', 'filter=is_featured=true&sort=order');

export async function getLessonBySlug(slug: string): Promise<Lesson | null> {
  const items = await pbList<Lesson>('rup_lessons', `filter=slug="${slug}"&perPage=1`);
  return items[0] ?? null;
}

// ---------- achievements ----------
export const getAchievements = () => pbList<Achievement>('rup_achievements', 'sort=order');

// ---------- helpers ----------
/** Returns a deterministic, content-based "lesson of the day" index. */
export function pickDailyLesson(lessons: Lesson[]): Lesson | null {
  if (!lessons.length) return null;
  const start = new Date(2024, 0, 1).getTime();
  const day = Math.floor((Date.now() - start) / 86_400_000);
  return lessons[day % lessons.length];
}

export function pickDailyQuote(quotes: Quote[]): Quote | null {
  if (!quotes.length) return null;
  const start = new Date(2024, 0, 1).getTime();
  const day = Math.floor((Date.now() - start) / 86_400_000);
  return quotes[day % quotes.length];
}

/** Resolve a relation id to a real object via a lookup map. */
export function resolve<T extends { id: string }>(ref: string | T | undefined, map: Map<string, T>): T | null {
  if (!ref) return null;
  if (typeof ref === 'string') return map.get(ref) ?? null;
  return ref;
}
