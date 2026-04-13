'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import { generateCertificateNumber, formatDate } from '@/lib/utils';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function CertificatesPage() {
  const [certificates, setCertificates] = useState<any[]>([]);
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showIssueDialog, setShowIssueDialog] = useState(false);
  const [selectedCourse, setSelectedCourse] = useState('');
  const [selectedStudent, setSelectedStudent] = useState('');

  useEffect(() => {
    async function fetchData() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Get courses
      const { data: coursesData } = await supabase
        .from('courses')
        .select('id, title')
        .eq('provider_id', user.id);
      
      if (coursesData) setCourses(coursesData);

      // Get certificates
      const { data } = await supabase
        .from('certificates')
        .select('*, student:users(*), course:courses(*)')
        .eq('provider_id', user.id)
        .order('created_at', { ascending: false });

      if (data) setCertificates(data);
      setLoading(false);
    }

    fetchData();
  }, []);

  const handleIssueCertificate = async () => {
    if (!selectedCourse || !selectedStudent) return;

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { error } = await supabase
      .from('certificates')
      .insert({
        course_id: selectedCourse,
        student_id: selectedStudent,
        provider_id: user.id,
        certificate_number: generateCertificateNumber(),
        issue_date: new Date().toISOString(),
        status: 'issued',
      });

    if (!error) {
      setShowIssueDialog(false);
      // Refresh certificates
      window.location.reload();
    }
  };

  const handleRevoke = async (certificateId: string) => {
    if (!confirm('هل أنت متأكد من إلغاء هذه الشهادة؟')) return;

    const { error } = await supabase
      .from('certificates')
      .update({ status: 'revoked' })
      .eq('id', certificateId);

    if (!error) {
      setCertificates(certificates.map(c => 
        c.id === certificateId ? { ...c, status: 'revoked' } : c
      ));
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'issued':
        return <span className="badge-success">سارية</span>;
      case 'revoked':
        return <span className="badge-danger">ملغاة</span>;
      default:
        return <span className="badge-default">{status}</span>;
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
        <h1 className="text-2xl font-bold text-gray-900">الشهادات</h1>
        <button onClick={() => setShowIssueDialog(true)} className="btn-primary">
          إصدار شهادة
        </button>
      </div>

      {certificates.length === 0 ? (
        <div className="card p-12 text-center">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
          </svg>
          <h3 className="mt-4 text-lg font-medium text-gray-900">لا توجد شهادات</h3>
          <p className="mt-2 text-sm text-gray-500">ابدأ بإصدار أول شهادة</p>
          <button onClick={() => setShowIssueDialog(true)} className="btn-primary mt-4">
            إصدار شهادة
          </button>
        </div>
      ) : (
        <div className="card">
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>رقم الشهادة</th>
                  <th>الطالب</th>
                  <th>الكورس</th>
                  <th>تاريخ الإصدار</th>
                  <th>الحالة</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {certificates.map(cert => (
                  <tr key={cert.id}>
                    <td className="font-mono">{cert.certificate_number}</td>
                    <td>{cert.student?.full_name || cert.student?.email || 'غير محدد'}</td>
                    <td>{cert.course?.title || 'غير محدد'}</td>
                    <td>{formatDate(cert.issue_date)}</td>
                    <td>{getStatusBadge(cert.status)}</td>
                    <td>
                      {cert.status === 'issued' && (
                        <button
                          onClick={() => handleRevoke(cert.id)}
                          className="text-red-600 hover:text-red-700 text-sm"
                        >
                          إلغاء
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Issue Certificate Dialog */}
      {showIssueDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="card p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4">إصدار شهادة جديدة</h2>
            
            <div className="space-y-4">
              <div>
                <label className="label">الكورس</label>
                <select
                  value={selectedCourse}
                  onChange={(e) => setSelectedCourse(e.target.value)}
                  className="input"
                >
                  <option value="">اختر الكورس</option>
                  {courses.map(course => (
                    <option key={course.id} value={course.id}>{course.title}</option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="label">الطالب</label>
                <input
                  type="text"
                  value={selectedStudent}
                  onChange={(e) => setSelectedStudent(e.target.value)}
                  className="input"
                  placeholder="معرف الطالب"
                />
              </div>
            </div>

            <div className="flex gap-2 mt-4">
              <button onClick={handleIssueCertificate} className="btn-primary flex-1">
                إصدار
              </button>
              <button onClick={() => setShowIssueDialog(false)} className="btn-secondary">
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}