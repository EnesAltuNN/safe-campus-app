import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';
import 'package:safe_campus_app/core/constants/texts/app_texts.dart';
import 'package:safe_campus_app/presentation/screens/signup/widget/uni_search.dart';
import 'package:safe_campus_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedUniversity;
  int? _selectedUniversityId;
  bool _loading = false;
  String? _error;
  String? _success;

  // Sadece 5 üniversite ve sabit eşleşme
  static const Map<String, int> _universityMap = {
    'Atatürk Üniversitesi': 1,
    'İstanbul Teknik Üniversitesi': 2,
    'Erzurum Teknik Üniversitesi': 3,
    'Orta Doğu Teknik Üniversitesi': 4,
    'Yıldız Teknik Üniversitesi': 5,
  };
  int? _getUniversityId(String? name) {
    if (name == null) return null;
    return _universityMap[name];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            children: [
              Text(
                Texts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: Texts.firstName,
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Ad gerekli' : null,
                          ),
                        ),
                        SizedBox(width: Sizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: Texts.lastName,
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Soyad gerekli' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwInputFields),
                    // Üniversite seçimi
                    DropdownButtonFormField<String>(
                      value: _selectedUniversity,
                      items: _universityMap.keys
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedUniversity = val;
                          _selectedUniversityId = _getUniversityId(val);
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Üniversite',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Üniversite gerekli' : null,
                    ),
                    const SizedBox(height: Sizes.spaceBtwInputFields),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: Texts.email,
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'E-posta gerekli' : null,
                    ),
                    const SizedBox(height: Sizes.spaceBtwInputFields),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: Texts.password,
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'Şifre en az 6 karakter olmalı'
                          : null,
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_success != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _success!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : Text(Texts.createAccount),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final universityId = _selectedUniversityId;
      if (universityId == null) throw Exception('Üniversite seçimi hatalı');
      final resp = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
        universityId: universityId,
      );
      setState(() {
        _success = 'Kayıt başarılı! Giriş yapabilirsiniz.';
      });
    } catch (e) {
      setState(() {
        _error = 'Kayıt başarısız: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
