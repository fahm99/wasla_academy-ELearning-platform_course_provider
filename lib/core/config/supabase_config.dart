// Supabase Configuration
class SupabaseConfig {
  // استبدل هذه القيم ببيانات مشروعك على Supabase
  static const String supabaseUrl = 'https://hmgisljihrsztskvmbfd.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_-ZiqWMN8A8uZdjO6S0prlQ_6GVN6my8';

  // معرفات الجداول
  static const String usersTable = 'users';
  static const String coursesTable = 'courses';
  static const String modulesTable = 'modules';
  static const String lessonsTable = 'lessons';
  static const String lessonResourcesTable = 'lesson_resources';
  static const String enrollmentsTable = 'enrollments';
  static const String lessonProgressTable = 'lesson_progress';
  static const String examsTable = 'exams';
  static const String examQuestionsTable = 'exam_questions';
  static const String examResultsTable = 'exam_results';
  static const String certificatesTable = 'certificates';
  static const String paymentsTable = 'payments';
  static const String notificationsTable = 'notifications';
  static const String reviewsTable = 'reviews';
  static const String appSettingsTable = 'app_settings';

  // معرفات Buckets
  static const String videosBucket = 'course-videos';
  static const String filesBucket = 'course-files';
  static const String imagesBucket = 'course-images';
  static const String certificatesBucket = 'certificates';
  static const String avatarsBucket = 'avatars';
}
