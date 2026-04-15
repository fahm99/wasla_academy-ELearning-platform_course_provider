'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function RegisterPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    if (password !== confirmPassword) {
      setError('كلمات المرور غير متطابقة');
      setLoading(false);
      return;
    }

    if (password.length < 6) {
      setError('يجب أن تكون كلمة المرور 6 أحرف على الأقل');
      setLoading(false);
      return;
    }

    try {
      // Create user - disable email confirmation for easier testing
      // In production, you would enable email confirmation in Supabase
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { full_name: fullName },
          // For testing: disable redirect
          emailRedirectTo: `${typeof window !== 'undefined' ? window.location.origin : ''}/auth/confirm`,
        }
      });

      if (signUpError) {
        console.error('SignUp Error:', signUpError);
        throw signUpError;
      }

      console.log('SignUp Data:', data);

      // If user is created (email confirmation may be disabled in Supabase)
      if (data.user) {
        // Create user profile
        await supabase.from('users').insert({
          id: data.user.id,
          email,
          full_name: fullName,
          role: 'provider',
        });
      }

      // Show success message
      setSuccess(true);
      
    } catch (err: any) {
      console.error('Registration error:', err);
      setError(err.message || 'حدث خطأ في إنشاء الحساب');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-surface flex flex-col justify-center py-12 px-4">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-primary">Wasla</h1>
          <p className="mt-2 text-on-surface-variant">منصة التعليمية</p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="card py-8 px-4 sm:px-10">
          {!success ? (
            <>
              <h2 className="text-2xl font-bold text-primary text-center mb-6">
                إنشاء حساب جديد
              </h2>

              {error && (
                <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-xl text-red-600 text-sm">
                  {error}
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-6">
                <div>
                  <label htmlFor="fullName" className="label">
                    الاسم الكامل
                  </label>
                  <input
                    id="fullName"
                    type="text"
                    required
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    className="input"
                    placeholder="الاسم الكامل"
                  />
                </div>

                <div>
                  <label htmlFor="email" className="label">
                    البريد الإلكتروني
                  </label>
                  <input
                    id="email"
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="input"
                    placeholder="example@email.com"
                  />
                </div>

                <div>
                  <label htmlFor="password" className="label">
                    كلمة المرور
                  </label>
                  <input
                    id="password"
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="input"
                    placeholder="••••••••"
                  />
                </div>

                <div>
                  <label htmlFor="confirmPassword" className="label">
                    تأكيد كلمة المرور
                  </label>
                  <input
                    id="confirmPassword"
                    type="password"
                    required
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="input"
                    placeholder="••••••••"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="btn-primary w-full"
                >
                  {loading ? 'جاري إنشاء الحساب...' : 'إنشاء حساب'}
                </button>
              </form>
            </>
          ) : (
            /* Success Message */
            <div className="text-center py-6">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-4xl">✅</span>
              </div>
              <h2 className="text-xl font-bold text-primary mb-2">
                تم إنشاء حسابك بنجاح!
              </h2>
              <p className="text-on-surface-variant mb-4">
                لقد أرسلنا رابط التحقق إلى بريدك الإلكتروني:
              </p>
              <p className="font-semibold text-primary bg-surface-low px-4 py-2 rounded-lg inline-block mb-6">
                {email}
              </p>
              <div className="bg-surface-low rounded-xl p-4 text-right">
                <p className="text-on-surface-subtle text-sm mb-2">📋 الخطوات:</p>
                <ol className="text-on-surface-variant text-sm space-y-2 list-decimal list-right mr-4">
                  <li>افتح بريدك الإلكتروني</li>
                  <li>ابحث عن رسالة من Wasla</li>
                  <li>اضغط على رابط "تأكيد البريد الإلكتروني"</li>
                  <li>ستتم إعادة توجيهك للداشبورد تلقائياً</li>
                </ol>
              </div>
              <p className="text-on-surface-subtle text-xs mt-4">
                لم تستلم الرسالة؟ تحقق من مجلد الرسائل غير المرغوب فيها (Spam)
              </p>
            </div>
          )}

          <div className="mt-6 text-center">
            <p className="text-sm text-on-surface-variant">
              لديك حساب بالفعل؟{' '}
              <Link
                href="/auth/login"
                className="text-primary hover:underline font-medium"
              >
                تسجيل الدخول
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}