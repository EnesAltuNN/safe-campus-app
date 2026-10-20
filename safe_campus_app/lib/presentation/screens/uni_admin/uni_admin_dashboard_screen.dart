import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/uni_admin_service.dart';
import 'package:safe_campus_app/logic/models/uni_admin_dashboard_stats.dart';

class UniAdminDashboardScreen extends StatefulWidget {
  const UniAdminDashboardScreen({super.key});

  @override
  State<UniAdminDashboardScreen> createState() =>
      _UniAdminDashboardScreenState();
}

class _UniAdminDashboardScreenState extends State<UniAdminDashboardScreen> {
  late Future<UniAdminDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = UniAdminService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üniversite Dashboard')),
      body: FutureBuilder<UniAdminDashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: \\${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Veri bulunamadı.'));
          }
          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Toplam Kullanıcı'),
                  trailing: Text(stats.totalUsers.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Toplam Rapor'),
                  trailing: Text(stats.totalReports.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Açık Rapor'),
                  trailing: Text(stats.openReports.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Çözülen Rapor'),
                  trailing: Text(stats.closedReports.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Son 7 Gün Raporu'),
                  trailing: Text(stats.reportsLast7Days.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Okunmamış Alert'),
                  trailing: Text(stats.unreadAlerts.toString()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
