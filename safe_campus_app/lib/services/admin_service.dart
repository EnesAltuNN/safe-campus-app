import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/logic/models/dashboard_stats.dart';
import 'package:safe_campus_app/logic/models/report.dart';
import 'package:safe_campus_app/logic/models/university.dart';
import 'package:safe_campus_app/logic/models/user.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/api_config.dart';

class AdminService {
  // API Base URL - Platform'a göre otomatik belirlenir
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/admin';
    } else {
      return '${ApiConfig.baseUrl}/api/admin';
    }
  }

  /// Tüm kullanıcıları getir
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        throw AdminException(
          message: data['message'] ?? 'Kullanıcılar getirilemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Tüm raporları getir
  static Future<List<Report>> getAllReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Report.fromJson(json)).toList();
      } else {
        final data = jsonDecode(response.body);
        throw AdminException(
          message: data['message'] ?? 'Raporlar getirilemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Tüm üniversitelere alert gönder
  static Future<String> sendAlertToAll({
    required String title,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alert-all'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({'title': title, 'message': message}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Alert gönderildi';
      } else {
        throw AdminException(
          message: data['message'] ?? 'Alert gönderilemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Yeni üniversite oluştur
  static Future<String> createUniversity({
    required String name,
    required String abbreviation,
    String? logoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/universities'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'name': name,
          'abbreviation': abbreviation,
          'logoUrl': logoUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Üniversite eklendi';
      } else {
        throw AdminException(
          message: data['message'] ?? 'Üniversite eklenemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Üniversite sil
  static Future<String> deleteUniversity(int universityId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/universities/$universityId'),
        headers: AuthService.getAuthHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Üniversite silindi';
      } else {
        throw AdminException(
          message: data['message'] ?? 'Üniversite silinemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Yeni UniAdmin oluştur
  static Future<String> createUniAdmin({
    required String fullName,
    required String email,
    required String password,
    required int universityId,
    int? unitId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/uni-admin'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'universityId': universityId,
          'unitId': unitId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'UniAdmin oluşturuldu';
      } else {
        throw AdminException(
          message: data['message'] ?? 'UniAdmin oluşturulamadı',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Kullanıcı sil
  static Future<String> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: AuthService.getAuthHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Kullanıcı silindi';
      } else {
        throw AdminException(
          message: data['message'] ?? 'Kullanıcı silinemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Kullanıcı rolü güncelle
  static Future<String> updateUserRole({
    required int userId,
    required String role,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/role'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({'role': role}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Kullanıcı rolü güncellendi';
      } else {
        throw AdminException(
          message: data['message'] ?? 'Kullanıcı rolü güncellenemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }

  /// Dashboard istatistiklerini getir
  static Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-stats'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return DashboardStats.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw AdminException(
          message: data['message'] ?? 'İstatistikler getirilemedi',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException(message: 'Bağlantı hatası: $e');
    }
  }
}

/// Admin işlemleri için özel hata sınıfı
class AdminException implements Exception {
  final String message;
  final int? statusCode;

  AdminException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
