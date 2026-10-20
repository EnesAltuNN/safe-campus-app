import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _sendingCode = false;
  String? _codeSendError;
  String? _codeSendSuccess;
  String? _testResetCode; // Test için ekrana yazdırılacak kod

  Future<void> _sendResetCode() async {
    setState(() {
      _sendingCode = true;
      _codeSendError = null;
      _codeSendSuccess = null;
      _testResetCode = null;
    });
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _codeSendError = 'Lütfen e-posta adresinizi girin.';
        _sendingCode = false;
      });
      return;
    }
    try {
      // AuthService.forgotPassword fonksiyonu çağrılıyor
      final result = await AuthService.forgotPassword(email: email);
      setState(() {
        _codeSendSuccess = result['message'] ?? 'Kod gönderildi.';
        _testResetCode = result['resetCode']?.toString();
      });
    } catch (e) {
      setState(() {
        _codeSendError = 'Kod gönderilemedi: $e';
      });
    } finally {
      setState(() {
        _sendingCode = false;
      });
    }
  }

  bool _notificationsEnabled = true;
  Future<void> _toggleNotificationPermission(bool enable) async {
    if (enable) {
      final status = await Permission.notification.request();
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
      if (!status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim izni verilmedi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Bildirim izni devre dışı bırakmak için kullanıcıyı ayarlara yönlendir
      await openAppSettings();
      // Kullanıcı ayarlardan kapatırsa, tekrar kontrol edelim
      final status = await Permission.notification.status;
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
      if (status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim izni uygulama ayarlarından kapatılabilir.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _changingPassword = false;
  String? _passwordError;
  String? _passwordSuccess;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak bildirim izni açık, gerçek değeri servisten çekebilirsiniz.
    _notificationsEnabled = true;
  }

  void _resetPassword() async {
    setState(() {
      _changingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();
    if (newPass != confirmPass) {
      setState(() {
        _passwordError = 'Yeni şifreler eşleşmiyor.';
        _changingPassword = false;
      });
      return;
    }
    try {
      final msg = await AuthService.resetPassword(
        email: email,
        code: code,
        newPassword: newPass,
      );
      setState(() {
        _passwordSuccess = msg;
        _emailController.clear();
        _codeController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _passwordError = 'Şifre değiştirilemedi: $e';
      });
    } finally {
      setState(() {
        _changingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Kullanıcı Bilgileri
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 36),
              title: Text(user?.fullName ?? 'Kullanıcı'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          const SizedBox(height: 24),
          // Bildirim izinleri
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (val) => _toggleNotificationPermission(val),
            title: const Text('Bildirimlere izin ver'),
            secondary: const Icon(Icons.notifications_active),
          ),
          const SizedBox(height: 24),
          // Şifre sıfırlama
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şifre Sıfırla',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _sendingCode ? null : _sendResetCode,
                          child: _sendingCode
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Kodu Gönder'),
                        ),
                      ),
                    ],
                  ),
                  if (_codeSendError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        _codeSendError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_codeSendSuccess != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        _codeSendSuccess!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  if (_testResetCode != null && _testResetCode!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Test kodu: ${_testResetCode!}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Kod'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Yeni Şifre'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Şifre (Tekrar)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_passwordError != null)
                    Text(
                      _passwordError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (_passwordSuccess != null)
                    Text(
                      _passwordSuccess!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _changingPassword ? null : _resetPassword,
                    child: _changingPassword
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Şifreyi Sıfırla'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
