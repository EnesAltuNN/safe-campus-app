import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/uni_admin_service.dart';

class UniAdminSendAlertScreen extends StatefulWidget {
  const UniAdminSendAlertScreen({super.key});

  @override
  State<UniAdminSendAlertScreen> createState() =>
      _UniAdminSendAlertScreenState();
}

class _UniAdminSendAlertScreenState extends State<UniAdminSendAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _loading = false;

  Future<void> _sendAlert() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await UniAdminService.sendAlert(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert başarıyla gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Gönder (Uni Admin)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.deepPurple[700], size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Bu alert sadece kendi üniversitenizdeki kullanıcılara gönderilecektir.',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Alert Başlığı',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mesaj gerekli';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Alert Mesajı',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _sendAlert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_loading ? 'Gönderiliyor...' : 'Alert Gönder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
