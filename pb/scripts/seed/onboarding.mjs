// Onboarding — 3 swipeable cards shown on first launch.
// Persisted in shared_preferences as `hasOnboarded = true`.

export const ONBOARDING = [
  {
    order: 1,
    title: 'A small, daily practice',
    body: 'A short lesson in the morning. A quote to carry through the day. A streak that doesn\'t care about your mood. That is the whole thing. Most of what we call motivation is just attention, paid on purpose, for thirty seconds a day.',
    icon: '🌿',
    cta: 'Next',
  },
  {
    order: 2,
    title: 'Streaks, with mercy',
    body: 'The streak is the reward, not the test. You get one free freeze per month — miss a day, the streak survives. Build a real practice, not a perfect one. The first 4 lessons are free, forever. Pro unlocks the deep stuff and offline reading.',
    icon: '🔥',
    cta: 'Next',
  },
  {
    order: 3,
    title: 'Your reminder',
    body: 'Pick a time for the daily nudge. Quiet hours respected. Change it any time in Settings. The reminder is the difference between "I downloaded it" and "I use it."',
    icon: '🔔',
    cta: 'Begin',
  },
];
