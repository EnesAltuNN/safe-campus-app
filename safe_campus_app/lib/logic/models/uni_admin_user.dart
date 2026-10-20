class UniAdminUser {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final int? unitId;

  UniAdminUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.unitId,
  });

  factory UniAdminUser.fromJson(Map<String, dynamic> json) {
    return UniAdminUser(
      userId: json['UserID'] ?? 0,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      role: json['Role'] ?? '',
      unitId: json['UnitID'],
    );
  }
}
