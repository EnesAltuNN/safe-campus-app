import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/services/auth_service.dart';

/// Süper yöneticiler için ana sayfa (tüm sistem yönetimi)
class SuperAdminHomeScreen extends StatelessWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Süper Yönetici Paneli'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
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
            // Süper admin bilgileri kartı
            _buildSuperAdminInfoCard(context, user),
            const SizedBox(height: 24),

            // Sistem genel durumu
            _buildSystemStatusCard(context),
            const SizedBox(height: 24),

            // Yönetim menüsü
            Text(
              'Sistem Yönetimi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.school,
                    title: 'Üniversiteler',
                    color: Colors.deepPurple,
                    onTap: () {
                      // TODO: Üniversite yönetimi
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: 'Yöneticiler',
                    color: Colors.indigo,
                    onTap: () {
                      // TODO: Yönetici yönetimi
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.people,
                    title: 'Tüm Kullanıcılar',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.userManagementScreen);
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.report,
                    title: 'Raporlar',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.reportsManagementScreen,
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.broadcast_on_personal,
                    title: 'Genel Alert',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.sendGlobalAlertScreen,
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.warning,
                    title: 'Tüm Alertler',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.alertListScreen);
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
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Analitik',
                    color: Colors.teal,
                    onTap: () {
                      // TODO: Analitik sayfası
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.settings,
                    title: 'Sistem Ayarları',
                    color: Colors.grey,
                    onTap: () {
                      // TODO: Ayarlar sayfası
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.backup,
                    title: 'Yedekleme',
                    color: Colors.green,
                    onTap: () {
                      // TODO: Yedekleme sayfası
                    },
                  ),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.history,
                    title: 'Log Kayıtları',
                    color: Colors.brown,
                    onTap: () {
                      // TODO: Log kayıtları sayfası
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

  Widget _buildSuperAdminInfoCard(BuildContext context, user) {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple,
              child: Text(
                user?.fullName.isNotEmpty == true
                    ? user!.fullName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Süper Yönetici',
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
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '👑 Süper Yönetici',
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

  Widget _buildSystemStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Sistem Durumu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '● Aktif',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  'Üniversite',
                  '12',
                  Colors.deepPurple,
                ),
                _buildStatusItem(
                  context,
                  'Toplam Kullanıcı',
                  '15,432',
                  Colors.blue,
                ),
                _buildStatusItem(context, 'Bugün Aktif', '2,341', Colors.green),
                _buildStatusItem(context, 'Bekleyen', '18', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
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
