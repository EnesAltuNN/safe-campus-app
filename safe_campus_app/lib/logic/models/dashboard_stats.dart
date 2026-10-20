class DashboardStats {
  final int toplamKullanici;
  final int toplamRapor;
  final int acikRapor;
  final int cozulmusRapor;
  final List<LastReport> son10Rapor;
  final List<UniversityUserCount> universiteBazliKullanici;
  final List<CategoryReportCount> kategoriBazliRapor;

  DashboardStats({
    required this.toplamKullanici,
    required this.toplamRapor,
    required this.acikRapor,
    required this.cozulmusRapor,
    required this.son10Rapor,
    required this.universiteBazliKullanici,
    required this.kategoriBazliRapor,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      toplamKullanici: json['toplamKullanici'] as int,
      toplamRapor: json['toplamRapor'] as int,
      acikRapor: json['acikRapor'] as int,
      cozulmusRapor: json['cozulmusRapor'] as int,
      son10Rapor: (json['son10Rapor'] as List)
          .map((e) => LastReport.fromJson(e))
          .toList(),
      universiteBazliKullanici: (json['universiteBazliKullanici'] as List)
          .map((e) => UniversityUserCount.fromJson(e))
          .toList(),
      kategoriBazliRapor: (json['kategoriBazliRapor'] as List)
          .map((e) => CategoryReportCount.fromJson(e))
          .toList(),
    );
  }
}

class LastReport {
  final int reportId;
  final String title;
  final String status;
  final DateTime createdAt;
  final String universityName;

  LastReport({
    required this.reportId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.universityName,
  });

  factory LastReport.fromJson(Map<String, dynamic> json) {
    return LastReport(
      reportId: json['ReportID'] as int,
      title: json['Title'] as String,
      status: json['Status'] as String,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      universityName: json['UniversityName'] as String,
    );
  }
}

class UniversityUserCount {
  final String name;
  final int userCount;

  UniversityUserCount({required this.name, required this.userCount});

  factory UniversityUserCount.fromJson(Map<String, dynamic> json) {
    return UniversityUserCount(
      name: json['Name'] as String,
      userCount: json['UserCount'] as int,
    );
  }
}

class CategoryReportCount {
  final String categoryName;
  final int reportCount;

  CategoryReportCount({required this.categoryName, required this.reportCount});

  factory CategoryReportCount.fromJson(Map<String, dynamic> json) {
    return CategoryReportCount(
      categoryName: json['CategoryName'] as String,
      reportCount: json['ReportCount'] as int,
    );
  }
}
