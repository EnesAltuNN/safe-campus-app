class Report {
  final int reportId;
  final int universityId;
  final String universityName;
  final int userId;
  final String userName;
  final int categoryId;
  final String categoryName;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> images;

  Report({
    required this.reportId,
    required this.universityId,
    required this.universityName,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.images = const [],
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['ReportID'] ?? 0,
      universityId: json['UniversityID'] ?? 0,
      universityName: json['UniversityName'] ?? '',
      userId: json['UserID'] ?? 0,
      userName: json['UserName'] ?? '',
      categoryId: json['CategoryID'] ?? 0,
      categoryName: json['CategoryName'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      latitude: json['Latitude'] != null
          ? double.tryParse(json['Latitude'].toString())
          : null,
      longitude: json['Longitude'] != null
          ? double.tryParse(json['Longitude'].toString())
          : null,
      status: json['Status'] ?? '',
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
      images:
          (json['Images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
