import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/super_admin_service.dart';
import '../logic/models/super_admin_report.dart';

class SuperAdminReportActions {
  // Rapor açıklamasını güncelle
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
      throw Exception('Açıklama güncellenemedi');
    }
  }

  // Rapor sil (global endpoint)
  static Future<void> deleteReport(int reportId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Rapor silinemedi');
    }
  }

  // Rapor durumunu güncelle (global endpoint)
  static Future<void> updateReportStatus({
    required int reportId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/status'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Rapor durumu güncellenemedi');
    }
  }
}
