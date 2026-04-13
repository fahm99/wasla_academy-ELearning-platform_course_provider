'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

type TabType = 'profile' | 'password' | 'payments';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('profile');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  
  // Profile form
  const [profile, setProfile] = useState({
    fullName: '',
    email: '',
    phone: '',
    bio: '',
    organizationName: '',
  });
  
  // Password form
  const [password, setPassword] = useState({
    current: '',
    new: '',
    confirm: '',
  });
  
  // Payment settings form
  const [paymentSettings, setPaymentSettings] = useState({
    walletNumber: '',
    walletOwner: '',
    bankAccount: '',
    bankName: '',
  });

  useEffect(() => {
    async function fetchData() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Fetch profile
      const { data: profileData } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single();

      if (profileData) {
        setProfile({
          fullName: profileData.full_name || '',
          email: profileData.email || '',
          phone: profileData.phone || '',
          bio: profileData.bio || '',
          organizationName: profileData.organization_name || '',
        });
      }

      // Fetch payment settings
      const { data: paymentData } = await supabase
        .from('payment_settings')
        .select('*')
        .eq('provider_id', user.id)
        .single();

      if (paymentData) {
        setPaymentSettings({
          walletNumber: paymentData.wallet_number || '',
          walletOwner: paymentData.wallet_owner || '',
          bankAccount: paymentData.bank_account || '',
          bankName: paymentData.bank_name || '',
        });
      }

      setLoading(false);
    }

    fetchData();
  }, []);

  const handleSaveProfile = async () => {
    setSaving(true);
    setMessage(null);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('لم يتم تسجيل الدخول');

      const { error } = await supabase
        .from('users')
        .update({
          full_name: profile.fullName,
          phone: profile.phone,
        })
        .eq('id', user.id);

      if (error) throw error;
      setMessage({ type: 'success', text: 'تم حفظ الملف الشخصي بنجاح' });
    } catch (err: any) {
      setMessage({ type: 'error', text: err.message || 'حدث خطأ في الحفظ' });
    } finally {
      setSaving(false);
    }
  };

  const handleSavePaymentSettings = async () => {
    setSaving(true);
    setMessage(null);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('لم يتم تسجيل الدخول');

      // Check if payment settings exist
      const { data: existing } = await supabase
        .from('payment_settings')
        .select('id')
        .eq('provider_id', user.id)
        .single();

      if (existing) {
        const { error } = await supabase
          .from('payment_settings')
          .update({
            wallet_number: paymentSettings.walletNumber,
            wallet_owner: paymentSettings.walletOwner,
            bank_account: paymentSettings.bankAccount,
            bank_name: paymentSettings.bankName,
          })
          .eq('provider_id', user.id);

        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('payment_settings')
          .insert({
            provider_id: user.id,
            wallet_number: paymentSettings.walletNumber,
            wallet_owner: paymentSettings.walletOwner,
            bank_account: paymentSettings.bankAccount,
            bank_name: paymentSettings.bankName,
          });

        if (error) throw error;
      }

      setMessage({ type: 'success', text: 'تم حفظ إعدادات الدفع بنجاح' });
    } catch (err: any) {
      setMessage({ type: 'error', text: err.message || 'حدث خطأ في الحفظ' });
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async () => {
    setSaving(true);
    setMessage(null);

    if (password.new !== password.confirm) {
      setMessage({ type: 'error', text: 'كلمات المرور غير متطابقة' });
      setSaving(false);
      return;
    }

    if (password.new.length < 6) {
      setMessage({ type: 'error', text: 'يجب أن تكون كلمة المرور 6 أحرف على الأقل' });
      setSaving(false);
      return;
    }

    try {
      // Verify current password by attempting to sign in
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: profile.email,
        password: password.current,
      });

      if (signInError) {
        setMessage({ type: 'error', text: 'كلمة المرور الحالية غير صحيحة' });
        setSaving(false);
        return;
      }

      // Update to new password
      const { error: updateError } = await supabase.auth.updateUser({
        password: password.new,
      });

      if (updateError) throw updateError;

      setPassword({ current: '', new: '', confirm: '' });
      setMessage({ type: 'success', text: 'تم تغيير كلمة المرور بنجاح' });
    } catch (err: any) {
      setMessage({ type: 'error', text: err.message || 'حدث خطأ في تغيير كلمة المرور' });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">الإعدادات</h1>

      {/* Tabs */}
      <div className="flex gap-2 mb-6 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('profile')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'profile'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          الملف الشخصي
        </button>
        <button
          onClick={() => setActiveTab('password')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'password'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          كلمة المرور
        </button>
        <button
          onClick={() => setActiveTab('payments')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'payments'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          إعدادات الدفع
        </button>
      </div>

      {message && (
        <div className={`mb-4 p-3 rounded-lg text-sm ${
          message.type === 'success' ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'
        }`}>
          {message.text}
        </div>
      )}

      {/* Profile Tab */}
      {activeTab === 'profile' && (
        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">معلومات الملف الشخصي</h2>
          
          <div className="space-y-4">
            <div>
              <label className="label">الاسم الكامل</label>
              <input
                type="text"
                value={profile.fullName}
                onChange={(e) => setProfile({ ...profile, fullName: e.target.value })}
                className="input"
              />
            </div>

            <div>
              <label className="label">البريد الإلكتروني</label>
              <input
                type="email"
                value={profile.email}
                disabled
                className="input bg-gray-50"
              />
              <p className="text-xs text-gray-500 mt-1">لا يمكن تغيير البريد الإلكتروني</p>
            </div>

            <div>
              <label className="label">رقم الهاتف</label>
              <input
                type="tel"
                value={profile.phone}
                onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                className="input"
                placeholder="+966501234567"
              />
            </div>

            <button onClick={handleSaveProfile} disabled={saving} className="btn-primary">
              {saving ? 'جاري الحفظ...' : 'حفظ التغييرات'}
            </button>
          </div>
        </div>
      )}

      {/* Password Tab */}
      {activeTab === 'password' && (
        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">تغيير كلمة المرور</h2>
          
          <div className="space-y-4">
            <div>
              <label className="label">كلمة المرور الحالية</label>
              <input
                type="password"
                value={password.current}
                onChange={(e) => setPassword({ ...password, current: e.target.value })}
                className="input"
                placeholder="••••••••"
              />
            </div>

            <div>
              <label className="label">كلمة المرور الجديدة</label>
              <input
                type="password"
                value={password.new}
                onChange={(e) => setPassword({ ...password, new: e.target.value })}
                className="input"
                placeholder="••••••••"
              />
            </div>

            <div>
              <label className="label">تأكيد كلمة المرور</label>
              <input
                type="password"
                value={password.confirm}
                onChange={(e) => setPassword({ ...password, confirm: e.target.value })}
                className="input"
                placeholder="••••••••"
              />
            </div>

            <button onClick={handleChangePassword} disabled={saving} className="btn-primary">
              {saving ? 'جاري التغيير...' : 'تغيير كلمة المرور'}
            </button>
          </div>
        </div>
      )}

      {/* Payment Settings Tab */}
      {activeTab === 'payments' && (
        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">معلومات الدفع للطلاب</h2>
          <p className="text-sm text-gray-500 mb-4">
            هذه المعلومات ستظهر للطلاب عندشراء الكورسات
          </p>
          
          <div className="space-y-4">
            <div>
              <label className="label">رقم المحفظة</label>
              <input
                type="text"
                value={paymentSettings.walletNumber}
                onChange={(e) => setPaymentSettings({ ...paymentSettings, walletNumber: e.target.value })}
                className="input"
                placeholder="رقم المحفظة للتحويل"
              />
            </div>

            <div>
              <label className="label">اسم صاحب المحفظة</label>
              <input
                type="text"
                value={paymentSettings.walletOwner}
                onChange={(e) => setPaymentSettings({ ...paymentSettings, walletOwner: e.target.value })}
                className="input"
                placeholder="الاسم كما في المحفظة"
              />
            </div>

            <div className="border-t border-gray-200 pt-4 mt-4">
              <h3 className="font-medium text-gray-900 mb-2">ibank (اختياري)</h3>
            </div>

            <div>
              <label className="label">اسم البنك</label>
              <input
                type="text"
                value={paymentSettings.bankName}
                onChange={(e) => setPaymentSettings({ ...paymentSettings, bankName: e.target.value })}
                className="input"
                placeholder="اسم البنك"
              />
            </div>

            <div>
              <label className="label">رقم الحساب</label>
              <input
                type="text"
                value={paymentSettings.bankAccount}
                onChange={(e) => setPaymentSettings({ ...paymentSettings, bankAccount: e.target.value })}
                className="input"
                placeholder="رقم الحساب IBAN"
              />
            </div>

            <button onClick={handleSavePaymentSettings} disabled={saving} className="btn-primary">
              {saving ? 'جاري الحفظ...' : 'حفظ التغييرات'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}