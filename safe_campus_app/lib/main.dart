import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/core/helper/route_generator.dart';
import 'package:safe_campus_app/logic/models/notification.dart';
import 'package:safe_campus_app/services/notification_service.dart';
import 'package:safe_campus_app/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safe_campus_app/services/device_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  NotificationService.initialize(
    onSelectReport: (reportId) {
      // Bildirim tıklanınca rapor detayına yönlendir
      navigatorKey.currentState?.pushNamed(
        Routes.notificationDetailScreen,
        arguments: NotificationClass.minimal(id: reportId),
      );
    },
  );
  FcmService.initialize().then((_) async {
    final token = await FcmService.getToken();
    print('FCM Token: $token');
    if (token != null) {
      try {
        await DeviceService.saveFcmToken(token);
        print('FCM token backend\'e kaydedildi.');
      } catch (e) {
        print('FCM token backend\'e kaydedilemedi: $e');
      }
    }
    FcmService.onMessage((message) {
      NotificationService.showNotification(
        title: message.notification?.title ?? 'Yeni Bildirim',
        body: message.notification?.body ?? '',
      );
    });
  });
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: Routes.loginScreen,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      onGenerateRoute: RouteGenerator.routeGenerator,
    );
  }
}
