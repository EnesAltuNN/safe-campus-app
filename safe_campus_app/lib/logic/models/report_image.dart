class ReportImage {
  final String url;

  ReportImage({required this.url});

  factory ReportImage.fromJson(Map<String, dynamic> json) {
    return ReportImage(
      url: json['url'] ?? json['Url'] ?? json['image'] ?? json['Image'] ?? '',
    );
  }
}
