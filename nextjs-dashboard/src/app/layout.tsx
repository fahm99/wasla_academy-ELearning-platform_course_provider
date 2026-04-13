import '@/app/globals.css';
import type { Metadata } from 'next';
import { Tajawal, Plus_Jakarta_Sans } from 'next/font/google';

// Import both fonts
const tajawal = Tajawal({
  weight: ['200', '300', '400', '500', '700', '800'], // No 600
  subsets: ['arabic', 'latin'],
  variable: '--font-tajawal',
});

const plusJakartaSans = Plus_Jakarta_Sans({
  weight: ['400', '500', '600', '700'], // Add available weights
  subsets: ['latin'],
  variable: '--font-plus-jakarta',
});

export const metadata: Metadata = {
  title: 'Wasla - منصة مقدم خدمة الكورسات',
  description: 'لوحة تحكم مقدم خدمة الكورسات',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${tajawal.variable} ${plusJakartaSans.variable}`}>
        {children}
      </body>
    </html>
  );
}