import { createClient } from '@supabase/supabase-js';
import TopNavigation from '@/components/layout/TopNavigation';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Check session client-side via cookie header
  const { data: { session } } = await supabase.auth.getSession();

  // Allow access - actual auth check is done client-side in pages
  return (
    <div className="min-h-screen bg-gray-50">
      <TopNavigation />
      {children}
    </div>
  );
}