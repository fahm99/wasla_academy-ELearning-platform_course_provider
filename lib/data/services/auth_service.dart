import 'package:course_provider/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../../core/config/supabase_config.dart';

/// خدمة المصادقة
class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  /// التسجيل مع تحديد نوع المستخدم
  Future<Map<String, dynamic>> registerWithResult({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      // إنشاء الحساب في Supabase Authentication
      // الـ trigger سيُضيف السجل لجدول users تلقائياً
      final authResponse = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'user_type': userType,
        },
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'فشل في إنشاء الحساب'};
      }

      // إذا كان المستخدم لديه session (Email Confirmation معطّل)
      // نتحقق من وجود السجل في جدول users ونُضيفه يدوياً إذا لم يُنشئه الـ trigger بعد
      if (authResponse.session != null) {
        await _ensureUserRecord(
          userId: authResponse.user!.id,
          email: email,
          name: name,
          phone: phone,
          userType: userType,
        );
      }

      return {'success': true, 'message': 'تم إنشاء الحساب بنجاح'};
    } on AuthException catch (e) {
      String message = 'حدث خطأ في إنشاء الحساب';
      if (e.message.contains('already registered') ||
          e.message.contains('already been registered') ||
          e.message.contains('User already registered')) {
        message = 'البريد الإلكتروني مسجل مسبقاً';
      } else if (e.message.contains('weak_password') ||
          e.message.contains('Password should be')) {
        message = 'كلمة المرور ضعيفة جداً، يجب أن تكون 6 أحرف على الأقل';
      }
      // ignore: avoid_print
      print('[AuthService] AuthException: ${e.message}');
      return {'success': false, 'message': message};
    } catch (e) {
      // ignore: avoid_print
      print('[AuthService] registerWithResult error: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع: $e'};
    }
  }

  /// التأكد من وجود سجل المستخدم في جدول users (fallback إذا لم يعمل الـ trigger)
  Future<void> _ensureUserRecord({
    required String userId,
    required String email,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final existing = await _supabaseService.getOne(
        SupabaseConfig.usersTable,
        userId,
      );
      if (existing == null) {
        await _supabaseService.insert(
          SupabaseConfig.usersTable,
          {
            'id': userId,
            'email': email,
            'name': name,
            'phone': phone,
            'user_type': userType,
            'is_verified': false,
            'is_active': true,
          },
        );
      }
    } catch (e) {
      // نطبع الخطأ للتشخيص
      // ignore: avoid_print
      print('[AuthService] _ensureUserRecord error: $e');
    }
  }

  /// تسجيل الدخول مع رسالة خطأ مفصّلة
  Future<Map<String, dynamic>> loginWithResult({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse =
          await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'فشل في تسجيل الدخول'};
      }

      return {'success': true, 'message': 'تم تسجيل الدخول بنجاح'};
    } on AuthException catch (e) {
      String message = 'حدث خطأ في تسجيل الدخول';
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'يرجى تأكيد بريدك الإلكتروني أولاً';
      } else if (e.message.contains('Too many requests')) {
        message = 'محاولات كثيرة، يرجى الانتظار قليلاً';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      return {'success': true, 'message': 'تم إرسال رابط إعادة التعيين'};
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في إرسال الرابط'};
    }
  }

  /// تحديث كلمة المرور الجديدة
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return {'success': true, 'message': 'تم تحديث كلمة المرور بنجاح'};
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في تحديث كلمة المرور'};
    }
  }

  /// التسجيل (إنشاء حساب جديد) - للتوافق مع الكود القديم
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    final result = await registerWithResult(
      email: email,
      password: password,
      name: name,
      phone: phone,
      userType: userType,
    );
    return result['success'] as bool;
  }

  /// تسجيل الدخول - للتوافق مع الكود القديم
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final result = await loginWithResult(email: email, password: password);
    return result['success'] as bool;
  }

  /// تسجيل الخروج
  Future<bool> logout() async {
    try {
      await _supabaseService.client.auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// استعادة كلمة المرور - للتوافق مع الكود القديم
  Future<bool> resetPassword(String email) async {
    final result = await sendPasswordResetEmail(email);
    return result['success'] as bool;
  }

  /// الحصول على المستخدم الحالي
  Future<User?> getCurrentUser() async {
    try {
      final authUser = _supabaseService.getCurrentUser();
      if (authUser == null) return null;

      final userData = await _supabaseService.getOne(
        SupabaseConfig.usersTable,
        authUser.id,
      );

      if (userData == null) return null;

      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// التحقق من تسجيل الدخول
  bool isLoggedIn() {
    return _supabaseService.isLoggedIn();
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.update(
        SupabaseConfig.usersTable,
        userId,
        updateData,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تغيير كلمة المرور
  Future<bool> changePassword({
    required String newPassword,
  }) async {
    final result = await updatePassword(newPassword);
    return result['success'] as bool;
  }

  /// الحصول على جلسة المستخدم الحالية
  Session? getCurrentSession() {
    return _supabaseService.client.auth.currentSession;
  }

  /// تحديث جلسة المستخدم
  Future<bool> refreshSession() async {
    try {
      final session = _supabaseService.client.auth.currentSession;
      if (session == null) return false;

      await _supabaseService.client.auth.refreshSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// الاستماع لتغييرات المصادقة
  void onAuthStateChanged(Function(AuthChangeEvent, Session?) callback) {
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      callback(data.event, data.session);
    });
  }
}
