import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/core/constants/icon_and_image_string/icon_and_image_string.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';
import 'package:safe_campus_app/core/constants/texts/app_texts.dart';
import 'package:safe_campus_app/core/helper/helper_functions.dart';
import 'package:safe_campus_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Başarılı giriş - Ana sayfaya yönlendir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hoş geldin, ${response.user?.fullName ?? "Kullanıcı"}!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Kullanıcı rolüne göre yönlendirme
      final String targetRoute = _getHomeRouteByRole(response.user?.role);
      Navigator.pushReplacementNamed(context, targetRoute);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kullanıcı rolüne göre yönlendirilecek ana sayfa route'unu döndürür
  String _getHomeRouteByRole(String? role) {
    switch (role) {
      case 'SuperAdmin':
        return Routes.superAdminHomeScreen;
      case 'UniAdmin':
        return Routes.uniAdminHomeScreen;
      case 'User':
      default:
        return Routes.userHomeScreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: Sizes.appbarHeight,
            left: Sizes.defaultSpace,
            bottom: Sizes.defaultSpace,
            right: Sizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo, Title, & Sub-title
              Image(
                height: 150,
                image: AssetImage(
                  dark
                      ? IconAndImageString.darkAppLogo
                      : IconAndImageString.lightAppLogo,
                ),
              ),
              Text(
                Texts.loginTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: Sizes.sm),
              Text(
                Texts.loginSubTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Form
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.spaceBtwSections,
                  ),
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email adresi gerekli';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir email adresi girin';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          labelText: Texts.email,
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre gerekli';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          labelText: Texts.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields / 2),

                      // Remember Me & Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Remember Me
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? true;
                                  });
                                },
                              ),
                              const Text(Texts.rememberMe),
                            ],
                          ),
                          //Forget Password
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.forgotPasswordScreen,
                              );
                            },
                            child: Text(Texts.forgetPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.spaceBtwSections),
                      // Sign In Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(Sizes.buttonRadius),
                          ),
                        ),
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(Texts.signIn),
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.signUpPage);
                          },
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                side: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.circular(
                                  Sizes.inputFieldRadius,
                                ),
                              ),
                            ),
                          ),
                          child: Text(Texts.createAccount),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
