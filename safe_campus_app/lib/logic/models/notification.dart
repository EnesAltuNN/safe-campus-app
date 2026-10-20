class NotificationClass {
  // Sadece id ile minimal bir notification oluşturmak için
  factory NotificationClass.minimal({required int id}) {
    return NotificationClass(
      id: id,
      reportId: id,
      universityId: 0,
      userId: 0,
      categoryId: 0,
      title: '',
      description: '',
      latitude: 0.0,
      longitude: 0.0,
      status: '',
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }
  final int id;
  final int reportId; // Her bildirime ait default artan ID
  final int universityId; // Üniversite ID'ye göre
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt; // Güncelleme tarihi boş olabilir??

  NotificationClass({
    required this.id,
    required this.reportId,
    required this.universityId,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}
