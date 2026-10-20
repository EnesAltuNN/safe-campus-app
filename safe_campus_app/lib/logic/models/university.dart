class University {
  final int universityId;
  final String name;
  final String? abbreviation;
  final String? logoUrl;

  University({
    required this.universityId,
    required this.name,
    this.abbreviation,
    this.logoUrl,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      universityId: json['UniversityID'] ?? json['universityId'] ?? 0,
      name: json['Name'] ?? json['name'] ?? '',
      abbreviation: json['Abbreviation'] ?? json['abbreviation'],
      logoUrl: json['LogoUrl'] ?? json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UniversityID': universityId,
      'Name': name,
      'Abbreviation': abbreviation,
      'LogoUrl': logoUrl,
    };
  }
}
