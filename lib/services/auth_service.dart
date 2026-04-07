import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'supabase_service.dart';
import '../models/user.dart';
import '../config/supabase_config.dart';

/// خدمة المصادقة
class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  /// التسجيل (إنشاء حساب جديد)
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      // إنشاء حساب في Auth
      final authResponse = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return false;
      }

      // إضافة بيانات المستخدم في جدول users
      await _supabaseService.insert(
        SupabaseConfig.usersTable,
        {
          'id': authResponse.user!.id,
          'email': email,
          'name': name,
          'phone': phone,
          'user_type': userType,
          'is_verified': false,
          'is_active': true,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل الدخول
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse =
          await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return authResponse.user != null;
    } catch (e) {
      return false;
    }
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

  /// استعادة كلمة المرور
  Future<bool> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
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
    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      return false;
    }
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
  void onAuthStateChanged(Function(AuthState) callback) {
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      callback(data);
    });
  }
}
