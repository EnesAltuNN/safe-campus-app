import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // iOS için izin iste
    if (Platform.isIOS) {
      await _messaging.requestPermission();
    }
    // Android için otomatik izin
    await _messaging.setAutoInitEnabled(true);
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static void onMessage(Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  static void onMessageOpenedApp(Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }
}
