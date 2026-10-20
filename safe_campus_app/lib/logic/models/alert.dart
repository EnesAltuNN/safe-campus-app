class Alert {
  final int alertId;
  final int? universityId;
  final String? universityName;
  final int? senderId;
  final String? senderName;
  final String title;
  final String message;
  final bool isGlobal;
  final DateTime sentAt;
  final bool? isRead;

  Alert({
    required this.alertId,
    this.universityId,
    this.universityName,
    this.senderId,
    this.senderName,
    required this.title,
    required this.message,
    required this.isGlobal,
    required this.sentAt,
    this.isRead,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertId: json['AlertID'] ?? json['alertId'] ?? 0,
      universityId: json['UniversityID'],
      universityName: json['UniversityName'],
      senderId: json['SenderID'],
      senderName: json['SenderName'],
      title: json['Title'] ?? json['title'] ?? '',
      message: json['Message'] ?? json['message'] ?? '',
      isGlobal:
          (json['IsGlobal'] ?? json['isGlobal'] ?? 0) == 1 ||
          (json['IsGlobal'] ?? json['isGlobal']) == true,
      sentAt: DateTime.parse(
        json['SentAt'] ?? json['sentAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['IsRead'] == null
          ? null
          : (json['IsRead'] == 1 || json['IsRead'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AlertID': alertId,
      'UniversityID': universityId,
      'UniversityName': universityName,
      'SenderID': senderId,
      'SenderName': senderName,
      'Title': title,
      'Message': message,
      'IsGlobal': isGlobal ? 1 : 0,
      'SentAt': sentAt.toIso8601String(),
      'IsRead': isRead,
    };
  }
}
