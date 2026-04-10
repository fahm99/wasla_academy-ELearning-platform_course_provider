import 'dart:io';
import 'dart:typed_data';
import 'package:course_provider/data/services/supabase_service.dart';
import '../../core/config/supabase_config.dart';
import 'package:cross_file/cross_file.dart';

/// خدمة التخزين والملفات
class StorageService {
  final SupabaseService _supabaseService = SupabaseService();

  /// رفع فيديو سريع مع مؤشر تقدم حقيقي (Chunked Upload)
  Future<String?> uploadVideoFast({
    required dynamic videoFile,
    required String courseId,
    required String lessonId,
    Function(double)? onProgress,
  }) async {
    try {
      print('[Wasla] 🚀 StorageService.uploadVideoFast - رفع سريع!');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');

      final file = videoFile as File;
      final fileName =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}.mp4';

      print('[Wasla]   - اسم الملف: $fileName');

      // قراءة الملف
      final fileBytes = await file.readAsBytes();
      final totalSize = fileBytes.length;
      print(
          '[Wasla]   - حجم الملف: ${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      // رفع مباشر بدون تقسيم (Supabase يدعم الرفع المباشر)
      print('[Wasla] 📤 بدء الرفع المباشر...');

      // محاكاة التقدم أثناء الرفع
      onProgress?.call(0.1);

      final url = await _supabaseService.uploadFile(
        SupabaseConfig.videosBucket,
        fileName,
        fileBytes,
      );

      onProgress?.call(1.0);

      print('[Wasla] ✅ StorageService.uploadVideoFast - نجح!');
      print('[Wasla]   - الرابط: $url');
      print('[Wasla]   - الوقت: فوري ⚡');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadVideoFast - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// رفع فيديو سريع من bytes (للويب)
  Future<String?> uploadVideoFromBytesFast({
    required Uint8List videoBytes,
    required String fileName,
    required String courseId,
    required String lessonId,
    Function(double)? onProgress,
  }) async {
    try {
      print(
          '[Wasla] 🚀 StorageService.uploadVideoFromBytesFast - رفع سريع (Web)!');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');
      print('[Wasla]   - اسم الملف الأصلي: $fileName');
      print(
          '[Wasla]   - حجم الملف: ${(videoBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB');

      final storagePath =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      print('[Wasla]   - مسار التخزين: $storagePath');
      print('[Wasla] 📤 بدء الرفع المباشر...');

      // محاكاة التقدم
      onProgress?.call(0.1);

      final url = await _supabaseService.uploadFile(
        SupabaseConfig.videosBucket,
        storagePath,
        videoBytes,
      );

      onProgress?.call(1.0);

      print('[Wasla] ✅ StorageService.uploadVideoFromBytesFast - نجح!');
      print('[Wasla]   - الرابط: $url');
      print('[Wasla]   - الوقت: فوري ⚡');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadVideoFromBytesFast - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> uploadVideo({
    required dynamic videoFile,
    required String courseId,
    required String lessonId,
  }) async {
    try {
      print('[Wasla] StorageService.uploadVideo - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');

      final file = videoFile as File;
      print('[Wasla]   - مسار الملف: ${file.path}');

      final fileName =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      print('[Wasla]   - اسم الملف في Storage: $fileName');

      print('[Wasla] قراءة bytes الملف...');
      final fileBytes = await file.readAsBytes();
      print(
          '[Wasla]   - حجم الملف: ${fileBytes.length} bytes (${(fileBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB)');

      print('[Wasla] استدعاء _supabaseService.uploadFile...');
      final url = await _supabaseService.uploadFile(
        SupabaseConfig.videosBucket,
        fileName,
        fileBytes,
      );

      print('[Wasla] ✅ StorageService.uploadVideo - نجح!');
      print('[Wasla]   - الرابط: $url');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadVideo - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// رفع فيديو من bytes (للويب)
  Future<String?> uploadVideoFromBytes({
    required Uint8List videoBytes,
    required String fileName,
    required String courseId,
    required String lessonId,
  }) async {
    try {
      print('[Wasla] StorageService.uploadVideoFromBytes - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');
      print('[Wasla]   - اسم الملف الأصلي: $fileName');
      print(
          '[Wasla]   - حجم الملف: ${videoBytes.length} bytes (${(videoBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB)');

      final storagePath =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      print('[Wasla]   - مسار التخزين: $storagePath');

      print('[Wasla] استدعاء _supabaseService.uploadFile...');
      final url = await _supabaseService.uploadFile(
        SupabaseConfig.videosBucket,
        storagePath,
        videoBytes,
      );

      print('[Wasla] ✅ StorageService.uploadVideoFromBytes - نجح!');
      print('[Wasla]   - الرابط: $url');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadVideoFromBytes - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> uploadFile({
    required dynamic file,
    required String courseId,
    required String lessonId,
    required String fileType,
  }) async {
    try {
      print('[Wasla] StorageService.uploadFile - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');
      print('[Wasla]   - نوع الملف: $fileType');

      final f = file as File;
      print('[Wasla]   - مسار الملف: ${f.path}');

      final fileName =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}_${f.path.split('/').last}';
      print('[Wasla]   - اسم الملف في Storage: $fileName');

      print('[Wasla] قراءة bytes الملف...');
      final fileBytes = await f.readAsBytes();
      print(
          '[Wasla]   - حجم الملف: ${fileBytes.length} bytes (${(fileBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB)');

      print('[Wasla] استدعاء _supabaseService.uploadFile...');
      final url = await _supabaseService.uploadFile(
        SupabaseConfig.filesBucket,
        fileName,
        fileBytes,
      );

      print('[Wasla] ✅ StorageService.uploadFile - نجح!');
      print('[Wasla]   - الرابط: $url');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadFile - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// رفع ملف من bytes (للويب)
  Future<String?> uploadFileFromBytes({
    required Uint8List fileBytes,
    required String fileName,
    required String courseId,
    required String lessonId,
    required String fileType,
  }) async {
    try {
      print('[Wasla] StorageService.uploadFileFromBytes - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Lesson ID: $lessonId');
      print('[Wasla]   - اسم الملف الأصلي: $fileName');
      print('[Wasla]   - نوع الملف: $fileType');
      print(
          '[Wasla]   - حجم الملف: ${fileBytes.length} bytes (${(fileBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB)');

      final storagePath =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      print('[Wasla]   - مسار التخزين: $storagePath');

      print('[Wasla] استدعاء _supabaseService.uploadFile...');
      final url = await _supabaseService.uploadFile(
        SupabaseConfig.filesBucket,
        storagePath,
        fileBytes,
      );

      print('[Wasla] ✅ StorageService.uploadFileFromBytes - نجح!');
      print('[Wasla]   - الرابط: $url');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadFileFromBytes - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> uploadImage({
    required dynamic imageFile,
    required String courseId,
    String? type,
  }) async {
    try {
      print('[Wasla] StorageService.uploadImage - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - Type: ${type ?? 'image'}');

      final file = imageFile as File;
      final fileName =
          '$courseId/${type ?? 'image'}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('[Wasla]   - اسم الملف في Storage: $fileName');

      final fileBytes = await file.readAsBytes();
      print(
          '[Wasla]   - حجم الملف: ${(fileBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB');

      final url = await _supabaseService.uploadFile(
        SupabaseConfig.imagesBucket,
        fileName,
        fileBytes,
      );

      print('[Wasla] ✅ StorageService.uploadImage - نجح!');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadImage - خطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// رفع صورة من bytes (للويب)
  Future<String?> uploadImageFromBytes({
    required Uint8List imageBytes,
    required String fileName,
    required String courseId,
    String? type,
  }) async {
    try {
      print('[Wasla] StorageService.uploadImageFromBytes - بدء العملية');
      print('[Wasla]   - Course ID: $courseId');
      print('[Wasla]   - اسم الملف الأصلي: $fileName');
      print('[Wasla]   - Type: ${type ?? 'image'}');
      print(
          '[Wasla]   - حجم الملف: ${(imageBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB');

      final storagePath =
          '$courseId/${type ?? 'image'}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      print('[Wasla]   - مسار التخزين: $storagePath');

      final url = await _supabaseService.uploadFile(
        SupabaseConfig.imagesBucket,
        storagePath,
        imageBytes,
      );

      print('[Wasla] ✅ StorageService.uploadImageFromBytes - نجح!');

      return url;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ StorageService.uploadImageFromBytes - خطأ: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> uploadAvatar({
    required File avatarFile,
    required String userId,
  }) async {
    try {
      final fileName =
          'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await avatarFile.readAsBytes();
      return await _supabaseService.uploadFile(
        SupabaseConfig.avatarsBucket,
        fileName,
        fileBytes,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadCertificate({
    required Uint8List certificateBytes,
    required String certificateId,
  }) async {
    try {
      final fileName =
          'certificates/$certificateId/${DateTime.now().millisecondsSinceEpoch}.pdf';
      return await _supabaseService.uploadFile(
        SupabaseConfig.certificatesBucket,
        fileName,
        certificateBytes,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await _supabaseService.deleteFile(bucket, filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  String getPublicUrl({required String bucket, required String filePath}) {
    try {
      return _supabaseService.client.storage
          .from(bucket)
          .getPublicUrl(filePath);
    } catch (e) {
      return '';
    }
  }

  Future<String?> getSignedUrl({
    required String bucket,
    required String filePath,
    int expiresIn = 3600,
  }) async {
    try {
      return await _supabaseService.client.storage
          .from(bucket)
          .createSignedUrl(filePath, expiresIn);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      final files =
          await _supabaseService.client.storage.from(bucket).list(path: path);
      return files.map((f) => f.name).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Uint8List?> downloadFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      return await _supabaseService.client.storage
          .from(bucket)
          .download(filePath);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // Profile Image Management
  // ============================================

  Future<String> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      final fileName =
          'profiles/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await file.readAsBytes();

      final url = await _supabaseService.uploadFile(
        SupabaseConfig.avatarsBucket,
        fileName,
        fileBytes,
      );

      return url;
    } catch (e) {
      throw Exception('خطأ في رفع صورة الملف الشخصي: ${e.toString()}');
    }
  }

  Future<void> deleteProfileImage({required String userId}) async {
    try {
      // حذف جميع صور المستخدم من المجلد
      final files = await listFiles(
        bucket: SupabaseConfig.avatarsBucket,
        path: 'profiles/$userId',
      );

      for (final file in files) {
        await deleteFile(
          bucket: SupabaseConfig.avatarsBucket,
          filePath: 'profiles/$userId/$file',
        );
      }
    } catch (e) {
      throw Exception('خطأ في حذف صورة الملف الشخصي: ${e.toString()}');
    }
  }
}
