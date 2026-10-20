import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import '../logic/models/super_admin_user.dart';
import '../logic/models/super_admin_university.dart';
import '../logic/models/super_admin_report.dart';

class SuperAdminService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/admin';

  // Tüm kullanıcıları getir
  static Future<List<SuperAdminUser>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SuperAdminUser.fromJson(e)).toList();
    } else {
      throw Exception('Kullanıcılar alınamadı');
    }
  }

  // Kullanıcı sil
  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Kullanıcı silinemedi');
    }
  }

  // Kullanıcı rolünü değiştir
  static Future<void> updateUserRole(int userId, String newRole) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'role': newRole}),
    );
    if (response.statusCode != 200) {
      throw Exception('Rol güncellenemedi');
    }
  }

  // Tüm üniversiteleri getir
  static Future<List<SuperAdminUniversity>> getAllUniversities() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/universities'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SuperAdminUniversity.fromJson(e)).toList();
    } else {
      throw Exception('Üniversiteler alınamadı');
    }
  }

  // Alert gönder (tümüne veya seçili üniversitelere)
  static Future<void> sendAlert({
    required String title,
    required String message,
    bool isGlobal = false,
    int? universityId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'message': message,
      'isGlobal': isGlobal,
    };
    if (!isGlobal && universityId != null) {
      body['universityId'] = universityId;
    }
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/alerts/create'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Alert gönderilemedi');
    }
  }

  // Tüm raporları getir
  static Future<List<SuperAdminReport>> getAllReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SuperAdminReport.fromJson(e)).toList();
    } else {
      throw Exception('Raporlar alınamadı');
    }
  }
}
