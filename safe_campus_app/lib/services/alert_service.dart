import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/api_config.dart';

class AlertService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/alerts';
    } else {
      return '${ApiConfig.baseUrl}/api/alerts';
    }
  }

  // 1) Alert oluştur ve push gönder
  static Future<String> createAlert({
    required String title,
    required String message,
    required bool isGlobal,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({
        'title': title,
        'message': message,
        'isGlobal': isGlobal,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Alert gönderildi';
    } else {
      throw Exception(data['message'] ?? 'Alert gönderilemedi');
    }
  }

  // 2) Tüm alertleri getir (SuperAdmin)
  static Future<List<dynamic>> getAllAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Alertler getirilemedi');
    }
  }

  // 3) Kullanıcının alertlerini getir
  static Future<List<dynamic>> getMyAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Alertler getirilemedi');
    }
  }

  // 4) Belirli üniversitenin alertlerini getir
  static Future<List<dynamic>> getAlertsByUniversity(int universityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/university/$universityId'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Alertler getirilemedi');
    }
  }

  // 5) Alerti okundu olarak işaretle
  static Future<String> markAlertAsRead(int alertId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$alertId/read'),
      headers: AuthService.getAuthHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Alert okundu olarak işaretlendi';
    } else {
      throw Exception(data['message'] ?? 'İşaretleme başarısız');
    }
  }

  // 6) Alert sil (SuperAdmin)
  static Future<String> deleteAlert(int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$alertId'),
      headers: AuthService.getAuthHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Alert silindi';
    } else {
      throw Exception(data['message'] ?? 'Silme başarısız');
    }
  }

  // 7) Okunmamış alert sayısı
  static Future<int> getUnreadAlertCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/unread-count'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['UnreadCount'] ?? 0;
    } else {
      throw Exception('Okunmamış alert sayısı alınamadı');
    }
  }
}
