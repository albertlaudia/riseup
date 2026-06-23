// Types — what we get back from PocketBase. Dates come as ISO strings.

export interface Author {
  id: string;
  name: string;
  slug: string;
  era?: string;
  bio?: string;
  avatar_url?: string;
  order?: number;
  created_at?: string;
}

export interface Work {
  id: string;
  author: string | Author;
  title: string;
  slug: string;
  description?: string;
  year?: number;
  cover_url?: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  icon?: string;
  color?: string;
  description?: string;
  order?: number;
}

export interface Quote {
  id: string;
  text: string;
  author?: string | Author;
  work?: string | Work;
  theme?: string | Category;
  reflection?: string;
  is_featured?: boolean;
  created_at?: string;
}

export interface Lesson {
  id: string;
  title: string;
  slug: string;
  intro?: string;
  content: string;
  key_takeaway?: string;
  action_step?: string;
  author?: string | Author;
  theme?: string | Category;
  read_time_min?: number;
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  order?: number;
  is_featured?: boolean;
  cover_url?: string;
}

export interface Achievement {
  id: string;
  code: string;
  title: string;
  description?: string;
  icon?: string;
  xp_reward?: number;
  condition_type?: 'streak' | 'lessons_completed' | 'themes_explored' | 'favorites' | 'first_lesson' | 'quote_read';
  condition_value?: number;
  order?: number;
}

export interface RupUser {
  id: string;
  firebase_uid: string;
  email?: string;
  display_name?: string;
  avatar_url?: string;
  xp?: number;
  level?: number;
  streak_current?: number;
  streak_longest?: number;
  last_active_date?: string;
  total_lessons?: number;
  total_quotes_read?: number;
  joined_at?: string;
}
