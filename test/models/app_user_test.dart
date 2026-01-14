import 'package:flutter_test/flutter_test.dart';
import 'package:carpik_kaldirimlar/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('AppUser Model Tests', () {
    test('should parse valid map correctly', () {
      final map = {
        'email': 'saka@example.com',
        'name': 'Saka',
        'username': 'saka123',
        'role': 'admin',
        'bio': 'Developer',
        'createdAt': Timestamp.now(),
      };

      final user = AppUser.fromMap('user1', map);

      expect(user.id, 'user1');
      expect(user.isAdmin, true);
      expect(user.username, 'saka123');
      expect(user.createdAt, isNotNull);
    });

    test('should generate default username from email if missing', () {
      final map = {
        'email': 'john.doe@example.com',
        'name': 'John',
        // username missing
      };

      final user = AppUser.fromMap('user2', map);

      expect(user.username, 'john.doe'); // split('@')[0]
      expect(user.role, 'user'); // Default role
      expect(user.isAdmin, false);
    });

    test('should handle completely missing fields gracefully', () {
      final map = <String, dynamic>{}; // Empty map

      final user = AppUser.fromMap('user3', map);

      expect(user.email, '');
      expect(user.name, '');
      expect(user.username, 'user'); // Fallback logic
      expect(user.role, 'user');
    });
  });
}
