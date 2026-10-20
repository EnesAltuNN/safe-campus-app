import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/logic/models/campus_polygon.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:safe_campus_app/services/api_config.dart';

class MapService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/map';
    } else {
      return '${ApiConfig.baseUrl}/api/map';
    }
  }

  // Polygon ekle/güncelle
  static Future<String> upsertPolygon({required dynamic geojson}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/polygon'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({'geojson': geojson}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Polygon kaydedildi';
    } else {
      throw Exception(data['message'] ?? 'Polygon kaydedilemedi');
    }
  }

  // Belirli üniversitenin polygonunu getir
  static Future<CampusPolygon> getPolygonByUniversity(int universityId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/universities/$universityId/polygon'),
      headers: AuthService.getAuthHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // PolygonData stringini parse et
      final geojson = jsonDecode(data['PolygonData']);
      return CampusPolygon(
        polygonId: 0,
        universityId: universityId,
        geojson: geojson,
        createdAt: null,
        updatedAt: null,
      );
    } else {
      throw Exception(data['message'] ?? 'Polygon bulunamadı');
    }
  }
}
