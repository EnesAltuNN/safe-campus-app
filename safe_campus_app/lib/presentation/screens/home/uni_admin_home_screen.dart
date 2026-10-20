import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/services/auth_service.dart';

/// Üniversite yöneticileri için ana sayfa
class UniAdminHomeScreen extends StatelessWidget {
  const UniAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Üniversite Yönetim Paneli'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
            // Yönetici bilgileri kartı
            _buildAdminInfoCard(context, user),
            const SizedBox(height: 24),

            // İstatistik kartları
            _buildStatsRow(context),
            const SizedBox(height: 24),

            // Yönetim menüsü
            Text(
              'Yönetim Menüsü',
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
                    icon: Icons.people,
                    title: 'Kullanıcı Yönetimi',
                    color: Colors.indigo,
                    onTap: () {
                      // TODO: Kullanıcı yönetimi sayfası
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.announcement,
                    title: 'Duyuru Yayınla',
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
                    icon: Icons.report,
                    title: 'Raporlar',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.reportsManagementScreen,
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
                        Navigator.pushNamed(
                          context,
                          Routes.campusPolygonScreen,
                          arguments: user!.universityId,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Üniversite bilgisi bulunamadı'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.security,
                    title: 'Güvenlik Durumu',
                    color: Colors.red,
                    onTap: () {
                      // TODO: Güvenlik durumu sayfası
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.analytics,
                    title: 'İstatistikler',
                    color: Colors.purple,
                    onTap: () {
                      // TODO: İstatistikler sayfası
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

  Widget _buildAdminInfoCard(BuildContext context, user) {
    return Card(
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.indigo,
              child: Text(
                user?.fullName.isNotEmpty == true
                    ? user!.fullName[0].toUpperCase()
                    : 'A',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Yönetici',
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
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Üniversite Yöneticisi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
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

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Aktif Kullanıcı',
            value: '1,234',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Bugünkü Bildirim',
            value: '23',
            icon: Icons.notification_important,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Açık Sorun',
            value: '5',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
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
