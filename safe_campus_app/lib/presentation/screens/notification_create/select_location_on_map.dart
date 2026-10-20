import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/map_service.dart';

class SelectLocationOnMapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const SelectLocationOnMapScreen({Key? key, this.initialLocation})
    : super(key: key);

  @override
  State<SelectLocationOnMapScreen> createState() =>
      _SelectLocationOnMapScreenState();
}

class _SelectLocationOnMapScreenState extends State<SelectLocationOnMapScreen> {
  LatLng? _selectedLocation;
  LatLng? _initialCenter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _loadInitialCenter();
  }

  Future<void> _loadInitialCenter() async {
    final user = AuthService.currentUser;
    if (user?.universityId != null) {
      try {
        final polygon = await MapService.getPolygonByUniversity(
          user!.universityId!,
        );
        final center = _getPolygonCenter(polygon.geojson);
        setState(() {
          _initialCenter = center;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _initialCenter = LatLng(39.925533, 32.866287);
          _loading = false;
        });
      }
    } else {
      setState(() {
        _initialCenter = LatLng(39.925533, 32.866287);
        _loading = false;
      });
    }
  }

  LatLng _getPolygonCenter(dynamic geojson) {
    final List coords = geojson['coordinates'][0];
    double avgLat = 0;
    double avgLng = 0;
    for (final c in coords) {
      avgLat += c[1];
      avgLng += c[0];
    }
    avgLat /= coords.length;
    avgLng /= coords.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konum Seç')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter:
                    _selectedLocation ??
                    _initialCenter ??
                    LatLng(39.925533, 32.866287),
                initialZoom: 15,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedLocation == null
                ? null
                : () {
                    Navigator.pop(context, _selectedLocation);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Konumu Kaydet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
