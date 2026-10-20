class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? universityId;
  final int? unitId;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.universityId,
    this.unitId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Map backend fields (UserID, FullName, etc.) to Dart model fields
    return User(
      id: json['UserID'] ?? json['id'] ?? 0,
      fullName: json['FullName'] ?? json['fullName'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      role: json['Role'] ?? json['role'] ?? '',
      universityId: json['UniversityID'] ?? json['universityId'],
      unitId: json['UnitID'] ?? json['unitId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'universityId': universityId,
      'unitId': unitId,
    };
  }
}
