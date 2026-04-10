import 'dart:io';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

/// مساعد لمعالجة الفيديو
class VideoHelper {
  /// ضغط الفيديو
  static Future<File?> compressVideo(
    File videoFile, {
    Function(double)? onProgress,
  }) async {
    try {
      print('[Wasla] VideoHelper.compressVideo - بدء الضغط');
      print('[Wasla]   - الملف الأصلي: ${videoFile.path}');

      final fileSize = await videoFile.length();
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      print('[Wasla]   - الحجم الأصلي: $fileSizeMB MB');

      // إذا كان الملف صغير، لا حاجة للضغط
      if (fileSize < 50 * 1024 * 1024) {
        print('[Wasla]   - الملف صغير، لا حاجة للضغط');
        return videoFile;
      }

      // الاشتراك في تحديثات التقدم
      final subscription =
          VideoCompress.compressProgress$.subscribe((progress) {
        print('[Wasla]   - تقدم الضغط: ${progress.toStringAsFixed(1)}%');
        onProgress?.call(progress / 100);
      });

      // ضغط الفيديو
      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 30,
      );

      // إلغاء الاشتراك
      subscription.unsubscribe();

      if (info == null || info.file == null) {
        print('[Wasla]   ❌ فشل الضغط');
        return videoFile; // إرجاع الملف الأصلي
      }

      final compressedSize = await info.file!.length();
      final compressedSizeMB =
          (compressedSize / (1024 * 1024)).toStringAsFixed(2);
      final reductionPercent =
          ((1 - compressedSize / fileSize) * 100).toStringAsFixed(1);

      print('[Wasla]   ✅ تم الضغط بنجاح');
      print('[Wasla]   - الحجم بعد الضغط: $compressedSizeMB MB');
      print('[Wasla]   - نسبة التقليل: $reductionPercent%');

      return info.file;
    } catch (e, stackTrace) {
      print('[Wasla]   ❌ خطأ في الضغط: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return videoFile; // إرجاع الملف الأصلي في حالة الخطأ
    }
  }

  /// استخراج معلومات الفيديو
  static Future<VideoInfo?> extractVideoInfo(File videoFile) async {
    try {
      print('[Wasla] VideoHelper.extractVideoInfo - بدء الاستخراج');
      print('[Wasla]   - الملف: ${videoFile.path}');

      // إنشاء controller للفيديو
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      // الحصول على المعلومات
      final duration = controller.value.duration;
      final durationInSeconds = duration.inSeconds;
      final durationInMinutes = (durationInSeconds / 60).ceil();

      // الحصول على اسم الملف
      final fileName = videoFile.path.split('/').last;
      final videoName =
          fileName.replaceAll(RegExp(r'\.[^.]+$'), ''); // إزالة الامتداد

      // الحصول على الحجم
      final fileSize = await videoFile.length();
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

      print('[Wasla]   ✅ تم استخراج المعلومات');
      print('[Wasla]   - الاسم: $videoName');
      print(
          '[Wasla]   - المدة: $durationInMinutes دقيقة ($durationInSeconds ثانية)');
      print('[Wasla]   - الحجم: $fileSizeMB MB');

      // تنظيف
      await controller.dispose();

      return VideoInfo(
        name: videoName,
        durationInSeconds: durationInSeconds,
        durationInMinutes: durationInMinutes,
        fileSizeMB: double.parse(fileSizeMB),
      );
    } catch (e, stackTrace) {
      print('[Wasla]   ❌ خطأ في استخراج المعلومات: $e');
      print('[Wasla]   - Stack trace: $stackTrace');
      return null;
    }
  }

  /// تنظيف الملفات المؤقتة
  static Future<void> cleanup() async {
    try {
      await VideoCompress.deleteAllCache();
      print('[Wasla] VideoHelper.cleanup - تم تنظيف الملفات المؤقتة');
    } catch (e) {
      print('[Wasla] VideoHelper.cleanup - خطأ في التنظيف: $e');
    }
  }
}

/// معلومات الفيديو
class VideoInfo {
  final String name;
  final int durationInSeconds;
  final int durationInMinutes;
  final double fileSizeMB;

  VideoInfo({
    required this.name,
    required this.durationInSeconds,
    required this.durationInMinutes,
    required this.fileSizeMB,
  });
}
