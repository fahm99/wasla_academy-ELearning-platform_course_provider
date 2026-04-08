import 'dart:io';
import 'dart:typed_data';
import 'package:course_provider/data/services/supabase_service.dart';
import '../../core/config/supabase_config.dart';

/// خدمة التخزين والملفات
class StorageService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<String?> uploadVideo({
    required dynamic videoFile,
    required String courseId,
    required String lessonId,
  }) async {
    try {
      final file = videoFile as File;
      final fileName =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final fileBytes = await file.readAsBytes();
      return await _supabaseService.uploadFile(
        SupabaseConfig.videosBucket,
        fileName,
        fileBytes,
      );
    } catch (e) {
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
      final f = file as File;
      final fileName =
          '$courseId/$lessonId/${DateTime.now().millisecondsSinceEpoch}_${f.path.split('/').last}';
      final fileBytes = await f.readAsBytes();
      return await _supabaseService.uploadFile(
        SupabaseConfig.filesBucket,
        fileName,
        fileBytes,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage({
    required dynamic imageFile,
    required String courseId,
    String? type,
  }) async {
    try {
      final file = imageFile as File;
      final fileName =
          '$courseId/${type ?? 'image'}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await file.readAsBytes();
      return await _supabaseService.uploadFile(
        SupabaseConfig.imagesBucket,
        fileName,
        fileBytes,
      );
    } catch (e) {
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
}
