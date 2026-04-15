'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { createClient } from '@supabase/supabase-js';
import type { Course } from '@/types';
import { formatDate, formatCurrency } from '@/lib/utils';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function CoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    async function fetchCourses() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      setUserId(user.id);

      const { data, error } = await supabase
        .from('courses')
        .select('*')
        .eq('provider_id', user.id)
        .order('created_at', { ascending: false });

      if (!error && data) {
        setCourses(data as Course[]);
      }
      setLoading(false);
    }

    fetchCourses();
  }, []);

  const handleDelete = async (courseId: string) => {
    if (!confirm('هل أنت متأكد من حذف هذا الكورس؟')) return;

    const { error } = await supabase.from('courses').delete().eq('id', courseId);
    
    if (!error) {
      setCourses(courses.filter(c => c.id !== courseId));
    }
  };

  const handlePublish = async (courseId: string, publish: boolean) => {
    const { error } = await supabase
      .from('courses')
      .update({ status: publish ? 'published' : 'draft' })
      .eq('id', courseId);

    if (!error) {
      setCourses(courses.map(c => 
        c.id === courseId ? { ...c, status: publish ? 'published' : 'draft' } : c
      ));
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'published':
        return <span className="badge-success">منشور</span>;
      case 'pendingReview':
        return <span className="badge-warning">قيد المراجعة</span>;
      case 'archived':
        return <span className="badge-danger">مؤرشف</span>;
      default:
        return <span className="badge-default">مسودة</span>;
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
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">الكورسات</h1>
        <Link href="/dashboard/courses/new" className="btn-primary">
          إضافة كورس جديد
        </Link>
      </div>

      {courses.length === 0 ? (
        <div className="card p-12 text-center">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
          <h3 className="mt-4 text-lg font-medium text-gray-900">لا توجد كورسات</h3>
          <p className="mt-2 text-sm text-gray-500">ابدأ بإنشاء أول كورس لك</p>
          <div className="mt-6">
            <Link href="/dashboard/courses/new" className="btn-primary">
              إضافة كورس جديد
            </Link>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {courses.map(course => (
            <div key={course.id} className="card overflow-hidden hover:shadow-md transition-shadow">
              <div className="aspect-video bg-gray-100 relative">
                {course.cover_image_url ? (
                  <img
                    src={course.cover_image_url}
                    alt={course.title}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <svg className="h-12 w-12 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                  </div>
                )}
                <div className="absolute top-2 left-2">
                  {getStatusBadge(course.status)}
                </div>
              </div>
              
              <div className="p-4">
                <h3 className="font-semibold text-gray-900 truncate">{course.title}</h3>
                <p className="text-sm text-gray-500 mt-1 line-clamp-2">
                  {course.description || 'لا يوجد وصف'}
                </p>
                
                <div className="flex items-center justify-between mt-4">
                  <span className="text-sm font-medium text-primary-600">
                    {formatCurrency(course.price, course.currency)}
                  </span>
                  <span className="text-sm text-gray-500">
                    {course.students_count || 0} طالب
                  </span>
                </div>

                <div className="flex gap-2 mt-4">
                  <Link
                    href={`/dashboard/courses/${course.id}`}
                    className="btn-secondary flex-1 text-center"
                  >
                    تعديل
                  </Link>
                  <Link
                    href={`/dashboard/courses/${course.id}/content`}
                    className="btn-secondary flex-1 text-center"
                  >
                    محتوى
                  </Link>
                  <button
                    onClick={() => handleDelete(course.id)}
                    className="btn-danger px-3"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>

                {course.status === 'draft' ? (
                  <button
                    onClick={() => handlePublish(course.id, true)}
                    className="btn-success w-full mt-2"
                  >
                    نشر الكورس
                  </button>
                ) : course.status === 'published' ? (
                  <button
                    onClick={() => handlePublish(course.id, false)}
                    className="btn-secondary w-full mt-2"
                  >
                    إلغاء النشر
                  </button>
                ) : null}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}