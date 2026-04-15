import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Table names
export const tables = {
  users: 'users',
  courses: 'courses',
  modules: 'modules',
  lessons: 'lessons',
  lessonResources: 'lesson_resources',
  enrollments: 'enrollments',
  lessonProgress: 'lesson_progress',
  exams: 'exams',
  examQuestions: 'exam_questions',
  examResults: 'exam_results',
  certificates: 'certificates',
  certificateTemplates: 'certificate_templates',
  payments: 'payments',
  paymentSettings: 'payment_settings',
  appSettings: 'app_settings',
  notifications: 'notifications',
} as const;