class SuperAdminUniversity {
  final int universityId;
  final String name;

  SuperAdminUniversity({required this.universityId, required this.name});

  factory SuperAdminUniversity.fromJson(Map<String, dynamic> json) {
    return SuperAdminUniversity(
      universityId: json['UniversityID'] ?? 0,
      name: json['Name'] ?? '',
    );
  }
}
