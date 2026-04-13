'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';
import type { Course } from '@/types';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function EditCoursePage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params.id as string;
  
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [course, setCourse] = useState<Course | null>(null);
  const [form, setForm] = useState({
    title: '',
    description: '',
    category: '',
    level: 'beginner',
    price: 0,
    durationHours: 0,
    coverImageUrl: '',
    status: 'draft',
  });

  useEffect(() => {
    async function fetchCourse() {
      if (!courseId) return;

      const { data, error } = await supabase
        .from('courses')
        .select('*')
        .eq('id', courseId)
        .single();

      if (!error && data) {
        setCourse(data as Course);
        setForm({
          title: data.title || '',
          description: data.description || '',
          category: data.category || '',
          level: data.level || 'beginner',
          price: data.price || 0,
          durationHours: data.duration_hours || 0,
          coverImageUrl: data.cover_image_url || '',
          status: data.status || 'draft',
        });
      }
      setLoading(false);
    }

    fetchCourse();
  }, [courseId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError(null);

    try {
      const { error: updateError } = await supabase
        .from('courses')
        .update({
          title: form.title,
          description: form.description,
          category: form.category,
          level: form.level,
          price: form.price,
          duration_hours: form.durationHours,
          cover_image_url: form.coverImageUrl,
          status: form.status,
          updated_at: new Date().toISOString(),
        })
        .eq('id', courseId);

      if (updateError) throw updateError;

      router.push('/dashboard/courses');
    } catch (err: any) {
      setError(err.message || 'حدث خطأ في تحديث الكورس');
    } finally {
      setSaving(false);
    }
  };

  const updateField = (field: string, value: any) => {
    setForm(prev => ({ ...prev, [field]: value }));
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!course) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="card p-6 text-center">
          <p className="text-gray-500">لم يتم العثور على الكورس</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900">تعديل الكورس</h1>
        <div className="flex gap-2">
          <button
            onClick={() => router.push(`/dashboard/courses/${courseId}/content`)}
            className="btn-secondary"
          >
            إدارة المحتوى
          </button>
          <button
            onClick={() => router.push(`/dashboard/courses/${courseId}/exams`)}
            className="btn-secondary"
          >
            الاختبارات
          </button>
        </div>
      </div>

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
              />
            </div>

            <div>
              <label className="label">الوصف</label>
              <textarea
                value={form.description}
                onChange={(e) => updateField('description', e.target.value)}
                className="input min-h-[120px]"
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
              />
            </div>

            <div>
              <label className="label">الحالة</label>
              <select
                value={form.status}
                onChange={(e) => updateField('status', e.target.value)}
                className="input"
              >
                <option value="draft">مسودة</option>
                <option value="published">منشور</option>
                <option value="pendingReview">قيد المراجعة</option>
                <option value="archived">مؤرشف</option>
              </select>
            </div>
          </div>
        </div>

        <div className="flex gap-4">
          <button
            type="submit"
            disabled={saving}
            className="btn-primary"
          >
            {saving ? 'جاري الحفظ...' : 'حفظ التغييرات'}
          </button>
          <button
            type="button"
            onClick={() => router.push('/dashboard/courses')}
            className="btn-secondary"
          >
            إلغاء
          </button>
        </div>
      </form>
    </div>
  );
}