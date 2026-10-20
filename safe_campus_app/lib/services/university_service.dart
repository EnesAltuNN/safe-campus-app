import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/api_config.dart';
import 'package:safe_campus_app/logic/models/university.dart';

class UniversityService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/universities';

  // Tüm üniversiteleri getir
  static Future<List<University>> getAllUniversities() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => University.fromJson(e)).toList();
    } else {
      throw Exception('Üniversiteler getirilemedi');
    }
  }

  // Belirli üniversitenin polygon bilgisini getir
  static Future<String?> getCampusPolygon(int universityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$universityId/polygon'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['PolygonData'] as String?;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Polygon verisi getirilemedi');
    }
  }
}
