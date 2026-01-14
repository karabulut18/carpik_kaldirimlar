import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firestore is hard without fake_cloud_firestore, so we rely on setPosts
void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required if service uses Flutter bindings

  group('PostService Logic Tests', () {
    late PostService service;
    late List<Post> testPosts;

    setUp(() {
      service = PostService(isTest: true);
      
      // Create test data
      testPosts = [
        Post(
          id: '1',
          title: 'Post 1',
          author: 'Author 1',
          authorId: 'u1',
          date: DateTime(2025, 1, 1),
          category: 'Tech',
          tags: ['flutter', 'dart'],
          isFeatured: true, // Featured
        ),
        Post(
          id: '2',
          title: 'Post 2',
          author: 'Author 2',
          authorId: 'u2',
          date: DateTime(2025, 1, 2),
          category: 'Life',
          tags: ['flutter', 'mobile'],
          isFeatured: false,
        ),
        Post(
          id: '3',
          title: 'Post 3',
          author: 'Author 1',
          authorId: 'u1',
          date: DateTime(2025, 1, 3),
          category: 'Tech',
          tags: ['web'],
          isFeatured: false,
        ),
      ];

      // Inject data
      service.setPosts(testPosts);
    });

    test('getPostsByCategory should filter correctly', () {
      final techPosts = service.getPostsByCategory('Tech');
      expect(techPosts.length, 2);
      expect(techPosts.first.id, '1');
      expect(techPosts.last.id, '3');

      final lifePosts = service.getPostsByCategory('Life');
      expect(lifePosts.length, 1);
      expect(lifePosts.first.title, 'Post 2');
    });

    test('getPostsByCategory "Genel" should return all posts', () {
      final allPosts = service.getPostsByCategory('Genel');
      expect(allPosts.length, 3);
    });

    test('getPostsByTag should filter correctly', () {
      final flutterPosts = service.getPostsByTag('flutter');
      expect(flutterPosts.length, 2); // Post 1 & 2

      final webPosts = service.getPostsByTag('web');
      expect(webPosts.length, 1); // Post 3
      
      final unknownPosts = service.getPostsByTag('java');
      expect(unknownPosts, isEmpty);
    });

    test('featuredPosts should return only featured posts', () {
      final featured = service.featuredPosts;
      expect(featured.length, 1);
      expect(featured.first.title, 'Post 1');
    });
  });
}
