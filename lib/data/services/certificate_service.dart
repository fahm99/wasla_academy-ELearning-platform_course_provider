import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/certificate/certificate.dart';

class CertificateService {
  final SupabaseClient _supabase;

  CertificateService(this._supabase);

  /// جلب الطلاب المؤهلين للحصول على الشهادة
  Future<List<EligibleStudent>> getEligibleStudents(String courseId) async {
    try {
      final result = await _supabase.rpc('get_eligible_students', params: {
        'p_course_id': courseId,
      });

      if (result == null) return [];

      return (result as List)
          .map((e) => EligibleStudent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting eligible students: $e');
      return [];
    }
  }

  /// إصدار شهادة لطالب واحد
  Future<Certificate?> issueCertificate({
    required String courseId,
    required String studentId,
    required String providerId,
    String? logoUrl,
    String? signatureUrl,
    String? customColor,
    String? grade,
  }) async {
    try {
      // التحقق من الأهلية
      final isEligible =
          await _supabase.rpc('check_student_eligibility', params: {
        'p_student_id': studentId,
        'p_course_id': courseId,
      });

      if (isEligible != true) {
        throw Exception('الطالب غير مؤهل للحصول على الشهادة');
      }

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

      // جلب تاريخ الإكمال
      final enrollment = await _supabase
          .from('enrollments')
          .select('completed_at')
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .single();

      // توليد رقم الشهادة
      final certificateNumber = _generateCertificateNumber();

      // إنشاء الشهادة
      final certificate = await _supabase.from('certificates').insert({
        'course_id': courseId,
        'student_id': studentId,
        'provider_id': providerId,
        'certificate_number': certificateNumber,
        'issue_date': DateTime.now().toIso8601String(),
        'completion_date': enrollment['completed_at'],
        'provider_logo_url': logoUrl,
        'provider_signature_url': signatureUrl,
        'custom_color': customColor ?? '#1E3A8A',
        'grade': grade,
        'auto_issue': false,
        'status': 'issued',
      }).select('''
            *,
            courses(id, title),
            users!certificates_student_id_fkey(id, name, email)
          ''').single();

      // إرسال إشعار للطالب
      await _supabase.from('notifications').insert({
        'user_id': studentId,
        'title': 'تم إصدار شهادتك',
        'message': 'تهانينا! تم إصدار شهادة إتمام الكورس',
        'type': 'certificate',
        'related_id': certificate['id'],
      });

      return Certificate.fromJson(certificate);
    } catch (e) {
      print('Error issuing certificate: $e');
      return null;
    }
  }

  /// إصدار شهادات لعدة طلاب
  Future<Map<String, dynamic>> issueCertificates({
    required String courseId,
    required List<String> studentIds,
    required String providerId,
    String? logoUrl,
    String? signatureUrl,
    String? customColor,
  }) async {
    final certificates = <Certificate>[];
    final errors = <String, String>{};

    for (final studentId in studentIds) {
      try {
        final certificate = await issueCertificate(
          courseId: courseId,
          studentId: studentId,
          providerId: providerId,
          logoUrl: logoUrl,
          signatureUrl: signatureUrl,
          customColor: customColor,
        );

        if (certificate != null) {
          certificates.add(certificate);
        } else {
          errors[studentId] = 'فشل إصدار الشهادة';
        }
      } catch (e) {
        errors[studentId] = e.toString();
      }
    }

    return {
      'success': certificates,
      'errors': errors,
      'total': studentIds.length,
      'issued': certificates.length,
      'failed': errors.length,
    };
  }

  /// جلب شهادات كورس معين
  Future<List<Certificate>> getCourseCertificates(String courseId) async {
    try {
      final certificates = await _supabase.from('certificates').select('''
            *,
            users!certificates_student_id_fkey(id, name, email, avatar_url),
            courses(id, title)
          ''').eq('course_id', courseId).order('issue_date', ascending: false);

      return (certificates as List)
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting course certificates: $e');
      return [];
    }
  }

  /// جلب شهادة طالب معين في كورس معين
  Future<Certificate?> getStudentCertificate({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final certificate = await _supabase
          .from('certificates')
          .select('''
            *,
            courses(id, title, description),
            users!certificates_student_id_fkey(id, name, email)
          ''')
          .eq('course_id', courseId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (certificate == null) return null;
      return Certificate.fromJson(certificate);
    } catch (e) {
      print('Error getting student certificate: $e');
      return null;
    }
  }

  /// إلغاء شهادة
  Future<bool> revokeCertificate(String certificateId) async {
    try {
      await _supabase
          .from('certificates')
          .update({'status': 'revoked'}).eq('id', certificateId);
      return true;
    } catch (e) {
      print('Error revoking certificate: $e');
      return false;
    }
  }

  /// استعادة شهادة ملغاة
  Future<bool> restoreCertificate(String certificateId) async {
    try {
      await _supabase
          .from('certificates')
          .update({'status': 'issued'}).eq('id', certificateId);
      return true;
    } catch (e) {
      print('Error restoring certificate: $e');
      return false;
    }
  }

  /// جلب جميع شهادات مقدم الخدمة
  Future<List<Certificate>> getProviderCertificates(String providerId) async {
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

      return (certificates as List)
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting provider certificates: $e');
      return [];
    }
  }

  /// التحقق من صحة شهادة برقمها
  Future<Certificate?> verifyCertificate(String certificateNumber) async {
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

      if (certificate == null) return null;
      return Certificate.fromJson(certificate);
    } catch (e) {
      print('Error verifying certificate: $e');
      return null;
    }
  }

  /// حفظ إعدادات الشهادة للكورس
  Future<bool> saveCertificateSettings({
    required String courseId,
    required CertificateSettings settings,
  }) async {
    try {
      await _supabase.from('courses').update({
        'certificate_auto_issue': settings.autoIssue,
        'certificate_logo_url': settings.logoUrl,
        'certificate_signature_url': settings.signatureUrl,
        'certificate_custom_color': settings.customColor,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courseId);

      return true;
    } catch (e) {
      print('Error saving certificate settings: $e');
      return false;
    }
  }

  /// جلب إعدادات الشهادة للكورس
  Future<CertificateSettings?> getCertificateSettings(String courseId) async {
    try {
      final course = await _supabase.from('courses').select('''
            id,
            certificate_auto_issue,
            certificate_logo_url,
            certificate_signature_url,
            certificate_custom_color
          ''').eq('id', courseId).single();

      return CertificateSettings.fromJson(course);
    } catch (e) {
      print('Error getting certificate settings: $e');
      return null;
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

  /// حذف شهادة
  Future<bool> deleteCertificate(String certificateId) async {
    try {
      await _supabase.from('certificates').delete().eq('id', certificateId);
      return true;
    } catch (e) {
      print('Error deleting certificate: $e');
      return false;
    }
  }
}
