import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/alert_service.dart';
import 'package:safe_campus_app/logic/models/alert.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/university_service.dart';
import 'package:safe_campus_app/logic/models/university.dart';

class UniAdminAlertListScreen extends StatefulWidget {
  UniAdminAlertListScreen({Key? key}) : super(key: key);

  @override
  State<UniAdminAlertListScreen> createState() =>
      _UniAdminAlertListScreenState();
}

class _UniAdminAlertListScreenState extends State<UniAdminAlertListScreen> {
  List<Alert> _alerts = [];
  bool _isLoading = true;
  String? _error;
  University? _university;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _loadUniversity();
  }

  Future<void> _loadUniversity() async {
    final universityId = AuthService.currentUser?.universityId;
    if (universityId != null) {
      try {
        final universities = await UniversityService.getAllUniversities();
        setState(() {
          _university = universities.firstWhere(
            (u) => u.universityId == universityId,
            orElse: () => University(
              universityId: universityId,
              name: 'Bilinmeyen Üniversite',
              abbreviation: '',
              logoUrl: null,
            ),
          );
        });
      } catch (_) {
        // ignore error, show fallback
      }
    }
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AlertService.getMyAlerts();
      setState(() {
        _alerts = data.map((e) => Alert.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _university != null
              ? '${_university!.name} Alertleri'
              : 'Üniversite Alertleri',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: ListView.builder(
                itemCount: _alerts.length,
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  return ListTile(
                    leading: Icon(
                      alert.isGlobal ? Icons.public : Icons.campaign,
                      color: alert.isGlobal ? Colors.red : Colors.orange,
                    ),
                    title: Text(alert.title),
                    subtitle: Text(alert.message),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatDate(alert.sentAt)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Sil',
                          onPressed: () => _confirmDeleteAlert(alert),
                        ),
                      ],
                    ),
                    onTap: () => _showAlertDetail(alert),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDeleteAlert(Alert alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Sil'),
        content: Text('Bu alerti silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteAlert(alert);
    }
  }

  Future<void> _deleteAlert(Alert alert) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AlertService.deleteAlert(alert.alertId);
      setState(() {
        _alerts.removeWhere((a) => a.alertId == alert.alertId);
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alert silindi.')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Alert silinemedi. Yetkiniz olmayabilir veya sunucu hatası.';
      });
    }
  }

  void _showAlertDetail(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesaj: ${alert.message}'),
            const SizedBox(height: 8),
            Text('Gönderen: ${alert.senderName ?? '-'}'),
            if (alert.universityName != null)
              Text('Üniversite: ${alert.universityName}'),
            if (_university != null)
              Text('Giriş yapılan üniversite: ${_university!.name}'),
            Text('Tarih: ${_formatDate(alert.sentAt)}'),
            if (alert.isGlobal)
              const Text('Genel Alert', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
