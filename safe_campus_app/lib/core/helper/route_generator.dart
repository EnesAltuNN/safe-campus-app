import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/logic/models/notification.dart';
import 'package:safe_campus_app/presentation/screens/admin/reports_management_screen.dart';
import 'package:safe_campus_app/presentation/screens/admin/send_global_alert_screen.dart';
import 'package:safe_campus_app/presentation/screens/admin/user_management_screen.dart';
import 'package:safe_campus_app/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:safe_campus_app/presentation/screens/home/home_screen.dart';
import 'package:safe_campus_app/presentation/screens/profile/profile_screen.dart';
import 'package:safe_campus_app/presentation/screens/super_admin/super_admin_home_screen.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_alert_list_screen.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_home_screen.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_reports_screen.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_send_alert_screen.dart';
// TODO: import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_alert_list_screen.dart';
import 'package:safe_campus_app/presentation/screens/home/user_home_screen.dart';
import 'package:safe_campus_app/presentation/screens/login/login_screen.dart';
import 'package:safe_campus_app/presentation/screens/notification/notification_screen.dart';
import 'package:safe_campus_app/presentation/screens/notification_create/notification_create_screen.dart';
import 'package:safe_campus_app/presentation/screens/notification_detail/notification_detail.dart';
import 'package:safe_campus_app/presentation/screens/signup/signup.dart';
import 'package:safe_campus_app/presentation/screens/admin/alert_list_screen.dart';

import 'package:safe_campus_app/presentation/screens/admin/my_alerts_screen.dart';

import 'package:safe_campus_app/presentation/screens/map/campus_polygon_screen.dart';
import 'package:safe_campus_app/presentation/screens/role_based_home_screen.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_users_screen.dart';

class RouteGenerator {
  static Route<dynamic>? _routeOlustur(
    Widget gidilecekWidget,
    RouteSettings settings,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => gidilecekWidget,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => gidilecekWidget,
      );
    } else {
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => gidilecekWidget,
      );
    }
  }

  static Route<dynamic>? routeGenerator(RouteSettings settings) {
    // Profil ekranı
    if (settings.name == Routes.profileScreen) {
      return _routeOlustur(const ProfileScreen(), settings);
    }
    switch (settings.name) {
      case '/uni-admin-reports':
        return _routeOlustur(const UniAdminReportsScreen(), settings);
      case '/uni-admin-alert-send':
        return _routeOlustur(const UniAdminSendAlertScreen(), settings);
      case '/uni-admin-alert-list':
        return _routeOlustur(UniAdminAlertListScreen(), settings);
      case '/uni-admin-users':
        return _routeOlustur(const UniAdminUsersScreen(), settings);
      case Routes.campusPolygonScreen:
        final universityId = settings.arguments as int;
        return _routeOlustur(
          CampusPolygonScreen(universityId: universityId),
          settings,
        );
      case Routes.loginScreen:
        return _routeOlustur(LoginScreen(), settings);
      case Routes.signUpPage:
        return _routeOlustur(SignupScreen(), settings);
      case Routes.homeScreen:
        return _routeOlustur(HomeScreen(), settings);
      case Routes.roleBasedHomeScreen:
        // Kullanıcı rolüne göre ilgili ana sayfa
        // (RoleBasedHomeScreen import edilmeli)
        // ignore: prefer_const_constructors
        return _routeOlustur(const RoleBasedHomeScreen(), settings);
      case Routes.userHomeScreen:
        return _routeOlustur(UserHomeScreen(), settings);
      case Routes.uniAdminHomeScreen:
        return _routeOlustur(const UniAdminHomeScreen(), settings);
      case Routes.superAdminHomeScreen:
        return _routeOlustur(const SuperAdminHomeScreen(), settings);
      case Routes.forgotPasswordScreen:
        return _routeOlustur(ForgotPasswordScreen(), settings);
      case Routes.notificationScreen:
        return _routeOlustur(NotificationScreen(), settings);
      case Routes.notificationCreateScreen:
        return _routeOlustur(NotificationCreateScreen(), settings);
      case Routes.notificationDetailScreen:
        var notification = settings.arguments as NotificationClass;
        return _routeOlustur(
          NotificationDetailScreen(notification: notification),
          settings,
        );
      case Routes.userManagementScreen:
        return _routeOlustur(UserManagementScreen(), settings);
      case Routes.reportsManagementScreen:
        return _routeOlustur(ReportsManagementScreen(), settings);
      case Routes.sendGlobalAlertScreen:
        return _routeOlustur(SendGlobalAlertScreen(), settings);
      case Routes.alertListScreen:
        return _routeOlustur(AlertListScreen(), settings);
      case Routes.myAlertsScreen:
        return _routeOlustur(MyAlertsScreen(), settings);

      // Bu kısım şimdilik yorum satırında kalsın
      /*       case '/':
        var parametre = settings.arguments as parametre;
        return _routeOlustur(
            SayfaAdı(
              gönderilecekParametre: parametre,
            ),
            settings); */

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('404')),
            body: Center(child: Text('Sayfa Bulunamadı')),
          ),
        );
    }
  }
}
