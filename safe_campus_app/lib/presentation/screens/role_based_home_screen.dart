import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/presentation/screens/uni_admin/uni_admin_home_screen.dart';
import 'package:safe_campus_app/presentation/screens/super_admin/super_admin_home_screen.dart';

class RoleBasedHomeScreen extends StatelessWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı.')));
    }
    if (user.role == 'superadmin') {
      return const SuperAdminHomeScreen();
    } else if (user.role == 'uniadmin') {
      return const UniAdminHomeScreen();
    } else {
      return const Scaffold(
        body: Center(child: Text('Bu panel sadece adminler içindir.')),
      );
    }
  }
}
