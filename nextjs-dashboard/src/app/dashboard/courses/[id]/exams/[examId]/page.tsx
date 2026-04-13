'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@supabase/supabase-js';
import type { ExamQuestion } from '@/types';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function ExamQuestionsPage() {
  const router = useRouter();
  const params = useParams();
  const examId = params.examId as string;
  
  const [questions, setQuestions] = useState<ExamQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [showDialog, setShowDialog] = useState(false);
  const [newQuestion, setNewQuestion] = useState({
    question: '',
    option1: '',
    option2: '',
    option3: '',
    option4: '',
    correctOption: 0,
  });

  useEffect(() => {
    async function fetchQuestions() {
      if (!examId) return;

      const { data } = await supabase
        .from('exam_questions')
        .select('*')
        .eq('exam_id', examId)
        .order('order_index');

      if (data) setQuestions(data as ExamQuestion[]);
      setLoading(false);
    }

    fetchQuestions();
  }, [examId]);

  const handleCreateQuestion = async () => {
    if (!newQuestion.question.trim() || !newQuestion.option1.trim()) return;

    const { data, error } = await supabase
      .from('exam_questions')
      .insert({
        exam_id: examId,
        question: newQuestion.question,
        options: [newQuestion.option1, newQuestion.option2, newQuestion.option3, newQuestion.option4],
        correct_option: newQuestion.correctOption,
        order_index: questions.length,
      })
      .select()
      .single();

    if (!error && data) {
      setQuestions([...questions, data as ExamQuestion]);
      setShowDialog(false);
      setNewQuestion({
        question: '',
        option1: '',
        option2: '',
        option3: '',
        option4: '',
        correctOption: 0,
      });
    }
  };

  const handleDelete = async (questionId: string) => {
    if (!confirm('هل أنت متأكد من حذف هذا السؤال؟')) return;

    await supabase.from('exam_questions').delete().eq('id', questionId);
    setQuestions(questions.filter(q => q.id !== questionId));
  };

  const getOptionLabel = (index: number) => {
    return ['أ', 'ب', 'ج', 'د'][index];
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
            ← العودة للاختبار
          </button>
          <h1 className="text-2xl font-bold text-gray-900">الأسئلة</h1>
          <p className="text-sm text-gray-500">{questions.length} سؤال</p>
        </div>
        <button onClick={() => setShowDialog(true)} className="btn-primary">
          إضافة سؤال
        </button>
      </div>

      {questions.length === 0 ? (
        <div className="card p-12 text-center">
          <p className="text-gray-500">لا توجد أسئلة</p>
          <button onClick={() => setShowDialog(true)} className="btn-primary mt-4">
            إضافة سؤال
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {questions.map((question, index) => (
            <div key={question.id} className="card p-4">
              <div className="flex justify-between items-start">
                <div>
                  <span className="text-sm text-gray-500">سؤال {index + 1}</span>
                  <h3 className="font-medium text-gray-900 mt-1">{question.question}</h3>
                  <div className="mt-2 space-y-1">
                    {question.options.map((option, optIndex) => (
                      <div 
                        key={optIndex} 
                        className={`text-sm ${
                          optIndex === question.correct_option 
                            ? 'text-green-600 font-medium' 
                            : 'text-gray-500'
                        }`}
                      >
                        {getOptionLabel(optIndex)}) {option}
                        {optIndex === question.correct_option && ' ✓'}
                      </div>
                    ))}
                  </div>
                </div>
                <button
                  onClick={() => handleDelete(question.id)}
                  className="btn-danger btn-sm"
                >
                  حذف
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Question Dialog */}
      {showDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="card p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <h2 className="text-lg font-semibold mb-4">إضافة سؤال جديد</h2>
            
            <div className="space-y-4">
              <div>
                <label className="label">نص السؤال *</label>
                <textarea
                  value={newQuestion.question}
                  onChange={(e) => setNewQuestion({ ...newQuestion, question: e.target.value })}
                  className="input"
                />
              </div>

              <div className="space-y-2">
                <label className="label">الخيارات</label>
                
                <div className="flex gap-2 items-center">
                  <input
                    type="radio"
                    name="correct"
                    checked={newQuestion.correctOption === 0}
                    onChange={() => setNewQuestion({ ...newQuestion, correctOption: 0 })}
                  />
                  <input
                    type="text"
                    value={newQuestion.option1}
                    onChange={(e) => setNewQuestion({ ...newQuestion, option1: e.target.value })}
                    className="input flex-1"
                    placeholder="الخيار الأول (صحيح)"
                  />
                </div>
                
                <div className="flex gap-2 items-center">
                  <input
                    type="radio"
                    name="correct"
                    checked={newQuestion.correctOption === 1}
                    onChange={() => setNewQuestion({ ...newQuestion, correctOption: 1 })}
                  />
                  <input
                    type="text"
                    value={newQuestion.option2}
                    onChange={(e) => setNewQuestion({ ...newQuestion, option2: e.target.value })}
                    className="input flex-1"
                    placeholder="الخيار الثاني"
                  />
                </div>
                
                <div className="flex gap-2 items-center">
                  <input
                    type="radio"
                    name="correct"
                    checked={newQuestion.correctOption === 2}
                    onChange={() => setNewQuestion({ ...newQuestion, correctOption: 2 })}
                  />
                  <input
                    type="text"
                    value={newQuestion.option3}
                    onChange={(e) => setNewQuestion({ ...newQuestion, option3: e.target.value })}
                    className="input flex-1"
                    placeholder="الخيار الثالث"
                  />
                </div>
                
                <div className="flex gap-2 items-center">
                  <input
                    type="radio"
                    name="correct"
                    checked={newQuestion.correctOption === 3}
                    onChange={() => setNewQuestion({ ...newQuestion, correctOption: 3 })}
                  />
                  <input
                    type="text"
                    value={newQuestion.option4}
                    onChange={(e) => setNewQuestion({ ...newQuestion, option4: e.target.value })}
                    className="input flex-1"
                    placeholder="الخيار الرابع"
                  />
                </div>
              </div>
            </div>

            <div className="flex gap-2 mt-4">
              <button onClick={handleCreateQuestion} className="btn-primary flex-1">
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