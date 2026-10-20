class UniAdminDashboardStats {
  final int totalUsers;
  final int totalReports;
  final int openReports;
  final int closedReports;
  final int reportsLast7Days;
  final int unreadAlerts;

  UniAdminDashboardStats({
    required this.totalUsers,
    required this.totalReports,
    required this.openReports,
    required this.closedReports,
    required this.reportsLast7Days,
    required this.unreadAlerts,
  });

  factory UniAdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return UniAdminDashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalReports: json['totalReports'] ?? 0,
      openReports: json['openReports'] ?? 0,
      closedReports: json['closedReports'] ?? 0,
      reportsLast7Days: json['reportsLast7Days'] ?? 0,
      unreadAlerts: json['unreadAlerts'] ?? 0,
    );
  }
}
