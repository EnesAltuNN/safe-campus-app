import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    Function(int reportId)? onSelectReport,
  }) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null && onSelectReport != null) {
          final reportId = int.tryParse(payload);
          if (reportId != null) {
            onSelectReport(reportId);
          }
        }
      },
    );
    // Android 13+ için bildirim izni iste
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int? reportId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'followed_report_channel',
          'Takip Edilen Raporlar',
          channelDescription:
              'Takip edilen rapor güncellemeleri için bildirimler',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: reportId?.toString(),
    );
  }
}
