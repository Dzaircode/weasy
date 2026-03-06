import 'package:dio/dio.dart';
import '../constants.dart';
import 'storage_service.dart';

class AuthResult {
  final bool success;
  final String? message;
  final bool? userExists;
  final bool? isNewUser;

  AuthResult({
    required this.success,
    this.message,
    this.userExists,
    this.isNewUser,
  });
}

class AuthService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<AuthResult> checkPhone(String phone) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult(success: true, userExists: false);
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to check phone');
    }
  }

  static Future<AuthResult> sendOtp(String phone) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to send OTP');
    }
  }

  static Future<AuthResult> verifyOtp(String phone, String otp) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      return AuthResult(success: true, isNewUser: true);
    } catch (e) {
      return AuthResult(success: false, message: 'Invalid OTP');
    }
  }

  static Future<AuthResult> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String email,
    required String restaurantName,
    required String address,
    String? logoPath,
    String? coverPath,
    String? instagram,
    String? facebook,
    String? tiktok,
    String? whatsapp,
  }) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, message: 'Registration failed');
    }
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}

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