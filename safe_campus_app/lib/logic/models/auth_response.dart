import 'package:safe_campus_app/logic/models/user.dart';

class AuthResponse {
  final String message;
  final String? token;
  final User? user;

  AuthResponse({required this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
