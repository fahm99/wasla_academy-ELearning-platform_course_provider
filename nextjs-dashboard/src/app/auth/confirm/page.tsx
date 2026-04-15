'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function ConfirmPage() {
  const router = useRouter();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [message, setMessage] = useState('جاري التحقق من البريد الإلكتروني...');

  useEffect(() => {
    async function handleConfirmation() {
      try {
        // Get the hash params from URL (Supabase sends confirmation token in hash)
        const hashParams = new URLSearchParams(window.location.hash.substring(1));
        const accessToken = hashParams.get('access_token');
        const refreshToken = hashParams.get('refresh_token');

        if (accessToken && refreshToken) {
          // Set the session with the tokens
          const { data, error } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken,
          });

          if (error) throw error;

          // Check if user is now confirmed
          if (data.user?.email_confirmed_at) {
            // Create user profile if not exists
            const { data: existingUser } = await supabase
              .from('users')
              .select('id')
              .eq('id', data.user.id)
              .single();

            if (!existingUser) {
              await supabase.from('users').insert({
                id: data.user.id,
                email: data.user.email,
                full_name: data.user.user_metadata?.full_name || '',
                role: 'provider',
              });
            }

            setStatus('success');
            setMessage('✅ تم التحقق من بريدك الإلكتروني بنجاح!');

            // Redirect to dashboard after 2 seconds
            setTimeout(() => {
              router.push('/dashboard');
            }, 2000);
          } else {
            throw new Error('Email not confirmed');
          }
        } else {
          // Check if already logged in (user clicked on already confirmed link)
          const { data: { session } } = await supabase.auth.getSession();
          
          if (session?.user?.email_confirmed_at) {
            setStatus('success');
            setMessage('✅ حسابك مفعل بالفعل! جاري التوجيه...');
            setTimeout(() => {
              router.push('/dashboard');
            }, 2000);
          } else {
            throw new Error('Invalid confirmation link');
          }
        }
      } catch (err: any) {
        console.error('Confirmation error:', err);
        setStatus('error');
        setMessage(err.message || 'حدث خطأ في التحقق من البريد الإلكتروني');
      }
    }

    handleConfirmation();
  }, [router]);

  return (
    <div className="min-h-screen bg-surface flex flex-col justify-center items-center px-4">
      <div className="max-w-md w-full text-center">
        {/* Status Icon */}
        <div className={`w-24 h-24 rounded-full flex items-center justify-center mx-auto mb-6 ${
          status === 'loading' ? 'bg-primary/10' :
          status === 'success' ? 'bg-green-100' : 'bg-red-100'
        }`}>
          {status === 'loading' && (
            <span className="loading-spinner w-10 h-10 border-4 border-primary/20 border-t-primary"></span>
          )}
          {status === 'success' && (
            <span className="text-5xl">✅</span>
          )}
          {status === 'error' && (
            <span className="text-5xl">❌</span>
          )}
        </div>

        {/* Logo */}
        <h1 className="text-3xl font-bold text-primary mb-2">Wasla</h1>
        <p className="text-on-surface-variant mb-6">منصة التعليمية</p>

        {/* Message */}
        <div className={`card p-6 ${status === 'error' ? 'border-red-200' : ''}`}>
          <p className={`text-lg ${status === 'success' ? 'text-green-600' : status === 'error' ? 'text-red-600' : 'text-on-surface'}`}>
            {message}
          </p>
          
          {status === 'error' && (
            <button
              onClick={() => router.push('/auth/login')}
              className="btn-primary mt-4"
            >
              تسجيل الدخول
            </button>
          )}
          
          {status === 'loading' && (
            <p className="text-on-surface-subtle text-sm mt-4">
              يرجى الانتظار...
            </p>
          )}
        </div>

        {/* Help */}
        {status === 'error' && (
          <p className="text-on-surface-subtle text-sm mt-4">
            إذا استمرت المشكلة، يرجى التواصل مع الدعم
          </p>
        )}
      </div>
    </div>
  );
}