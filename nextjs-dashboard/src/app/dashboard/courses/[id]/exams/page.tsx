'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@supabase/supabase-js';
import type { Exam } from '@/types';
import { formatDate } from '@/lib/utils';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function ExamsPage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params.id as string;
  
  const [exams, setExams] = useState<Exam[]>([]);
  const [loading, setLoading] = useState(true);
  const [showDialog, setShowDialog] = useState(false);
  const [newExam, setNewExam] = useState({
    title: '',
    description: '',
    duration: 30,
    passingScore: 60,
    maxAttempts: 3,
  });

  useEffect(() => {
    async function fetchExams() {
      if (!courseId) return;

      const { data } = await supabase
        .from('exams')
        .select('*')
        .eq('course_id', courseId)
        .order('created_at', { ascending: false });

      if (data) setExams(data as Exam[]);
      setLoading(false);
    }

    fetchExams();
  }, [courseId]);

  const handleCreateExam = async () => {
    if (!newExam.title.trim()) return;

    const { data, error } = await supabase
      .from('exams')
      .insert({
        course_id: courseId,
        title: newExam.title,
        description: newExam.description,
        duration: newExam.duration,
        passing_score: newExam.passingScore,
        max_attempts: newExam.maxAttempts,
      })
      .select()
      .single();

    if (!error && data) {
      setExams([...exams, data as Exam]);
      setShowDialog(false);
      setNewExam({
        title: '',
        description: '',
        duration: 30,
        passingScore: 60,
        maxAttempts: 3,
      });
    }
  };

  const handleDelete = async (examId: string) => {
    if (!confirm('هل أنت متأكد من حذف هذا الاختبار؟')) return;

    await supabase.from('exams').delete().eq('id', examId);
    setExams(exams.filter(e => e.id !== examId));
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <button onClick={() => router.back()} className="text-primary-600 mb-2">
            ← العودة للكورس
          </button>
          <h1 className="text-2xl font-bold text-gray-900">الاختبارات</h1>
        </div>
        <button onClick={() => setShowDialog(true)} className="btn-primary">
          إضافة اختبار
        </button>
      </div>

      {exams.length === 0 ? (
        <div className="card p-12 text-center">
          <p className="text-gray-500">لا توجد اختبارات</p>
          <button onClick={() => setShowDialog(true)} className="btn-primary mt-4">
            إضافة اختبار
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {exams.map(exam => (
            <div key={exam.id} className="card p-4">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-semibold text-gray-900">{exam.title}</h3>
                  <p className="text-sm text-gray-500 mt-1">{exam.description}</p>
                  <div className="flex gap-4 mt-2 text-sm text-gray-500">
                    <span>⏱️ {exam.duration} دقيقة</span>
                    <span>📊 درجة النجاح: {exam.passing_score}%</span>
                    <span>🔄 المحاولات: {exam.max_attempts}</span>
                  </div>
                </div>
                <div className="flex gap-2">
                  <Link
                    href={`/dashboard/courses/${courseId}/exams/${exam.id}`}
                    className="btn-secondary btn-sm"
                  >
                    الأسئلة
                  </Link>
                  <button
                    onClick={() => handleDelete(exam.id)}
                    className="btn-danger btn-sm"
                  >
                    حذف
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Exam Dialog */}
      {showDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="card p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4">إضافة اختبار جديد</h2>
            
            <div className="space-y-4">
              <div>
                <label className="label">عنوان الاختبار *</label>
                <input
                  type="text"
                  value={newExam.title}
                  onChange={(e) => setNewExam({ ...newExam, title: e.target.value })}
                  className="input"
                />
              </div>

              <div>
                <label className="label">الوصف</label>
                <textarea
                  value={newExam.description}
                  onChange={(e) => setNewExam({ ...newExam, description: e.target.value })}
                  className="input"
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="label">المدة (دقيقة)</label>
                  <input
                    type="number"
                    value={newExam.duration}
                    onChange={(e) => setNewExam({ ...newExam, duration: parseInt(e.target.value) || 30 })}
                    className="input"
                  />
                </div>
                <div>
                  <label className="label">درجة النجاح %</label>
                  <input
                    type="number"
                    value={newExam.passingScore}
                    onChange={(e) => setNewExam({ ...newExam, passingScore: parseInt(e.target.value) || 60 })}
                    className="input"
                  />
                </div>
                <div>
                  <label className="label">عدد المحاولات</label>
                  <input
                    type="number"
                    value={newExam.maxAttempts}
                    onChange={(e) => setNewExam({ ...newExam, maxAttempts: parseInt(e.target.value) || 3 })}
                    className="input"
                  />
                </div>
              </div>
            </div>

            <div className="flex gap-2 mt-4">
              <button onClick={handleCreateExam} className="btn-primary flex-1">
                إضافة
              </button>
              <button onClick={() => setShowDialog(false)} className="btn-secondary">
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}