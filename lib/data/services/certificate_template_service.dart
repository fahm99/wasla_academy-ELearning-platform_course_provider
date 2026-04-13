import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/certificate/certificate_template.dart';

class CertificateTemplateService {
  final SupabaseClient _supabase;

  CertificateTemplateService(this._supabase);

  /// جلب جميع قوالب المقدم
  Future<List<CertificateTemplate>> getProviderTemplates(
      String providerId) async {
    try {
      final response = await _supabase
          .from('certificate_templates')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CertificateTemplate.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في جلب القوالب: $e');
      return [];
    }
  }

  /// جلب قالب معين
  Future<CertificateTemplate?> getTemplate(String templateId) async {
    try {
      final response = await _supabase
          .from('certificate_templates')
          .select()
          .eq('id', templateId)
          .single();

      return CertificateTemplate.fromJson(response);
    } catch (e) {
      print('خطأ في جلب القالب: $e');
      return null;
    }
  }

  /// جلب القالب الافتراضي
  Future<CertificateTemplate?> getDefaultTemplate(String providerId,
      {String? courseId}) async {
    try {
      var query = _supabase
          .from('certificate_templates')
          .select()
          .eq('provider_id', providerId)
          .eq('is_default', true);

      if (courseId != null) {
        query = query.eq('course_id', courseId);
      }

      final response = await query.maybeSingle();

      if (response != null) {
        return CertificateTemplate.fromJson(response);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب القالب الافتراضي: $e');
      return null;
    }
  }

  /// حفظ قالب جديد
  Future<CertificateTemplate?> createTemplate(
      CertificateTemplate template) async {
    try {
      final data = template.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      // إذا كان القالب افتراضي، إلغاء الافتراضية من القوالب الأخرى
      if (template.isDefault) {
        await _supabase.from('certificate_templates').update(
            {'is_default': false}).eq('provider_id', template.providerId);
      }

      final response = await _supabase
          .from('certificate_templates')
          .insert(data)
          .select()
          .single();

      return CertificateTemplate.fromJson(response);
    } catch (e) {
      print('خطأ في إنشاء القالب: $e');
      rethrow;
    }
  }

  /// تحديث قالب
  Future<CertificateTemplate?> updateTemplate(
      CertificateTemplate template) async {
    try {
      final data = template.toJson();
      data.remove('id');
      data.remove('provider_id');
      data.remove('created_at');

      // إذا كان القالب افتراضي، إلغاء الافتراضية من القوالب الأخرى
      if (template.isDefault) {
        await _supabase
            .from('certificate_templates')
            .update({'is_default': false})
            .eq('provider_id', template.providerId)
            .neq('id', template.id);
      }

      final response = await _supabase
          .from('certificate_templates')
          .update(data)
          .eq('id', template.id)
          .select()
          .single();

      return CertificateTemplate.fromJson(response);
    } catch (e) {
      print('خطأ في تحديث القالب: $e');
      rethrow;
    }
  }

  /// حذف قالب
  Future<bool> deleteTemplate(String templateId) async {
    try {
      await _supabase
          .from('certificate_templates')
          .delete()
          .eq('id', templateId);
      return true;
    } catch (e) {
      print('خطأ في حذف القالب: $e');
      return false;
    }
  }

  /// تعيين قالب كافتراضي
  Future<bool> setDefaultTemplate(String templateId, String providerId) async {
    try {
      // إلغاء الافتراضية من جميع القوالب
      await _supabase
          .from('certificate_templates')
          .update({'is_default': false}).eq('provider_id', providerId);

      // تعيين القالب الجديد كافتراضي
      await _supabase
          .from('certificate_templates')
          .update({'is_default': true}).eq('id', templateId);

      return true;
    } catch (e) {
      print('خطأ في تعيين القالب الافتراضي: $e');
      return false;
    }
  }
}
