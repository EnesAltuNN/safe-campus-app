import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import '../logic/models/uni_admin_user.dart';
import '../logic/models/uni_admin_report.dart';
import '../logic/models/uni_admin_dashboard_stats.dart';

class UniAdminService {
  // Rapor açıklamasını güncelle (PUT /api/reports/:id/description)
  static Future<void> updateReportDescription({
    required int reportId,
    required String description,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/description'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'description': description}),
    );
    if (response.statusCode != 200) {
      String message = 'Açıklama güncellenemedi';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  // Rapor sil (UniAdmin)
  static Future<void> deleteReport(int reportId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode != 200) {
      String message = 'Rapor silinemedi';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  // Üniversite admini kendi üniversitesindeki bir kullanıcıyı silebilsin
  static Future<void> deleteUser(int userId) async {
    final adminBaseUrl = '${ApiConfig.baseUrl}/api/admin';
    final response = await http.delete(
      Uri.parse('$adminBaseUrl/users/$userId'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode != 200) {
      String message = 'Kullanıcı silinemedi';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static String get baseUrl => '${ApiConfig.baseUrl}/api/uniadmin';

  // Üniversiteye ait kullanıcıları getir
  static Future<List<UniAdminUser>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UniAdminUser.fromJson(e)).toList();
    } else {
      throw Exception('Kullanıcılar alınamadı');
    }
  }

  // Üniversiteye ait raporları getir
  static Future<List<UniAdminReport>> getReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UniAdminReport.fromJson(e)).toList();
    } else {
      throw Exception('Raporlar alınamadı');
    }
  }

  // Üniversiteye alert gönder
  static Future<void> sendAlert({
    required String title,
    required String message,
    bool isGlobal = false,
  }) async {
    // Alert göndermeden hemen önce token ve header bilgisini ekrana ve konsola yazdır
    final tokenInfo =
        'Token (uni_admin_service.sendAlert): \n${AuthService.token}\n\nHeader: ${AuthService.getAuthHeaders()}';

    final body = {'title': title, 'message': message, 'isGlobal': isGlobal};
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/alerts/create'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Alert gönderilemedi');
    }
  }

  // Rapor durumunu güncelle
  static Future<void> updateReportStatus({
    required int reportId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reports/$reportId/status'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Rapor durumu güncellenemedi');
    }
  }

  // Dashboard istatistikleri getir
  static Future<UniAdminDashboardStats> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard-stats'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UniAdminDashboardStats.fromJson(data);
    } else {
      throw Exception('Dashboard istatistikleri alınamadı');
    }
  }
}
