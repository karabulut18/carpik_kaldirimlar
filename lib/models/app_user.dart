import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? bio;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'user',
    this.bio,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'name': name,
      'role': role,
      'bio': bio,
      // createdAt is usually server timestamp on creation, so maybe distinct logic for that
    };
  }
}
