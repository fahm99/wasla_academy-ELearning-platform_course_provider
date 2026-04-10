import 'dart:typed_data';
import 'package:course_provider/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// الخدمة الرئيسية للاتصال بـ Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  User? getCurrentUser() => _client.auth.currentUser;

  bool isLoggedIn() => _client.auth.currentUser != null;

  /// الاستعلام عن البيانات
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      // بناء الاستعلام مع الفلاتر
      var builder = _client.from(table).select(select?.join(',') ?? '*');

      if (filters != null) {
        filters.forEach((key, value) {
          if (value is List) {
            builder = builder.inFilter(key, value);
          } else {
            builder = builder.eq(key, value);
          }
        });
      }

      // تطبيق الترتيب والحد
      if (orderBy != null && limit != null && offset != null) {
        final response = await builder
            .order(orderBy, ascending: ascending)
            .range(offset, offset + limit - 1);
        return List<Map<String, dynamic>>.from(response);
      } else if (orderBy != null && limit != null) {
        final response =
            await builder.order(orderBy, ascending: ascending).limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else if (orderBy != null) {
        final response = await builder.order(orderBy, ascending: ascending);
        return List<Map<String, dynamic>>.from(response);
      } else if (limit != null) {
        final response = await builder.limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await builder;
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select();
      return response.isNotEmpty ? response[0] : {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await _client.from(table).update(data).eq('id', id).select();
      return response.isNotEmpty ? response[0] : {};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOne(String table, String id) async {
    try {
      final response = await _client.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadFile(
    String bucket,
    String path,
    Uint8List fileBytes,
  ) async {
    try {
      print('[Wasla] SupabaseService.uploadFile - بدء العملية');
      print('[Wasla]   - Bucket: $bucket');
      print('[Wasla]   - Path: $path');
      print(
          '[Wasla]   - حجم البيانات: ${fileBytes.length} bytes (${(fileBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB)');

      print('[Wasla] التحقق من وجود الـ bucket...');
      try {
        final buckets = await _client.storage.listBuckets();
        final bucketExists = buckets.any((b) => b.name == bucket);
        print('[Wasla]   - الـ bucket موجود: $bucketExists');
        if (!bucketExists) {
          print('[Wasla]   ❌ الـ bucket "$bucket" غير موجود!');
          print(
              '[Wasla]   - الـ buckets المتاحة: ${buckets.map((b) => b.name).join(", ")}');
          throw Exception(
              'Bucket "$bucket" not found. Available buckets: ${buckets.map((b) => b.name).join(", ")}');
        }
      } catch (e) {
        print('[Wasla]   ⚠️ لم نتمكن من التحقق من الـ buckets: $e');
      }

      print('[Wasla] بدء رفع الملف إلى Supabase Storage...');
      await _client.storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      print('[Wasla] ✅ تم رفع الملف بنجاح!');

      print('[Wasla] الحصول على الرابط العام...');
      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      print('[Wasla] ✅ الرابط العام: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      print('[Wasla] ❌ SupabaseService.uploadFile - خطأ:');
      print('[Wasla]   - الخطأ: $e');
      print('[Wasla]   - النوع: ${e.runtimeType}');

      if (e is StorageException) {
        print('[Wasla]   - Storage Error Message: ${e.message}');
        print('[Wasla]   - Storage Error Status Code: ${e.statusCode}');
      }

      print('[Wasla]   - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      rethrow;
    }
  }

  RealtimeChannel listenToTable(String table, Function(dynamic) onData) {
    return _client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) => onData(payload),
        )
        .subscribe();
  }

  Future<void> stopListening(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  Future<dynamic> callFunction(
    String functionName,
    Map<String, dynamic> params,
  ) async {
    try {
      return await _client.rpc(functionName, params: params);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      var query = _client.from(table).select('id');
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }
      final response = await query;
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> search(
    String table,
    String searchColumn,
    String searchTerm,
  ) async {
    try {
      final response = await _client
          .from(table)
          .select()
          .ilike(searchColumn, '%$searchTerm%');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
