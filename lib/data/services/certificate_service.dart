import 'package:course_provider/data/services/supabase_service.dart';

import '../models/certificate.dart';
import '../../core/config/supabase_config.dart';

/// خدمة إدارة الشهادات
class CertificateService {
  final SupabaseService _supabaseService = SupabaseService();

  /// الحصول على شهادات الطالب
  Future<List<Certificate>> getStudentCertificates(String studentId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.certificatesTable,
        filters: {'student_id': studentId},
        orderBy: 'issue_date',
        ascending: false,
      );
      return data.map((e) => Certificate.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على شهادات الكورس
  Future<List<Certificate>> getCourseCertificates(String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.certificatesTable,
        filters: {'course_id': courseId},
        orderBy: 'issue_date',
        ascending: false,
      );
      return data.map((e) => Certificate.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على شهادات مقدم الخدمة
  Future<List<Certificate>> getProviderCertificates(String providerId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.certificatesTable,
        filters: {'provider_id': providerId},
        orderBy: 'issue_date',
        ascending: false,
      );
      return data.map((e) => Certificate.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// الحصول على شهادة واحدة
  Future<Certificate?> getCertificate(String certificateId) async {
    try {
      final data = await _supabaseService.getOne(
        SupabaseConfig.certificatesTable,
        certificateId,
      );
      if (data == null) return null;
      return Certificate.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على شهادة برقم الشهادة
  Future<Certificate?> getCertificateByNumber(String certificateNumber) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.certificatesTable,
        filters: {'certificate_number': certificateNumber},
        limit: 1,
      );
      if (data.isEmpty) return null;
      return Certificate.fromJson(data[0]);
    } catch (e) {
      return null;
    }
  }

  /// إصدار شهادة
  Future<Certificate?> issueCertificate({
    required String courseId,
    required String studentId,
    required String providerId,
    Map<String, dynamic>? templateDesign,
  }) async {
    try {
      // توليد رقم شهادة فريد
      final certificateNumber = _generateCertificateNumber();

      final data = await _supabaseService.insert(
        SupabaseConfig.certificatesTable,
        {
          'course_id': courseId,
          'student_id': studentId,
          'provider_id': providerId,
          'certificate_number': certificateNumber,
          'template_design': templateDesign,
        },
      );
      return Certificate.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// إصدار شهادات متعددة
  Future<List<Certificate>> issueCertificates({
    required String courseId,
    required List<String> studentIds,
    required String providerId,
    Map<String, dynamic>? templateDesign,
  }) async {
    final certificates = <Certificate>[];
    for (final studentId in studentIds) {
      final cert = await issueCertificate(
        courseId: courseId,
        studentId: studentId,
        providerId: providerId,
        templateDesign: templateDesign,
      );
      if (cert != null) {
        certificates.add(cert);
      }
    }
    return certificates;
  }

  /// إلغاء شهادة
  Future<bool> revokeCertificate(String certificateId) async {
    try {
      await _supabaseService.update(
        SupabaseConfig.certificatesTable,
        certificateId,
        {'status': 'revoked'},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من وجود شهادة للطالب في الكورس
  Future<bool> hasCertificate(String studentId, String courseId) async {
    try {
      final data = await _supabaseService.query(
        SupabaseConfig.certificatesTable,
        filters: {
          'student_id': studentId,
          'course_id': courseId,
        },
      );
      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على عدد الشهادات
  Future<int> getCertificatesCount(String providerId) async {
    try {
      return await _supabaseService.count(
        SupabaseConfig.certificatesTable,
        filters: {'provider_id': providerId},
      );
    } catch (e) {
      return 0;
    }
  }

  /// توليد رقم شهادة فريد
  String _generateCertificateNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'WASLA-$timestamp-$random';
  }
}
