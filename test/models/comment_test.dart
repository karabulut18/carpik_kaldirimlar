import 'package:flutter_test/flutter_test.dart';
import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Comment Model Tests', () {
    test('should parse valid map correctly', () {
      final date = DateTime.now();
      final map = {
        'postId': 'post1',
        'text': 'Hello World',
        'authorName': 'Saka',
        'authorId': 'user1',
        'date': Timestamp.fromDate(date),
        'likes': ['user2'],
        'replyToId': null,
        'depth': 0,
      };

      final comment = Comment.fromMap('comment1', map);

      expect(comment.id, 'comment1');
      expect(comment.text, 'Hello World');
      expect(comment.likes, contains('user2'));
      expect(comment.depth, 0);
    });

    test('should handle replyToUserName correctly', () {
      final map = {
        'postId': 'post1',
        'text': 'Reply',
        'authorName': 'User2',
        'authorId': 'user2',
        'date': Timestamp.now(),
        'likes': [],
        'replyToId': 'comment1',
        'replyToUserName': 'Saka',
        'depth': 1,
      };

      final comment = Comment.fromMap('comment2', map);

      expect(comment.replyToId, 'comment1');
      expect(comment.replyToUserName, 'Saka');
      expect(comment.depth, 1);
    });

    test('should handle missing optional fields', () {
        final map = {
        'postId': 'post1',
        'text': 'Text',
        'authorName': 'User',
        'authorId': 'uid',
        'date': Timestamp.now(), 
        // likes, replyToId, replyToUserName, depth missing
      };
      
      final comment = Comment.fromMap('id', map);
      
      expect(comment.likes, isEmpty);
      expect(comment.replyToId, isNull);
      expect(comment.replyToUserName, isNull);
      expect(comment.depth, 0);
    });
  });
}
