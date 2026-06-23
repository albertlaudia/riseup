import type { Metadata, Viewport } from 'next';
import './globals.css';
import { Header } from '@/components/Header';
import { Footer } from '@/components/Footer';

const SITE_URL = 'https://xyc4pio8o5le.space.minimax.io';

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: 'RiseUP — Stoic practice for the long game',
    template: '%s — RiseUP',
  },
  description: 'A daily stoic motivation app. Lessons, quotes, and a streak that doesn\'t care about your mood.',
  applicationName: 'RiseUP',
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    title: 'RiseUP',
    statusBarStyle: 'default',
  },
  formatDetection: { telephone: false },
  openGraph: {
    type: 'website',
    siteName: 'RiseUP',
    title: 'RiseUP — Stoic practice for the long game',
    description: 'A daily stoic motivation app. Lessons, quotes, and a streak that doesn\'t care about your mood.',
    url: SITE_URL,
  },
  twitter: { card: 'summary' },
  icons: {
    icon: [
      { url: '/icons/icon-192.png', sizes: '192x192' },
      { url: '/icons/icon-512.png', sizes: '512x512' },
    ],
    apple: '/icons/icon-192.png',
  },
};

export const viewport: Viewport = {
  themeColor: '#1f1d1a',
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-paper text-ink antialiased bg-grain">
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
