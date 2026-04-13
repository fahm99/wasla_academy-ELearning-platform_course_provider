import { supabase, tables } from './supabase';
import type { 
  Course, 
  Module, 
  Lesson, 
  Enrollment, 
  Exam, 
  ExamQuestion,
  ExamResult,
  Certificate,
  CertificateTemplate,
  Payment,
  PaymentSettings,
  AppSettings,
  User,
  LessonProgress
} from '@/types';

// Auth Service
export const authService = {
  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  async signUp(email: string, password: string, fullName: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    if (error) throw error;
    return data;
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getSession() {
    const { data: { session } } = await supabase.auth.getSession();
    return session;
  },

  async getCurrentUser() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;
    
    const { data: profile } = await supabase
      .from(tables.users)
      .select('*')
      .eq('id', user.id)
      .single();
    
    return profile;
  },

  async updatePassword(newPassword: string) {
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) throw error;
  },
};

// Course Service
export const courseService = {
  async getProviderCourses(providerId: string) {
    const { data, error } = await supabase
      .from(tables.courses)
      .select('*')
      .eq('provider_id', providerId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data as Course[];
  },

  async getCourseById(courseId: string) {
    const { data, error } = await supabase
      .from(tables.courses)
      .select('*')
      .eq('id', courseId)
      .single();
    
    if (error) throw error;
    return data as Course;
  },

  async createCourse(course: Partial<Course>) {
    const { data, error } = await supabase
      .from(tables.courses)
      .insert([course])
      .select()
      .single();
    
    if (error) throw error;
    return data as Course;
  },

  async updateCourse(courseId: string, updates: Partial<Course>) {
    const { data, error } = await supabase
      .from(tables.courses)
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', courseId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Course;
  },

  async deleteCourse(courseId: string) {
    const { error } = await supabase
      .from(tables.courses)
      .delete()
      .eq('id', courseId);
    
    if (error) throw error;
  },

  async publishCourse(courseId: string) {
    return this.updateCourse(courseId, { status: 'published' });
  },

  async unpublishCourse(courseId: string) {
    return this.updateCourse(courseId, { status: 'draft' });
  },

  async archiveCourse(courseId: string) {
    return this.updateCourse(courseId, { status: 'archived' });
  },
};

// Module Service
export const moduleService = {
  async getCourseModules(courseId: string) {
    const { data, error } = await supabase
      .from(tables.modules)
      .select('*')
      .eq('course_id', courseId)
      .order('order_index');
    
    if (error) throw error;
    return data as Module[];
  },

  async createModule(module: Partial<Module>) {
    const { data, error } = await supabase
      .from(tables.modules)
      .insert([module])
      .select()
      .single();
    
    if (error) throw error;
    return data as Module;
  },

  async updateModule(moduleId: string, updates: Partial<Module>) {
    const { data, error } = await supabase
      .from(tables.modules)
      .update(updates)
      .eq('id', moduleId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Module;
  },

  async deleteModule(moduleId: string) {
    const { error } = await supabase
      .from(tables.modules)
      .delete()
      .eq('id', moduleId);
    
    if (error) throw error;
  },

  async reorderModules(courseId: string, moduleIds: string[]) {
    const updates = moduleIds.map((id, index) => ({
      id,
      order_index: index,
    }));
    
    for (const update of updates) {
      await supabase
        .from(tables.modules)
        .update({ order_index: update.order_index })
        .eq('id', update.id);
    }
  },
};

// Lesson Service
export const lessonService = {
  async getModuleLessons(moduleId: string) {
    const { data, error } = await supabase
      .from(tables.lessons)
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index');
    
    if (error) throw error;
    return data as Lesson[];
  },

  async getLessonById(lessonId: string) {
    const { data, error } = await supabase
      .from(tables.lessons)
      .select('*')
      .eq('id', lessonId)
      .single();
    
    if (error) throw error;
    return data as Lesson;
  },

  async createLesson(lesson: Partial<Lesson>) {
    const { data, error } = await supabase
      .from(tables.lessons)
      .insert([lesson])
      .select()
      .single();
    
    if (error) throw error;
    return data as Lesson;
  },

  async updateLesson(lessonId: string, updates: Partial<Lesson>) {
    const { data, error } = await supabase
      .from(tables.lessons)
      .update(updates)
      .eq('id', lessonId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Lesson;
  },

  async deleteLesson(lessonId: string) {
    const { error } = await supabase
      .from(tables.lessons)
      .delete()
      .eq('id', lessonId);
    
    if (error) throw error;
  },

  async reorderLessons(moduleId: string, lessonIds: string[]) {
    const updates = lessonIds.map((id, index) => ({
      id,
      order_index: index,
    }));
    
    for (const update of updates) {
      await supabase
        .from(tables.lessons)
        .update({ order_index: update.order_index })
        .eq('id', update.id);
    }
  },
};

// Enrollment / Student Service
export const studentService = {
  async getCourseStudents(courseId: string) {
    const { data, error } = await supabase
      .from(tables.enrollments)
      .select('*, student:users!student_id(*)')
      .eq('course_id', courseId)
      .order('enrollment_date', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async getProviderStudents(providerId: string) {
    const { data, error } = await supabase
      .from(tables.enrollments)
      .select('*, course:courses(*), student:users!student_id(*)')
      .in('course_id', 
        await supabase.from(tables.courses).select('id').eq('provider_id', providerId).then(r => r.data?.map(c => c.id) || [])
      )
      .order('enrollment_date', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async updateEnrollmentProgress(enrollmentId: string, completionPercentage: number) {
    const { data, error } = await supabase
      .from(tables.enrollments)
      .update({ 
        completion_percentage: completionPercentage,
        lastAccessed: new Date().toISOString()
      })
      .eq('id', enrollmentId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Enrollment;
  },
};

// Exam Service
export const examService = {
  async getCourseExams(courseId: string) {
    const { data, error } = await supabase
      .from(tables.exams)
      .select('*')
      .eq('course_id', courseId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data as Exam[];
  },

  async getExamById(examId: string) {
    const { data, error } = await supabase
      .from(tables.exams)
      .select('*')
      .eq('id', examId)
      .single();
    
    if (error) throw error;
    return data as Exam;
  },

  async createExam(exam: Partial<Exam>) {
    const { data, error } = await supabase
      .from(tables.exams)
      .insert([exam])
      .select()
      .single();
    
    if (error) throw error;
    return data as Exam;
  },

  async updateExam(examId: string, updates: Partial<Exam>) {
    const { data, error } = await supabase
      .from(tables.exams)
      .update(updates)
      .eq('id', examId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Exam;
  },

  async deleteExam(examId: string) {
    const { error } = await supabase
      .from(tables.exams)
      .delete()
      .eq('id', examId);
    
    if (error) throw error;
  },

  async getExamQuestions(examId: string) {
    const { data, error } = await supabase
      .from(tables.examQuestions)
      .select('*')
      .eq('exam_id', examId)
      .order('order_index');
    
    if (error) throw error;
    return data as ExamQuestion[];
  },

  async createExamQuestion(question: Partial<ExamQuestion>) {
    const { data, error } = await supabase
      .from(tables.examQuestions)
      .insert([question])
      .select()
      .single();
    
    if (error) throw error;
    return data as ExamQuestion;
  },

  async updateExamQuestion(questionId: string, updates: Partial<ExamQuestion>) {
    const { data, error } = await supabase
      .from(tables.examQuestions)
      .update(updates)
      .eq('id', questionId)
      .select()
      .single();
    
    if (error) throw error;
    return data as ExamQuestion;
  },

  async deleteExamQuestion(questionId: string) {
    const { error } = await supabase
      .from(tables.examQuestions)
      .delete()
      .eq('id', questionId);
    
    if (error) throw error;
  },

  async submitExamResult(result: Partial<ExamResult>) {
    const { data, error } = await supabase
      .from(tables.examResults)
      .insert([result])
      .select()
      .single();
    
    if (error) throw error;
    return data as ExamResult;
  },

  async getStudentExamResults(studentId: string, examId: string) {
    const { data, error } = await supabase
      .from(tables.examResults)
      .select('*')
      .eq('student_id', studentId)
      .eq('exam_id', examId)
      .order('completed_at', { ascending: false });
    
    if (error) throw error;
    return data as ExamResult[];
  },
};

// Certificate Service
export const certificateService = {
  async getCourseCertificates(courseId: string) {
    const { data, error } = await supabase
      .from(tables.certificates)
      .select('*, student:users!student_id(*)')
      .eq('course_id', courseId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async getCertificateById(certificateId: string) {
    const { data, error } = await supabase
      .from(tables.certificates)
      .select('*')
      .eq('id', certificateId)
      .single();
    
    if (error) throw error;
    return data as Certificate;
  },

  async issueCertificate(certificate: Partial<Certificate>) {
    const { data, error } = await supabase
      .from(tables.certificates)
      .insert([certificate])
      .select()
      .single();
    
    if (error) throw error;
    return data as Certificate;
  },

  async revokeCertificate(certificateId: string) {
    const { data, error } = await supabase
      .from(tables.certificates)
      .update({ status: 'revoked' })
      .eq('id', certificateId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Certificate;
  },

  async getProviderTemplates(providerId: string) {
    const { data, error } = await supabase
      .from(tables.certificateTemplates)
      .select('*')
      .eq('provider_id', providerId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data as CertificateTemplate[];
  },

  async createTemplate(template: Partial<CertificateTemplate>) {
    const { data, error } = await supabase
      .from(tables.certificateTemplates)
      .insert([template])
      .select()
      .single();
    
    if (error) throw error;
    return data as CertificateTemplate;
  },

  async updateTemplate(templateId: string, updates: Partial<CertificateTemplate>) {
    const { data, error } = await supabase
      .from(tables.certificateTemplates)
      .update(updates)
      .eq('id', templateId)
      .select()
      .single();
    
    if (error) throw error;
    return data as CertificateTemplate;
  },
};

// Payment Service
export const paymentService = {
  async getProviderPayments(providerId: string) {
    const { data, error } = await supabase
      .from(tables.payments)
      .select('*, student:users!student_id(*), course:courses(*)')
      .eq('provider_id', providerId)
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async getPendingPayments(providerId: string) {
    const { data, error } = await supabase
      .from(tables.payments)
      .select('*, student:users!student_id(*), course:courses(*)')
      .eq('provider_id', providerId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async verifyPayment(paymentId: string, status: 'completed' | 'failed', rejectionReason?: string) {
    const { data, error } = await supabase
      .from(tables.payments)
      .update({ 
        status,
        verified_by: (await supabase.auth.getUser()).data.user?.id,
        verified_at: new Date().toISOString(),
        rejection_reason: rejectionReason
      })
      .eq('id', paymentId)
      .select()
      .single();
    
    if (error) throw error;
    return data as Payment;
  },

  async createPayment(payment: Partial<Payment>) {
    const { data, error } = await supabase
      .from(tables.payments)
      .insert([payment])
      .select()
      .single();
    
    if (error) throw error;
    return data as Payment;
  },

  async getPaymentSettings(providerId: string) {
    const { data, error } = await supabase
      .from(tables.paymentSettings)
      .select('*')
      .eq('provider_id', providerId)
      .single();
    
    if (error) throw error;
    return data as PaymentSettings;
  },

  async updatePaymentSettings(providerId: string, settings: Partial<PaymentSettings>) {
    const existing = await this.getPaymentSettings(providerId);
    
    if (existing) {
      const { data, error } = await supabase
        .from(tables.paymentSettings)
        .update(settings)
        .eq('provider_id', providerId)
        .select()
        .single();
      
      if (error) throw error;
      return data as PaymentSettings;
    } else {
      const { data, error } = await supabase
        .from(tables.paymentSettings)
        .insert([{ ...settings, providerId }])
        .select()
        .single();
      
      if (error) throw error;
      return data as PaymentSettings;
    }
  },
};

// Settings Service
export const settingsService = {
  async getAppSettings(providerId: string) {
    const { data, error } = await supabase
      .from(tables.appSettings)
      .select('*')
      .eq('provider_id', providerId)
      .single();
    
    if (error) throw error;
    return data as AppSettings;
  },

  async updateAppSettings(providerId: string, settings: Partial<AppSettings>) {
    const existing = await this.getAppSettings(providerId);
    
    if (existing) {
      const { data, error } = await supabase
        .from(tables.appSettings)
        .update(settings)
        .eq('provider_id', providerId)
        .select()
        .single();
      
      if (error) throw error;
      return data as AppSettings;
    } else {
      const { data, error } = await supabase
        .from(tables.appSettings)
        .insert([{ ...settings, providerId }])
        .select()
        .single();
      
      if (error) throw error;
      return data as AppSettings;
    }
  },
};

// Notification Service
export const notificationService = {
  async getUserNotifications(userId: string) {
    const { data, error } = await supabase
      .from(tables.notifications)
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(50);
    
    if (error) throw error;
    return data;
  },

  async createNotification(notification: { userId: string; title: string; message: string; type: 'info' | 'success' | 'warning' | 'error' }) {
    const { data, error } = await supabase
      .from(tables.notifications)
      .insert([{ ...notification, user_id: notification.userId }])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async markAsRead(notificationId: string) {
    const { error } = await supabase
      .from(tables.notifications)
      .update({ is_read: true })
      .eq('id', notificationId);
    
    if (error) throw error;
  },
};

// User Service
export const userService = {
  async getUserById(userId: string) {
    const { data, error } = await supabase
      .from(tables.users)
      .select('*')
      .eq('id', userId)
      .single();
    
    if (error) throw error;
    return data as User;
  },

  async updateUser(userId: string, updates: Partial<User>) {
    const { data, error } = await supabase
      .from(tables.users)
      .update(updates)
      .eq('id', userId)
      .select()
      .single();
    
    if (error) throw error;
    return data as User;
  },

  async searchStudents(providerId: string, query: string) {
    const { data, error } = await supabase
      .from(tables.enrollments)
      .select('*, student:users!student_id(*), course:courses(*)')
      .in('course_id', 
        await supabase.from(tables.courses).select('id').eq('provider_id', providerId).then(r => r.data?.map(c => c.id) || [])
      )
      .or(`student.full_name.ilike.%${query}%,student.email.ilike.%${query}%`)
      .order('enrollment_date', { ascending: false });
    
    if (error) throw error;
    return data;
  },

  async getStudentDetails(studentId: string) {
    const { data: student, error: studentError } = await supabase
      .from(tables.users)
      .select('*')
      .eq('id', studentId)
      .single();

    if (studentError) throw studentError;

    // Get enrollments
    const { data: enrollments } = await supabase
      .from(tables.enrollments)
      .select('*, course:courses(*)')
      .eq('student_id', studentId);

    // Get exam results
    const { data: examResults } = await supabase
      .from(tables.examResults)
      .select('*, exam:exams(*)')
      .eq('student_id', studentId);

    // Get certificates
    const { data: certificates } = await supabase
      .from(tables.certificates)
      .select('*, course:courses(*)')
      .eq('student_id', studentId);

    return {
      student,
      enrollments,
      examResults,
      certificates,
    };
  },
};

// Storage/Upload Service
export const storageService = {
  async uploadFile(
    bucket: string, 
    file: File, 
    folder: string,
    onProgress?: (progress: number) => void
  ): Promise<string> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const fileName = `${folder}/${Date.now()}_${file.name}`;
    
    // For files under 6MB, use simple upload
    if (file.size < 6 * 1024 * 1024) {
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (error) throw error;
      
      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);
      
      return publicUrl;
    }
    
    // For larger files, use chunked upload
    const chunkSize = 6 * 1024 * 1024; // 6MB chunks
    const chunks = Math.ceil(file.size / chunkSize);
    let uploadedChunks = 0;

    for (let i = 0; i < chunks; i++) {
      const start = i * chunkSize;
      const end = Math.min(start + chunkSize, file.size);
      const chunk = file.slice(start, end);
      
      const { error } = await supabase.storage
        .from(bucket)
        .upload(`${fileName}_part${i}`, chunk, {
          cacheControl: '3600',
          upsert: true,
        });

      if (error) throw error;
      
      uploadedChunks++;
      onProgress?.(Math.round((uploadedChunks / chunks) * 100));
    }

    // For simplicity, return the base file path (in production, you'd compose the chunks)
    const { data: { publicUrl } } = supabase.storage
      .from(bucket)
      .getPublicUrl(fileName);
    
    return publicUrl;
  },

  async deleteFile(bucket: string, filePath: string) {
    const fileName = filePath.split('/').slice(-2).join('/');
    const { error } = await supabase.storage
      .from(bucket)
      .remove([fileName]);

    if (error) throw error;
  },

  getBucketUrl(bucket: string, fileName: string) {
    const { data: { publicUrl } } = supabase.storage
      .from(bucket)
      .getPublicUrl(fileName);
    return publicUrl;
  },
};

// Financial Service
export const financialService = {
  async getProviderStats(providerId: string) {
    // Get completed payments
    const { data: completedPayments } = await supabase
      .from(tables.payments)
      .select('amount, currency')
      .eq('provider_id', providerId)
      .eq('status', 'completed');

    const totalRevenue = completedPayments?.reduce((sum, p) => sum + (p.amount || 0), 0) || 0;

    // Get pending payments
    const { data: pendingPayments } = await supabase
      .from(tables.payments)
      .select('amount')
      .eq('provider_id', providerId)
      .eq('status', 'pending');

    const pendingAmount = pendingPayments?.reduce((sum, p) => sum + (p.amount || 0), 0) || 0;

    // Get student count
    const { data: enrollments } = await supabase
      .from(tables.enrollments)
      .select('id')
      .in('course_id',
        await supabase.from(tables.courses).select('id').eq('provider_id', providerId).then(r => r.data?.map(c => c.id) || [])
      );

    const studentCount = enrollments?.length || 0;

    // Get course count
    const { data: courses } = await supabase
      .from(tables.courses)
      .select('id')
      .eq('provider_id', providerId);

    const courseCount = courses?.length || 0;

    return {
      totalRevenue,
      pendingAmount,
      studentCount,
      courseCount,
    };
  },

  async getTransactionHistory(providerId: string, limit: number = 50) {
    const { data, error } = await supabase
      .from(tables.payments)
      .select('*, student:users!student_id(*), course:courses(*)')
      .eq('provider_id', providerId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data;
  },
};

// Exam Result Service
export const examResultService = {
  async submitExam(
    examId: string, 
    studentId: string, 
    answers: number[]
  ) {
    // Get exam questions
    const { data: questions } = await supabase
      .from(tables.examQuestions)
      .select('*')
      .eq('exam_id', examId)
      .order('order_index');

    if (!questions) throw new Error('No questions found');

    // Get exam info
    const { data: exam } = await supabase
      .from(tables.exams)
      .select('*')
      .eq('id', examId)
      .single();

    if (!exam) throw new Error('Exam not found');

    // Check attempt count
    const { data: existingResults } = await supabase
      .from(tables.examResults)
      .select('attempt_number')
      .eq('exam_id', examId)
      .eq('student_id', studentId)
      .order('attempt_number', { ascending: false })
      .limit(1);

    const attemptNumber = (existingResults?.[0]?.attempt_number || 0) + 1;

    if (exam.max_attempts && attemptNumber > exam.max_attempts) {
      throw new Error('تجاوزت عدد المحاولات المسموحة');
    }

    // Calculate score
    let correctAnswers = 0;
    questions.forEach((q, index) => {
      if (answers[index] === q.correct_option) {
        correctAnswers++;
      }
    });

    const score = Math.round((correctAnswers / questions.length) * 100);
    const passed = score >= exam.passing_score;

    // Save result
    const { data, error } = await supabase
      .from(tables.examResults)
      .insert({
        exam_id: examId,
        student_id: studentId,
        score,
        passed,
        attempt_number: attemptNumber,
        answers,
        completed_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;

    // Auto-issue certificate if passed and first attempt
    if (passed && attemptNumber === 1 && exam.auto_certificate) {
      await certificateService.issueCertificate({
        course_id: exam.course_id,
        student_id: studentId,
        provider_id: (await supabase.auth.getUser()).data.user?.id || '',
        certificate_number: `CRT-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).substring(2, 6).toUpperCase()}`,
        issue_date: new Date().toISOString(),
        status: 'issued',
      });
    }

    return data;
  },

  async getStudentResults(studentId: string) {
    const { data, error } = await supabase
      .from(tables.examResults)
      .select('*, exam:exams(*)')
      .eq('student_id', studentId)
      .order('completed_at', { ascending: false });

    if (error) throw error;
    return data;
  },
};