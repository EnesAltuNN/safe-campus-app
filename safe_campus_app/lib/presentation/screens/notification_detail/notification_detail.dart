import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_campus_app/presentation/screens/map/campus_polygon_screen.dart';
import 'package:safe_campus_app/services/report_service.dart';
import 'package:safe_campus_app/services/super_admin_report_actions.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/logic/models/report.dart';
import 'package:safe_campus_app/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_campus_app/logic/models/notification.dart';
import 'package:safe_campus_app/presentation/screens/notification_detail/widgets/status_chip.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final NotificationClass notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  bool _loading = false;
  String? _error;
  Report? _report;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailAndImages();
  }

  Future<void> _fetchDetailAndImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await ReportService.getReportById(widget.notification.id);
      final imagesRaw = await ReportService.getReportImages(
        widget.notification.id,
      );
      // notification_screen.dart'taki gibi '/uploads/' önekini kaldır
      final images = imagesRaw
          .map(
            (url) => url.startsWith('/uploads/')
                ? url.substring('/uploads/'.length)
                : url,
          )
          .toList();
      setState(() {
        _report = report;
        _images = images;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Detaylar alınamadı: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim Detayı')),
        body: Center(
          child: Text(_error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    void showImageDialog(String imageUrl) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        width: 300,
                        height: 300,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final title = _report?.title ?? widget.notification.title;
    final description = _report?.description ?? widget.notification.description;
    final status = _report?.status ?? widget.notification.status;
    final createdAt = _report?.createdAt ?? widget.notification.createdAt;
    final updatedAt = _report?.updatedAt ?? widget.notification.updatedAt;
    final latitude = _report?.latitude ?? widget.notification.latitude;
    final longitude = _report?.longitude ?? widget.notification.longitude;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Bildirim Detayı",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusChip(status: status),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 15),
            if (_images.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => showImageDialog(_images[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _images[i],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          width: 90,
                          height: 90,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            if (createdAt != null)
              Text(
                'Eklenme Tarihi: ${_formatDateTime(createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            const SizedBox(height: 5),
            if (updatedAt != null)
              Text(
                'Son Güncelleme Tarihi: ${_formatDateTime(updatedAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            const SizedBox(height: 25),
            Text(
              'Açıklama',
              style: const TextStyle(color: Colors.green, fontSize: 17),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF162620),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Konum',
              style: const TextStyle(color: Colors.green, fontSize: 17),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CampusPolygonScreen(
                      universityId:
                          _report?.universityId ??
                          widget.notification.universityId,
                    ),
                  ),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: (latitude != null && longitude != null)
                              ? LatLng(latitude, longitude)
                              : LatLng(39.925533, 32.866287),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          if (latitude != null && longitude != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(latitude, longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.8 * 255).toInt()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.map, color: Colors.black, size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Haritada Aç",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
