import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:safe_campus_app/logic/models/report.dart';
import 'package:safe_campus_app/services/api_config.dart';
import 'auth_service.dart';

class ReportService {
  static Future<List<String>> getReportImages(int reportId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$reportId/images-only'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['images'] is List) {
        return (data['images'] as List).map((e) => e.toString()).toList();
      } else if (data is List) {
        // Eğer doğrudan dizi dönüyorsa
        return data.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static Future<Report> getReportById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/$id'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Report.fromJson(data);
    } else {
      throw Exception('Rapor detayı alınamadı');
    }
  }

  static Future<List<Report>> getAllReports() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception('Raporlar alınamadı');
    }
  }

  static Future<List<Report>> getMapReports() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/map'),
      headers: AuthService.getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map(
            (e) => Report(
              reportId: e['ReportID'] ?? 0,
              universityId: e['UniversityID'] ?? 0,
              universityName: e['UniversityName'] ?? '',
              userId: e['UserID'] ?? 0,
              userName: e['UserName'] ?? '',
              categoryId: e['CategoryID'] ?? 0,
              categoryName: e['CategoryName'] ?? '',
              title: e['Title'] ?? '',
              description: e['Description'] ?? '',
              latitude: e['Latitude'] != null
                  ? double.tryParse(e['Latitude'].toString())
                  : null,
              longitude: e['Longitude'] != null
                  ? double.tryParse(e['Longitude'].toString())
                  : null,
              status: e['Status'] ?? '',
              createdAt: e['CreatedAt'] != null
                  ? DateTime.parse(e['CreatedAt'])
                  : DateTime.now(),
              updatedAt: e['UpdatedAt'] != null
                  ? DateTime.tryParse(e['UpdatedAt'])
                  : null,
              images:
                  (e['Images'] as List?)
                      ?.map((img) => img.toString())
                      .toList() ??
                  [],
            ),
          )
          .toList();
    } else {
      throw Exception('Harita raporları alınamadı');
    }
  }

  static Future<void> createReport({
    required int universityId,
    required int userId,
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
    String status = "Acik",
    List<String>? images,
  }) async {
    final body = {
      'UniversityID': universityId,
      'UserID': userId,
      'CategoryID': categoryId,
      'Title': title,
      'Description': description,
      'Latitude': latitude,
      'Longitude': longitude,
      'Status': status,
      'images': images ?? [],
    };
    // DEBUG: Gönderilen body'yi logla
    print('createReport body: ' + body.toString());
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/reports/create'),
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Bildirim gönderilemedi: ${response.body}');
    }
  }
}
