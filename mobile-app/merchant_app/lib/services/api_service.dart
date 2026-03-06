import 'package:dio/dio.dart';
import '../constants.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Attach JWT to every request automatically
  static Future<void> _attachToken() async {
    final token = await StorageService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ── GET ──────────────────────────────────────────────────
  static Future<Response> get(String path) async {
    await _attachToken();
    return await _dio.get(path);
  }

  // ── POST ─────────────────────────────────────────────────
  static Future<Response> post(String path, Map<String, dynamic> data) async {
    await _attachToken();
    return await _dio.post(path, data: data);
  }

  // ── PUT ──────────────────────────────────────────────────
  static Future<Response> put(String path, Map<String, dynamic> data) async {
    await _attachToken();
    return await _dio.put(path, data: data);
  }

  // ── PATCH ────────────────────────────────────────────────
  static Future<Response> patch(String path, Map<String, dynamic> data) async {
    await _attachToken();
    return await _dio.patch(path, data: data);
  }

  // ── DELETE ───────────────────────────────────────────────
  static Future<Response> delete(String path) async {
    await _attachToken();
    return await _dio.delete(path);
  }

  // ── Multipart (file upload) ───────────────────────────────
  static Future<Response> postFormData(
      String path, FormData formData) async {
    await _attachToken();
    return await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  static Future<Response> putFormData(
      String path, FormData formData) async {
    await _attachToken();
    return await _dio.put(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}