'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import { formatDate } from '@/lib/utils';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default function StudentsPage() {
  const [enrollments, setEnrollments] = useState<any[]>([]);
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCourse, setSelectedCourse] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudent, setSelectedStudent] = useState<any>(null);
  const [studentDetails, setStudentDetails] = useState<any>(null);

  useEffect(() => {
    async function fetchData() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Get provider courses
      const { data: coursesData } = await supabase
        .from('courses')
        .select('id, title')
        .eq('provider_id', user.id);
      
      if (coursesData) {
        setCourses(coursesData);
        const courseIds = coursesData.map(c => c.id);

        // Get enrollments
        const { data } = await supabase
          .from('enrollments')
          .select('*, student:users(*), course:courses(*)')
          .in('course_id', courseIds)
          .order('enrollment_date', { ascending: false });

        if (data) setEnrollments(data);
      }
      setLoading(false);
    }

    fetchData();
  }, []);

  const fetchStudentDetails = async (studentId: string) => {
    // Get student info
    const { data: student } = await supabase
      .from('users')
      .select('*')
      .eq('id', studentId)
      .single();

    // Get enrollments with course details
    const { data: enrollments } = await supabase
      .from('enrollments')
      .select('*, course:courses(*)')
      .eq('student_id', studentId);

    // Get exam results
    const { data: examResults } = await supabase
      .from('exam_results')
      .select('*, exam:exams(*)')
      .eq('student_id', studentId);

    // Get certificates
    const { data: certificates } = await supabase
      .from('certificates')
      .select('*, course:courses(*)')
      .eq('student_id', studentId);

    setStudentDetails({ student, enrollments, examResults, certificates });
  };

  const filteredEnrollments = enrollments.filter(e => {
    const courseMatch = selectedCourse === 'all' || e.course_id === selectedCourse;
    const searchMatch = !searchQuery || 
      (e.student?.full_name?.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (e.student?.email?.toLowerCase().includes(searchQuery.toLowerCase()));
    return courseMatch && searchMatch;
  });

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
        return <span className="badge-success">نشط</span>;
      case 'completed':
        return <span className="badge-info">مكتمل</span>;
      case 'dropped':
        return <span className="badge-danger">منسحب</span>;
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
      <h1 className="text-2xl font-bold text-gray-900 mb-6">الطلاب</h1>

      <div className="card">
        <div className="p-4 border-b border-gray-200 flex flex-wrap gap-4">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input flex-1 min-w-[200px]"
            placeholder="البحث عن طالب..."
          />
          <select
            value={selectedCourse}
            onChange={(e) => setSelectedCourse(e.target.value)}
            className="input min-w-[200px]"
          >
            <option value="all">جميع الكورسات</option>
            {courses.map(course => (
              <option key={course.id} value={course.id}>{course.title}</option>
            ))}
          </select>
        </div>

        {filteredEnrollments.length === 0 ? (
          <div className="p-12 text-center text-gray-500">
            لا توجد طلاب مسجلين
          </div>
        ) : (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>الطالب</th>
                  <th>الكورس</th>
                  <th>التقدم</th>
                  <th>الحالة</th>
                  <th>تاريخ التسجيل</th>
                </tr>
              </thead>
              <tbody>
                {filteredEnrollments.map(enrollment => (
                  <tr 
                    key={enrollment.id} 
                    className="cursor-pointer hover:bg-gray-50"
                    onClick={() => {
                      setSelectedStudent(enrollment.student);
                      fetchStudentDetails(enrollment.student_id);
                    }}
                  >
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-primary-700 font-medium">
                          {enrollment.student?.full_name?.[0] || enrollment.student?.email?.[0] || '؟'}
                        </div>
                        <div>
                          <p className="font-medium">{enrollment.student?.full_name || 'غير محدد'}</p>
                          <p className="text-sm text-gray-500">{enrollment.student?.email}</p>
                        </div>
                      </div>
                    </td>
                    <td>{enrollment.course?.title || 'غير محدد'}</td>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="w-24 h-2 bg-gray-200 rounded-full">
                          <div
                            className="h-2 bg-primary-600 rounded-full"
                            style={{ width: `${enrollment.completion_percentage || 0}%` }}
                          />
                        </div>
                        <span className="text-sm">{enrollment.completion_percentage || 0}%</span>
                      </div>
                    </td>
                    <td>{getStatusBadge(enrollment.status)}</td>
                    <td>{formatDate(enrollment.enrollment_date)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Student Details Modal */}
      {selectedStudent && studentDetails && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-3xl max-h-[90vh] overflow-y-auto">
            <div className="p-4 border-b border-gray-200 flex justify-between items-center">
              <h2 className="text-lg font-semibold">تفاصيل الطالب</h2>
              <button onClick={() => setSelectedStudent(null)} className="text-gray-500 hover:text-gray-700">
                ✕
              </button>
            </div>
            <div className="p-4">
              {/* Student Info */}
              <div className="mb-6">
                <h3 className="font-medium text-gray-900 mb-2">المعلومات</h3>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <p className="text-gray-500">الاسم</p>
                    <p className="font-medium">{studentDetails.student?.full_name || 'غير محدد'}</p>
                  </div>
                  <div>
                    <p className="text-gray-500">البريد</p>
                    <p className="font-medium">{studentDetails.student?.email}</p>
                  </div>
                  <div>
                    <p className="text-gray-500">رقم الهاتف</p>
                    <p className="font-medium">{studentDetails.student?.phone || 'غير محدد'}</p>
                  </div>
                </div>
              </div>

              {/* Enrollments */}
              <div className="mb-6">
                <h3 className="font-medium text-gray-900 mb-2">الكورسات ({studentDetails.enrollments?.length || 0})</h3>
                {studentDetails.enrollments?.length > 0 ? (
                  <div className="space-y-2">
                    {studentDetails.enrollments.map((e: any) => (
                      <div key={e.id} className="p-2 bg-gray-50 rounded flex justify-between">
                        <span>{e.course?.title}</span>
                        <span className="text-sm">{e.completion_percentage}%</span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-gray-500">لا توجد كورسات</p>
                )}
              </div>

              {/* Exam Results */}
              <div className="mb-6">
                <h3 className="font-medium text-gray-900 mb-2">النتائج ({studentDetails.examResults?.length || 0})</h3>
                {studentDetails.examResults?.length > 0 ? (
                  <div className="space-y-2">
                    {studentDetails.examResults.map((r: any) => (
                      <div key={r.id} className="p-2 bg-gray-50 rounded flex justify-between">
                        <span>{r.exam?.title}</span>
                        <span className={r.passed ? 'text-green-600' : 'text-red-600'}>
                          {r.score}% {r.passed ? '✓' : '✕'}
                        </span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-gray-500">لا توجد نتائج</p>
                )}
              </div>

              {/* Certificates */}
              <div>
                <h3 className="font-medium text-gray-900 mb-2">الشهادات ({studentDetails.certificates?.length || 0})</h3>
                {studentDetails.certificates?.length > 0 ? (
                  <div className="space-y-2">
                    {studentDetails.certificates.map((c: any) => (
                      <div key={c.id} className="p-2 bg-gray-50 rounded flex justify-between">
                        <span>{c.course?.title}</span>
                        <span className="text-sm text-gray-500">{c.certificate_number}</span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-gray-500">لا توجد شهادات</p>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}