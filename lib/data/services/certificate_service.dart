import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CertificateService {
  final SupabaseClient _supabase;

  CertificateService(this._supabase);

  /// إصدار شهادة لطالب واحد
  Future<Map<String, dynamic>> issueCertificate({
    required String courseId,
    required String studentId,
    required String providerId,
    Map<String, dynamic>? templateDesign,
  }) async {
    try {
      // توليد رقم الشهادة
      final certificateNumber = _generateCertificateNumber();

      // التحقق من عدم وجود شهادة سابقة
      final existing = await _supabase
          .from('certificates')
          .select()
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('الطالب لديه شهادة مسبقة لهذا الكورس');
      }

      // إنشاء الشهادة
      final certificate = await _supabase
          .from('certificates')
          .insert({
            'course_id': courseId,
            'student_id': studentId,
            'provider_id': providerId,
            'certificate_number': certificateNumber,
            'issue_date': DateTime.now().toIso8601String(),
            'template_design': templateDesign,
            'status': 'issued',
          })
          .select()
          .single();

      // تحديث عدد الشهادات للطالب
      await _supabase.rpc('increment_student_certificates', params: {
        'student_id': studentId,
      });

      // إرسال إشعار للطالب
      await _supabase.from('notifications').insert({
        'user_id': studentId,
        'title': 'تم إصدار شهادتك',
        'message': 'تهانينا! تم إصدار شهادة إتمام الكورس',
        'type': 'certificate',
        'related_id': certificate['id'],
      });

      return certificate;
    } catch (e) {
      throw Exception('فشل إصدار الشهادة: $e');
    }
  }

  /// إصدار شهادات لعدة طلاب
  Future<List<Map<String, dynamic>>> issueCertificates({
    required String courseId,
    required List<String> studentIds,
    required String providerId,
    Map<String, dynamic>? templateDesign,
  }) async {
    final certificates = <Map<String, dynamic>>[];
    final errors = <String>[];

    for (final studentId in studentIds) {
      try {
        final certificate = await issueCertificate(
          courseId: courseId,
          studentId: studentId,
          providerId: providerId,
          templateDesign: templateDesign,
        );
        certificates.add(certificate);
      } catch (e) {
        errors.add('خطأ في إصدار شهادة للطالب $studentId: $e');
      }
    }

    if (errors.isNotEmpty) {
      print('أخطاء في إصدار الشهادات: ${errors.join(', ')}');
    }

    return certificates;
  }

  /// جلب شهادات كورس معين
  Future<List<Map<String, dynamic>>> getCourseCertificates(
      String courseId) async {
    try {
      final certificates = await _supabase.from('certificates').select('''
            *,
            users!certificates_student_id_fkey(id, name, email, avatar_url),
            courses(id, title)
          ''').eq('course_id', courseId).order('issue_date', ascending: false);

      return List<Map<String, dynamic>>.from(certificates);
    } catch (e) {
      throw Exception('فشل جلب الشهادات: $e');
    }
  }

  /// جلب شهادة طالب معين في كورس معين
  Future<Map<String, dynamic>?> getStudentCertificate({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final certificate = await _supabase
          .from('certificates')
          .select('''
            *,
            courses(id, title, description),
            users!certificates_provider_id_fkey(id, name)
          ''')
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .maybeSingle();

      return certificate;
    } catch (e) {
      throw Exception('فشل جلب الشهادة: $e');
    }
  }

  /// إلغاء شهادة
  Future<void> revokeCertificate(String certificateId) async {
    try {
      await _supabase
          .from('certificates')
          .update({'status': 'revoked'}).eq('id', certificateId);
    } catch (e) {
      throw Exception('فشل إلغاء الشهادة: $e');
    }
  }

  /// استعادة شهادة ملغاة
  Future<void> restoreCertificate(String certificateId) async {
    try {
      await _supabase
          .from('certificates')
          .update({'status': 'issued'}).eq('id', certificateId);
    } catch (e) {
      throw Exception('فشل استعادة الشهادة: $e');
    }
  }

  /// جلب جميع شهادات مقدم الخدمة
  Future<List<Map<String, dynamic>>> getProviderCertificates(
      String providerId) async {
    try {
      final certificates = await _supabase
          .from('certificates')
          .select('''
            *,
            users!certificates_student_id_fkey(id, name, email, avatar_url),
            courses(id, title)
          ''')
          .eq('provider_id', providerId)
          .order('issue_date', ascending: false);

      return List<Map<String, dynamic>>.from(certificates);
    } catch (e) {
      throw Exception('فشل جلب الشهادات: $e');
    }
  }

  /// التحقق من صحة شهادة برقمها
  Future<Map<String, dynamic>?> verifyCertificate(
      String certificateNumber) async {
    try {
      final certificate = await _supabase
          .from('certificates')
          .select('''
            *,
            users!certificates_student_id_fkey(id, name, email),
            courses(id, title),
            users!certificates_provider_id_fkey(id, name)
          ''')
          .eq('certificate_number', certificateNumber)
          .eq('status', 'issued')
          .maybeSingle();

      return certificate;
    } catch (e) {
      throw Exception('فشل التحقق من الشهادة: $e');
    }
  }

  /// توليد رقم شهادة فريد
  String _generateCertificateNumber() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final timeFormat = DateFormat('HHmmss');
    final random = DateTime.now().millisecondsSinceEpoch % 10000;

    return 'CERT-${dateFormat.format(now)}-${timeFormat.format(now)}-$random';
  }

  /// حفظ قالب شهادة
  Future<void> saveCertificateTemplate({
    required String courseId,
    required Map<String, dynamic> templateDesign,
  }) async {
    try {
      await _supabase.from('courses').update({
        'certificate_template': templateDesign,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courseId);
    } catch (e) {
      throw Exception('فشل حفظ قالب الشهادة: $e');
    }
  }

  /// جلب قالب شهادة الكورس
  Future<Map<String, dynamic>?> getCertificateTemplate(String courseId) async {
    try {
      final course = await _supabase
          .from('courses')
          .select('certificate_template')
          .eq('id', courseId)
          .single();

      return course['certificate_template'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('فشل جلب قالب الشهادة: $e');
    }
  }
}
