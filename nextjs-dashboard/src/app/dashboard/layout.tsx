'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Navigation items matching Flutter design
const NAV_ITEMS = [
  { href: '/dashboard', icon: 'dashboard', label: 'الرئيسية' },
  { href: '/dashboard/courses', icon: 'courses', label: 'الكورسات' },
  { href: '/dashboard/certificates', icon: 'certificates', label: 'الشهادات' },
  { href: '/dashboard/payments', icon: 'payments', label: 'المدفوعات' },
  { href: '/dashboard/settings', icon: 'settings', label: 'الإعدادات' },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    checkAuth();
    // Set current index based on pathname
    const path = pathname || '/dashboard';
    const index = NAV_ITEMS.findIndex(item => path.startsWith(item.href) && item.href !== '/dashboard');
    if (index > -1) setCurrentIndex(index);
    else if (path === '/dashboard') setCurrentIndex(0);
  }, [pathname]);

  async function checkAuth() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      router.push('/auth/login');
      return;
    }
    setUser(user);
    setLoading(false);
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    router.push('/auth/login');
  };

  const getIcon = (icon: string, isActive: boolean) => {
    const fill = isActive ? '1' : '0';
    
    switch (icon) {
      case 'dashboard':
        return (
          <svg className="w-5 h-5" fill={fill} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 5a1 1 0 011-1h4a1 1 0 011 1v5a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM14 5a1 1 0 011-1h4a1 1 0 011 1v5a1 1 0 01-1 1h-4a1 1 0 01-1-1V5zM4 15a1 1 0 011-1h4a1 1 0 011 1v5a1 1 0 01-1 1H5a1 1 0 01-1-1v-5zM14 15a1 1 0 011-1h4a1 1 0 011 1v5a1 1 0 01-1 1h-4a1 1 0 01-1-1v-5z" />
          </svg>
        );
      case 'courses':
        return (
          <svg className="w-5 h-5" fill={fill} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        );
      case 'certificates':
        return (
          <svg className="w-5 h-5" fill={fill} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
          </svg>
        );
      case 'payments':
        return (
          <svg className="w-5 h-5" fill={fill} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m1 4h1m4-10h1m1 4h1m1-4h1m1 4h1m1-4h1M5 21h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2z" />
          </svg>
        );
      case 'settings':
        return (
          <svg className="w-5 h-5" fill={fill} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        );
      default:
        return null;
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F9F9F9] flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F9F9F9]">
      {/* Desktop Header - matching Flutter design */}
      <header className="hidden md:block bg-white/70 backdrop-blur-xl shadow-[0_12px_32px_rgba(12,20,69,0.06)] sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-8 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link href="/dashboard" className="flex items-center gap-2">
              <span className="text-2xl font-black text-primary" style={{ fontFamily: 'Cairo, system-ui, sans-serif' }}>
                وصلة
              </span>
            </Link>

            {/* Desktop Navigation */}
            <nav className="flex items-center gap-8">
              {NAV_ITEMS.map((item, index) => {
                const isActive = (pathname === item.href) || (item.href !== '/dashboard' && pathname?.startsWith(item.href));
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`relative py-2 px-3 text-sm font-medium transition-colors ${
                      isActive ? 'text-primary' : 'text-[#64748B] hover:text-primary'
                    }`}
                    onClick={() => setCurrentIndex(index)}
                  >
                    {item.label}
                    {isActive && (
                      <span className="absolute bottom-0 right-0 left-0 h-0.5 bg-secondary rounded-t" />
                    )}
                  </Link>
                );
              })}
            </nav>

            {/* Right Section: Search, Notifications, Profile */}
            <div className="flex items-center gap-4">
              {/* Search Bar */}
              <div className="relative">
                <input
                  type="text"
                  placeholder="ابحث عن كورس أو طالب..."
                  className="w-64 h-10 pl-10 pr-4 bg-[#E2E2E2] rounded-xl text-sm text-[#454652] placeholder-[#454652] border-none outline-none focus:ring-2 focus:ring-primary/20"
                  style={{ fontFamily: 'Cairo, system-ui, sans-serif' }}
                />
                <svg className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#454652]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>

              {/* Notifications */}
              <button className="p-2 text-[#454652] hover:text-primary transition-colors">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 7.388 6 9v5.159c0 .316.104.632.405.855L5 16v1h14v-1l-1.405-1.405A2.032 2.032 0 0115 17z" />
                </svg>
              </button>

              {/* Divider */}
              <div className="w-px h-10 bg-[#C6C5D4]/30" />

              {/* Profile */}
              <button
                onClick={handleSignOut}
                className="flex items-center gap-2 p-1 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <div className="w-10 h-10 rounded-full bg-secondary flex items-center justify-center">
                  <span className="text-primary font-bold" style={{ fontFamily: 'Cairo, system-ui, sans-serif' }}>
                    {user?.email?.[0]?.toUpperCase() || 'U'}
                  </span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Header */}
      <header className="md:hidden bg-white shadow-md sticky top-0 z-50">
        <div className="flex items-center justify-between px-4 py-3">
          <Link href="/dashboard" className="text-xl font-black text-primary">
            وصلة
          </Link>
          <button className="p-2 text-primary">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 md:px-8 py-6">
        {children}
      </main>

      {/* Mobile Bottom Navigation */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-xl border-t border-[#C6C5D4]/20 shadow-[-4px_0_20px_rgba(0,0,0,0.05)] z-50">
        <div className="flex items-center justify-around py-2 px-2 safe-area-bottom">
          {NAV_ITEMS.map((item) => {
            const isActive = (pathname === item.href) || (item.href !== '/dashboard' && pathname?.startsWith(item.href));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-colors ${
                  isActive
                    ? 'text-primary bg-primary/5'
                    : 'text-[#94A3B8]'
                }`}
                style={{ flex: 1 }}
              >
                <div className={isActive ? 'border-t-2 border-secondary w-full absolute -top-0.5' : ''} />
                {getIcon(item.icon, isActive)}
                <span className="text-[10px] font-medium">{item.label}</span>
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}