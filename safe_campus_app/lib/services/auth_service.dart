import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/logic/models/auth_response.dart';
import 'package:safe_campus_app/logic/models/user.dart';
import 'package:safe_campus_app/services/api_config.dart';

class AuthService {
  // API Base URL - Platform'a göre otomatik belirlenir
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/auth';
    } else {
      return '${ApiConfig.baseUrl}/api/auth';
    }
  }

  // Token'ı bellekte tutmak için (SharedPreferences ile kalıcı hale getirilebilir)
  static String? _token;
  static User? _currentUser;

  // Getter'lar
  static String? get token => _token;
  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _token != null;

  /// LOGIN - Kullanıcı girişi
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        _token = authResponse.token;
        _currentUser = authResponse.user;
        return authResponse;
      } else {
        throw AuthException(
          message: data['message'] ?? 'Giriş başarısız',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Bağlantı hatası: $e');
    }
  }

  /// REGISTER - Yeni kullanıcı kaydı
  static Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required int universityId,
    int? unitId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'universityId': universityId,
          'unitId': unitId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        _token = authResponse.token;
        _currentUser = authResponse.user;
        return authResponse;
      } else {
        throw AuthException(
          message: data['message'] ?? 'Kayıt başarısız',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Bağlantı hatası: $e');
    }
  }

  /// FORGOT PASSWORD - Şifre sıfırlama kodu gönderme
  /// Returns: resetCode (test için) veya message
  static Future<Map<String, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Test için resetCode döndürülüyor (gerçek uygulamada email ile gider)
        return {
          'message': data['message'] ?? 'Kod gönderildi',
          'resetCode': data['resetCode']?.toString() ?? '',
        };
      } else {
        throw AuthException(
          message: data['message'] ?? 'İşlem başarısız',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Bağlantı hatası: $e');
    }
  }

  /// VERIFY RESET CODE - Sıfırlama kodunu doğrulama
  static Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return true;
      } else {
        throw AuthException(
          message: data['message'] ?? 'Kod doğrulanamadı',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Bağlantı hatası: $e');
    }
  }

  /// RESET PASSWORD - Yeni şifre belirleme
  static Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data['message'] ?? 'Şifre güncellendi';
      } else {
        throw AuthException(
          message: data['message'] ?? 'Şifre güncellenemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Bağlantı hatası: $e');
    }
  }

  /// LOGOUT - Çıkış yap
  static void logout() {
    _token = null;
    _currentUser = null;
  }

  /// Token ile istek yapmak için header oluşturma
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}

/// Auth işlemleri için özel hata sınıfı
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
