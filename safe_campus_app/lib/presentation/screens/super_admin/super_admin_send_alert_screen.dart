import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/super_admin_service.dart';
import 'package:safe_campus_app/logic/models/super_admin_university.dart';
import 'package:safe_campus_app/core/constants/app_ui.dart';
import 'package:safe_campus_app/services/auth_service.dart';

class SuperAdminSendAlertScreen extends StatefulWidget {
  const SuperAdminSendAlertScreen({super.key});

  @override
  State<SuperAdminSendAlertScreen> createState() =>
      _SuperAdminSendAlertScreenState();
}

class _SuperAdminSendAlertScreenState extends State<SuperAdminSendAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  List<int> _selectedUniversityIds = [-1]; // -1: Tüm Üniversiteler
  late Future<List<SuperAdminUniversity>> _universitiesFuture;

  @override
  void initState() {
    super.initState();
    _universitiesFuture = SuperAdminService.getAllUniversities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendAlert() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Fonksiyonun en başında token bilgisini göster
      final tokenInfo = 'Token (sendAlert başı): \n${AuthService.token}\n\nHeader: ${AuthService.getAuthHeaders()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tokenInfo),
          backgroundColor: Colors.deepPurple,
          duration: const Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      final title = _titleController.text.trim();
      final message = _messageController.text.trim();
      final isGlobal = _selectedUniversityIds.contains(-1);
      if (isGlobal) {
        // Tüm üniversitelere global alert
        await SuperAdminService.sendAlert(
          title: title,
          message: message,
          isGlobal: true,
        );
      } else {
        // Her üniversiteye ayrı ayrı alert gönder
        for (final uniId in _selectedUniversityIds) {
          await SuperAdminService.sendAlert(
            title: title,
            message: message,
            isGlobal: false,
            universityId: uniId,
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGlobal
                ? 'Alert tüm üniversitelere gönderildi!'
                : 'Alert seçili üniversitelere gönderildi!',
          ),
          backgroundColor: AppUI.successColor,
        ),
      );
      _titleController.clear();
      _messageController.clear();
      setState(() => _selectedUniversityIds = [-1]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: AppUI.dangerColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmAndSend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Onay'),
          ],
        ),
        content: Text(
          _selectedUniversityIds.contains(-1)
              ? 'Bu alert TÜM üniversitelere gönderilecektir.\n\nDevam etmek istediğinize emin misiniz?'
              : 'Bu alert sadece seçili üniversitelere gönderilecektir.\n\nDevam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendAlert();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppUI.dangerColor),
            child: const Text('Gönder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel Alert Gönder (SuperAdmin)'),
        backgroundColor: Colors.red,
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
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedUniversityIds.contains(-1)
                              ? 'Bu alert TÜM üniversitelere gönderilecektir!\nSadece acil durumlar için kullanın.'
                              : 'Bu alert sadece seçili üniversitelere gönderilecektir.',
                          style: TextStyle(
                            color: Colors.red[700],
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
              const SizedBox(height: 16),
              FutureBuilder<List<SuperAdminUniversity>>(
                future: _universitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Hata: \'${snapshot.error}\'');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Üniversite bulunamadı.');
                  }
                  final universities = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hedef Üniversiteler:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      CheckboxListTile(
                        value: _selectedUniversityIds.contains(-1),
                        title: const Text('Tüm Üniversiteler'),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedUniversityIds = [-1];
                            } else {
                              _selectedUniversityIds = [];
                            }
                          });
                        },
                      ),
                      ...universities.map(
                        (u) => CheckboxListTile(
                          value: _selectedUniversityIds.contains(
                            u.universityId,
                          ),
                          title: Text(u.name),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedUniversityIds.remove(-1);
                                _selectedUniversityIds.add(u.universityId);
                              } else {
                                _selectedUniversityIds.remove(u.universityId);
                                if (_selectedUniversityIds.isEmpty) {
                                  _selectedUniversityIds = [-1];
                                }
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _confirmAndSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Gönderiliyor...' : 'Alert Gönder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
