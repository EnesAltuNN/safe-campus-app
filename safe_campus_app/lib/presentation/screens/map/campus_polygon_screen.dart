import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_campus_app/services/map_service.dart';
import 'package:safe_campus_app/logic/models/campus_polygon.dart';
import 'package:safe_campus_app/logic/models/report.dart';
import 'package:safe_campus_app/services/report_service.dart';

class CampusPolygonScreen extends StatefulWidget {
  final int universityId;
  const CampusPolygonScreen({required this.universityId, super.key});

  @override
  State<CampusPolygonScreen> createState() => _CampusPolygonScreenState();
}

class _CampusPolygonScreenState extends State<CampusPolygonScreen> {
  // Kategori eşlemesi (ID -> İsim)
  static const Map<int, String> categoryMap = {
    1: 'Acil Durum',
    2: 'Sağlık',
    3: 'Güvenlik',
    4: 'Teknik Arıza',
    5: 'Kayıp & Buluntu',
    6: 'Temizlik',
    7: 'Bilişim & İnternet',
    8: 'Yemekhane',
    9: 'Diğer',
  };
  CampusPolygon? _polygon;
  List<Report> _mapReports = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory;

  // Kategori renk eşlemesi (ID -> Color)
  static const Map<int, Color> categoryColors = {
    1: Colors.red, // Acil Durum
    2: Colors.green, // Sağlık
    3: Colors.blue, // Güvenlik
    4: Colors.orange, // Teknik Arıza
    5: Colors.purple, // Kayıp & Buluntu
    6: Colors.teal, // Temizlik
    7: Colors.indigo, // Bilişim & İnternet
    8: Colors.brown, // Yemekhane
    9: Colors.grey, // Diğer
  };

  @override
  void initState() {
    super.initState();
    _loadPolygon();
  }

  Future<void> _loadPolygon() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final polygon = await MapService.getPolygonByUniversity(
        widget.universityId,
      );
      final mapReports = await ReportService.getMapReports();
      debugPrint('Polygon veri: \n');
      debugPrint(polygon.geojson.toString());
      setState(() {
        _polygon = polygon;
        _mapReports = mapReports;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPolygon =
        _polygon != null &&
        _polygon!.geojson != null &&
        _polygon!.geojson['coordinates'] != null &&
        _polygon!.geojson['coordinates'].isNotEmpty;
    final filteredReports = _selectedCategory == null
        ? _mapReports
        : _mapReports
              .where((r) => r.categoryId.toString() == _selectedCategory)
              .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kampüs Poligonu')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : !hasPolygon
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Polygon verisi bulunamadı veya eksik.'),
                  if (_polygon != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _polygon!.geojson.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            )
          : Column(
              children: [
                // Kategori seçimi üstte gösterilmiyor, sağ alttaki buton ile açılacak
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _getPolygonCenter(_polygon!.geojson),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _parseGeoJsonToLatLng(_polygon!.geojson),
                            color: Colors.blue.withOpacity(0.2),
                            borderStrokeWidth: 2,
                            borderColor: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: filteredReports
                            .where(
                              (r) => r.latitude != null && r.longitude != null,
                            )
                            .map(
                              (r) => Marker(
                                width: 40,
                                height: 40,
                                point: LatLng(r.latitude!, r.longitude!),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(r.title),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Durum: ${r.status}'),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Kategori: ${categoryMap[r.categoryId] ?? r.categoryName}',
                                            ),
                                            const SizedBox(height: 8),
                                            Text('Açıklama: ${r.description}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Kapat'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color:
                                        categoryColors[r.categoryId ?? 9] ??
                                        Colors.grey,
                                    size: 36,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selected = await showDialog<String>(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Kategori Seç'),
                children: [
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Tümü'),
                  ),
                  ...categoryMap.entries.map(
                    (entry) => SimpleDialogOption(
                      onPressed: () =>
                          Navigator.pop(context, entry.key.toString()),
                      child: Text('${entry.value} (${entry.key})'),
                    ),
                  ),
                ],
              );
            },
          );
          if (selected != null || selected == null) {
            setState(() {
              _selectedCategory = selected;
            });
          }
        },
        child: const Icon(Icons.category),
        tooltip: 'Kategori Seç',
      ),
    );
  }

  List<LatLng> _parseGeoJsonToLatLng(dynamic geojson) {
    final List coords = geojson['coordinates'][0];
    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }

  LatLng _getPolygonCenter(dynamic geojson) {
    final coords = _parseGeoJsonToLatLng(geojson);
    double avgLat = 0;
    double avgLng = 0;
    for (final point in coords) {
      avgLat += point.latitude;
      avgLng += point.longitude;
    }
    avgLat /= coords.length;
    avgLng /= coords.length;
    return LatLng(avgLat, avgLng);
  }

  // Kategori rengi artık categoryId üzerinden atanıyor, bu fonksiyon kaldırıldı.
}
