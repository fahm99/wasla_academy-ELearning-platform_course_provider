'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function NewCoursePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    title: '',
    description: '',
    category: '',
    level: 'beginner',
    price: 0,
    durationHours: 0,
    coverImageUrl: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('لم يتم تسجيل الدخول');

      const { data, error: insertError } = await supabase
        .from('courses')
        .insert({
          provider_id: user.id,
          title: form.title,
          description: form.description,
          category: form.category,
          level: form.level,
          price: form.price,
          duration_hours: form.durationHours,
          cover_image_url: form.coverImageUrl,
          status: 'draft',
        })
        .select()
        .single();

      if (insertError) throw insertError;

      router.push(`/dashboard/courses/${data.id}`);
    } catch (err: any) {
      setError(err.message || 'حدث خطأ في إنشاء الكورس');
    } finally {
      setLoading(false);
    }
  };

  const updateField = (field: string, value: any) => {
    setForm(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">إنشاء كورس جديد</h1>

      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">معلومات الكورس</h2>
          
          <div className="space-y-4">
            <div>
              <label className="label">عنوان الكورس *</label>
              <input
                type="text"
                required
                value={form.title}
                onChange={(e) => updateField('title', e.target.value)}
                className="input"
                placeholder="مثال: تعلم البرمجة من الصفر"
              />
            </div>

            <div>
              <label className="label">الوصف</label>
              <textarea
                value={form.description}
                onChange={(e) => updateField('description', e.target.value)}
                className="input min-h-[120px]"
                placeholder="وصف موجز للكورس..."
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="label">الفئة</label>
                <input
                  type="text"
                  value={form.category}
                  onChange={(e) => updateField('category', e.target.value)}
                  className="input"
                  placeholder="مثال: البرمجة"
                />
              </div>

              <div>
                <label className="label">المستوى</label>
                <select
                  value={form.level}
                  onChange={(e) => updateField('level', e.target.value)}
                  className="input"
                >
                  <option value="beginner">مبتدئ</option>
                  <option value="intermediate">متوسط</option>
                  <option value="advanced">متقدم</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="label">السعر (ريال)</label>
                <input
                  type="number"
                  value={form.price}
                  onChange={(e) => updateField('price', parseFloat(e.target.value) || 0)}
                  className="input"
                  min="0"
                  step="0.01"
                />
              </div>

              <div>
                <label className="label">المدة (ساعات)</label>
                <input
                  type="number"
                  value={form.durationHours}
                  onChange={(e) => updateField('durationHours', parseInt(e.target.value) || 0)}
                  className="input"
                  min="0"
                />
              </div>
            </div>

            <div>
              <label className="label">رابط صورة الغلاف</label>
              <input
                type="url"
                value={form.coverImageUrl}
                onChange={(e) => updateField('coverImageUrl', e.target.value)}
                className="input"
                placeholder="https://..."
              />
            </div>
          </div>
        </div>

        <div className="flex gap-4">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary"
          >
            {loading ? 'جاري الإنشاء...' : 'إنشاء الكورس'}
          </button>
          <button
            type="button"
            onClick={() => router.back()}
            className="btn-secondary"
          >
            إلغاء
          </button>
        </div>
      </form>
    </div>
  );
}