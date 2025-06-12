// lib/model/user.dart
import 'dart:convert'; // Tambahkan ini

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? accessToken;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      accessToken: json['access_token'] as String?,
    );
  }

  // Tambahkan metode ini untuk mengonversi objek User ke Map (untuk disimpan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'access_token': accessToken,
    };
  }
}