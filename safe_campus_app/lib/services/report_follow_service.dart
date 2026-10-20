import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/services/auth_service.dart';

class ReportFollowService {
  /// Kullanıcının takip ettiği rapor ID'lerini getir
  static Future<List<int>> getFollowedReportIds() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/following'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<int>();
    } else {
      throw Exception('Takip edilen raporlar alınamadı');
    }
  }

  /// Raporu takip et
  static Future<String> followReport(int reportId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/follow'),
      headers: AuthService.getAuthHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Rapor takip edildi';
    } else {
      throw Exception(data['message'] ?? 'Takip etme başarısız');
    }
  }

  /// Raporu takipten çıkar
  static Future<String> unfollowReport(int reportId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/follow'),
      headers: AuthService.getAuthHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Takipten çıkarıldı';
    } else {
      throw Exception(data['message'] ?? 'Takipten çıkarma başarısız');
    }
  }
}
