// User types
export interface User {
  id: string;
  email: string;
  full_name: string;
  role: 'provider' | 'student';
  phone?: string;
  avatar_url?: string;
  bio?: string;
  organization_name?: string;
  created_at: string;
}

// Course types
export type CourseStatus = 'draft' | 'pendingReview' | 'published' | 'archived';
export type CourseLevel = 'beginner' | 'intermediate' | 'advanced';

export interface Course {
  id: string;
  title: string;
  description: string;
  provider_id: string;
  category?: string;
  level?: CourseLevel;
  price: number;
  currency: string;
  duration_hours?: number;
  thumbnail_url?: string;
  cover_image_url?: string;
  status: CourseStatus;
  students_count: number;
  rating: number;
  reviews_count: number;
  is_featured: boolean;
  created_at: string;
  updated_at: string;
}

// Module types
export interface Module {
  id: string;
  course_id: string;
  title: string;
  description?: string;
  order_index: number;
  created_at: string;
}

// Lesson types
export type LessonType = 'video' | 'file' | 'text' | 'link';

export interface Lesson {
  id: string;
  module_id: string;
  course_id: string;
  title: string;
  description?: string;
  type: LessonType;
  content?: string;
  video_url?: string;
  file_url?: string;
  link_url?: string;
  duration?: number;
  order_index: number;
  is_free?: boolean;
  created_at: string;
}

// Lesson Resource types
export interface LessonResource {
  id: string;
  lesson_id: string;
  title: string;
  type: string;
  url: string;
  created_at: string;
}

// Enrollment types
export type EnrollmentStatus = 'active' | 'completed' | 'dropped';

export interface Enrollment {
  id: string;
  student_id: string;
  course_id: string;
  enrollment_date: string;
  completion_percentage: number;
  status: EnrollmentStatus;
  last_accessed?: string;
  certificate_id?: string;
}

// Exam types
export interface Exam {
  id: string;
  course_id: string;
  title: string;
  description?: string;
  duration: number;
  passing_score: number;
  max_attempts: number;
  auto_certificate?: boolean;
  created_at: string;
}

// Exam Question types
export type QuestionType = 'mcq' | 'trueFalse';

export interface ExamQuestion {
  id: string;
  exam_id: string;
  question: string;
  options: string[];
  correct_option: number;
  question_type?: QuestionType;
  order_index: number;
}

// Exam Result types
export interface ExamResult {
  id: string;
  exam_id: string;
  student_id: string;
  score: number;
  passed: boolean;
  attempt_number: number;
  answers: number[];
  completed_at: string;
}

// Certificate types
export type CertificateStatus = 'issued' | 'revoked';

export interface Certificate {
  id: string;
  course_id: string;
  student_id: string;
  provider_id: string;
  certificate_number: string;
  issue_date: string;
  expiry_date?: string;
  template_design?: Record<string, unknown>;
  certificate_url?: string;
  status: CertificateStatus;
  created_at: string;
}

// Certificate Template types
export interface CertificateTemplate {
  id: string;
  provider_id: string;
  name: string;
  background_color: string;
  border_color: string;
  border_width: number;
  logo_url?: string;
  signature_url?: string;
  organization_name: string;
  created_at: string;
}

// Payment types
export type PaymentMethod = 'wallet' | 'bankTransfer';
export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';

export interface Payment {
  id: string;
  student_id: string;
  course_id: string;
  provider_id: string;
  amount: number;
  currency: string;
  payment_method: PaymentMethod;
  transaction_id?: string;
  transaction_reference?: string;
  receipt_image_url?: string;
  student_name?: string;
  course_name?: string;
  status: PaymentStatus;
  payment_date?: string;
  verified_by?: string;
  verified_at?: string;
  rejection_reason?: string;
  created_at: string;
}

// Payment Settings types
export interface PaymentSettings {
  id: string;
  provider_id: string;
  wallet_number: string;
  wallet_owner: string;
  bank_account?: string;
  bank_name?: string;
  created_at: string;
}

// App Settings types
export interface AppSettings {
  id: string;
  provider_id: string;
  organization_name: string;
  logo_url?: string;
  primary_color: string;
  contact_email?: string;
  contact_phone?: string;
  created_at: string;
}

// Lesson Progress types
export interface LessonProgress {
  id: string;
  lesson_id: string;
  student_id: string;
  is_completed: boolean;
  watch_time?: number;
  completed_at?: string;
  created_at: string;
}

// Notification types
export interface Notification {
  id: string;
  user_id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  is_read: boolean;
  created_at: string;
}