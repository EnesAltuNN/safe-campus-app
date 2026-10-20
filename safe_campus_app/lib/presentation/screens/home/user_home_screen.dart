import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/presentation/screens/map/campus_polygon_screen.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';

/// Normal kullanıcılar için ana sayfa
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı bilgileri kartı
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: _buildUserInfoCard(context, user),
            ),
            const SizedBox(height: 24),

            // Hızlı erişim butonları
            Text(
              'Hızlı Erişim',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.notifications,
                    title: 'Bildirimler',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.notificationScreen);
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.report_problem,
                    title: 'Sorun Bildir',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.notificationCreateScreen,
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.map,
                    title: 'Kampüs Haritası',
                    color: Colors.green,
                    onTap: () {
                      final user = AuthService.currentUser;
                      if (user?.universityId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampusPolygonScreen(
                              universityId: user!.universityId!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Üniversite bilgisi bulunamadı'),
                          ),
                        );
                      }
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.notifications_active,
                    title: 'Benim Alertlerim',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.myAlertsScreen);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[400],
              child: Text(
                user?.fullName.isNotEmpty == true
                    ? user!.fullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Kullanıcı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kullanıcı',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ...existing code...

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                (route) => false,
              );
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
