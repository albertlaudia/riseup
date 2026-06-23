import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        ink: {
          DEFAULT: '#1f1d1a',
          soft: '#3b3833',
          mute: '#7a7268',
        },
        paper: {
          DEFAULT: '#faf6ef',
          warm: '#f4ede0',
          card: '#fffdf7',
        },
        accent: {
          DEFAULT: '#b9532e',
          soft: '#d97a55',
        },
        gold: '#c8a14a',
        sage: '#6b8a6a',
      },
      fontFamily: {
        serif: ['ui-serif', 'Georgia', 'Cambria', '"Times New Roman"', 'Times', 'serif'],
        sans: ['ui-sans-serif', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'sans-serif'],
        display: ['"Cormorant Garamond"', 'ui-serif', 'Georgia', 'serif'],
      },
      maxWidth: {
        'reading': '38rem',
      },
      boxShadow: {
        'soft': '0 1px 2px rgba(31,29,26,0.04), 0 8px 24px rgba(31,29,26,0.06)',
      },
    },
  },
  plugins: [],
};

export default config;
