import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/services/auth_service.dart';

class DeviceService {
  /// FCM token'ı backend'e kaydet
  static Future<void> saveFcmToken(String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/users/register-device'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'fcmToken': token}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('FCM token kaydedilemedi: \\${response.body}');
    }
  }
}
