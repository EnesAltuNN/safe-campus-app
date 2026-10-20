import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'auth_service.dart';
import '../logic/models/report_image.dart';

class ImageService {
  static Future<List<ReportImage>> getImagesByReportId(int reportId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/images-only'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ReportImage.fromJson(e)).toList();
    } else {
      throw Exception('Görseller alınamadı');
    }
  }
}
