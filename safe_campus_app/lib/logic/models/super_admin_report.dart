class SuperAdminReport {
  final int reportId;
  final int universityId;
  final String universityName;
  final int userId;
  final String userName;
  final int categoryId;
  String? categoryName;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SuperAdminReport({
    required this.reportId,
    required this.universityId,
    required this.universityName,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  factory SuperAdminReport.fromJson(Map<String, dynamic> json) {
    return SuperAdminReport(
      reportId: json['ReportID'] ?? 0,
      universityId: json['UniversityID'] ?? 0,
      universityName: json['UniversityName'] ?? '',
      userId: json['UserID'] ?? 0,
      userName: json['UserName'] ?? '',
      categoryId: json['CategoryID'] ?? 0,
      categoryName: json['CategoryName'],
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      latitude: json['Latitude'] != null
          ? double.tryParse(json['Latitude'].toString())
          : null,
      longitude: json['Longitude'] != null
          ? double.tryParse(json['Longitude'].toString())
          : null,
      status: json['Status'] ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }
}
