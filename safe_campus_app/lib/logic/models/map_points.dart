import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


// Bunlar daha sonra dinamik olacak
class MapPoint {
  final String title;       // Başlık (Örn: Yangın)
  final String description; // Açıklama
  final LatLng location;    // Koordinat (Enlem, Boylam)
  final Color color;        // Pin Rengi
  final IconData icon;      // İkonu

  MapPoint({
    required this.title,
    required this.description,
    required this.location,
    required this.color,
    this.icon = Icons.location_on, // Varsayılan ikon
  });
}