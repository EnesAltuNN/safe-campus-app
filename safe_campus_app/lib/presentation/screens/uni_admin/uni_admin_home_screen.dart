import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class UniAdminHomeScreen extends StatelessWidget {
  const UniAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üniversite Admin Paneli'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              AuthService.logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.people,
              title: 'Kullanıcı Yönetimi',
              color: Colors.indigo,
              onTap: () => Navigator.pushNamed(context, '/uni-admin-users'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.notifications,
              title: 'Alert Gönder',
              color: Colors.orange,
              onTap: () =>
                  Navigator.pushNamed(context, '/uni-admin-alert-send'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.list_alt,
              title: 'Alert Listesi',
              color: Colors.blue,
              onTap: () =>
                  Navigator.pushNamed(context, '/uni-admin-alert-list'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.report,
              title: 'Raporlar',
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, '/uni-admin-reports'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.map,
              title: 'Harita',
              color: Colors.green,
              onTap: () {
                final user = AuthService.currentUser;
                if (user?.universityId != null) {
                  Navigator.pushNamed(
                    context,
                    '/map/campus-polygon',
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
