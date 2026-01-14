import 'package:flutter_test/flutter_test.dart';
import 'package:carpik_kaldirimlar/models/post.dart';

void main() {
  group('Post Model Tests', () {
    test('should parse valid map correctly', () {
      final date = DateTime.now();
      final map = {
        'title': 'Test Post',
        'author': 'Saka',
        'authorId': 'user1',
        'date': date.millisecondsSinceEpoch,
        'excerpt': 'Short summary',
        'content': 'Long content',
        'imageUrl': 'http://image.com',
        'viewCount': 10,
        'likes': ['user2', 'user3'],
        'tags': ['flutter', 'dart'],
        'category': 'Tech',
        'isFeatured': true,
      };

      final post = Post.fromMap('post1', map);

      expect(post.id, 'post1');
      expect(post.title, 'Test Post');
      expect(post.author, 'Saka');
      expect(post.likes.length, 2);
      expect(post.tags, contains('flutter'));
      expect(post.isFeatured, true);
    });

    test('should handle default values', () {
      final map = {
        'title': 'Minimal Post',
        'author': 'Anon',
        'authorId': 'anon1',
        // Missing date, likes, tags, category, viewCount, isFeatured
      };

      final post = Post.fromMap('post2', map);

      expect(post.likes, isEmpty);
      expect(post.tags, isEmpty);
      expect(post.viewCount, 0);
      expect(post.category, 'Genel');
      expect(post.isFeatured, false);
      // Date defaults to epoch 0 if missing in map logic
      expect(post.date, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('likeCount should return correct length', () {
      final post = Post(
        id: '1', 
        title: 'T', 
        author: 'A', 
        authorId: '1', 
        date: DateTime.now(),
        likes: ['u1', 'u2', 'u3']
      );
      
      expect(post.likeCount, 3);
    });
  });
}
