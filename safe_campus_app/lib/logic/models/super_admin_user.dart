class SuperAdminUser {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final int universityId;
  final String universityName;

  SuperAdminUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.universityId,
    required this.universityName,
  });

  factory SuperAdminUser.fromJson(Map<String, dynamic> json) {
    return SuperAdminUser(
      userId: json['UserID'] ?? 0,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      role: json['Role'] ?? '',
      universityId: json['UniversityID'] ?? 0,
      universityName: json['UniversityName'] ?? '',
    );
  }
}
