class CampusPolygon {
  final int polygonId;
  final int universityId;
  final dynamic geojson; // GeoJSON objesi veya string
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CampusPolygon({
    required this.polygonId,
    required this.universityId,
    required this.geojson,
    this.createdAt,
    this.updatedAt,
  });

  factory CampusPolygon.fromJson(Map<String, dynamic> json) {
    return CampusPolygon(
      polygonId: json['PolygonID'] ?? 0,
      universityId: json['UniversityID'] ?? 0,
      geojson: json['GeoJSON'],
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PolygonID': polygonId,
      'UniversityID': universityId,
      'GeoJSON': geojson,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}
