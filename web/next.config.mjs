/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',          // pure static export → goes to `out/`
  trailingSlash: false,
  reactStrictMode: true,
  images: {
    unoptimized: true,      // required for static export
    remotePatterns: [
      { protocol: 'https', hostname: 'upload.wikimedia.org' },
      { protocol: 'https', hostname: 'pocketbase.scaleupcrm.com' },
    ],
  },
};

export default nextConfig;
