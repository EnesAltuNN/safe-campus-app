import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/alert_service.dart';
import 'package:safe_campus_app/logic/models/alert.dart';

class MyAlertsScreen extends StatefulWidget {
  const MyAlertsScreen({super.key});

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  List<Alert> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
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
        title: const Text('Benim Alertlerim'),
        backgroundColor: Colors.red,
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
                      alert.isRead == true
                          ? Icons.mark_email_read
                          : Icons.mark_email_unread,
                      color: alert.isRead == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(alert.title),
                    subtitle: Text(alert.message),
                    trailing: Text(_formatDate(alert.sentAt)),
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
            if (alert.universityName != null)
              Text('Üniversite: ${alert.universityName}'),
            Text('Tarih: ${_formatDate(alert.sentAt)}'),
            if (alert.isRead == true)
              const Text('Okundu', style: TextStyle(color: Colors.green)),
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
