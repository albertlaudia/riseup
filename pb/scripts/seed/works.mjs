// Works — primary texts and modern popularizations.
// `author_slug` is resolved to a real PB record id by the seeder.

export const WORKS = [
  {
    author_slug: 'marcus-aurelius',
    slug: 'meditations',
    title: 'Meditations',
    year: 180,
    description: 'Twelve books of private notes on Stoic practice, written on campaign by the Roman emperor Marcus Aurelius.',
  },
  {
    author_slug: 'seneca',
    slug: 'letters-from-a-stoic',
    title: 'Letters from a Stoic',
    year: 65,
    description: 'A series of moral letters to Lucilius Junior, covering everything from wealth and friendship to death and the proper use of time.',
  },
  {
    author_slug: 'seneca',
    slug: 'on-the-shortness-of-life',
    title: 'On the Shortness of Life',
    year: 49,
    description: 'A polemical essay arguing that life is long enough — we simply waste it. One of the most quoted Stoic texts.',
  },
  {
    author_slug: 'epictetus',
    slug: 'enchiridion',
    title: 'The Enchiridion',
    year: 135,
    description: 'A short manual of Stoic ethics distilled by Arrian from Epictetus\'s lectures. Famously opens with the dichotomy of control.',
  },
  {
    author_slug: 'epictetus',
    slug: 'discourses',
    title: 'The Discourses',
    year: 108,
    description: 'Longer lectures by Epictetus, recorded by Arrian. The full backbone of his teaching on philosophy as a way of life.',
  },
  {
    author_slug: 'musonius-rufus',
    slug: 'lectures-and-fragments',
    title: 'Lectures and Fragments',
    year: 90,
    description: 'A practical syllabus of Stoic ethics, focused on how to live — diet, marriage, child-rearing, work, and exile.',
  },
  {
    author_slug: 'ryan-holiday',
    slug: 'the-daily-stoic',
    title: 'The Daily Stoic',
    year: 2016,
    description: 'A year of daily meditations, each pairing a Stoic passage with a modern reflection. The book that launched a thousand morning pages.',
  },
  {
    author_slug: 'ryan-holiday',
    slug: 'the-obstacle-is-the-way',
    title: 'The Obstacle Is the Way',
    year: 2014,
    description: 'A modern retelling of how Stoic turning-the-obstacle-into-fuel applies to creative work, business, and life.',
  },
  {
    author_slug: 'ryan-holiday',
    slug: 'ego-is-the-enemy',
    title: 'Ego Is the Enemy',
    year: 2016,
    description: 'A book on the way ego derails ambition — and the Stoic practices that keep it in check.',
  },
  {
    author_slug: 'william-irvine',
    slug: 'a-guide-to-the-good-life',
    title: 'A Guide to the Good Life',
    year: 2008,
    description: 'A practical introduction to ancient Stoic technique — including negative visualization, voluntary discomfort, and journaling.',
  },
];
