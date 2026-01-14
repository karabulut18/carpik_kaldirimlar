import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String postId; // Added field
  final String id;
  final String text;
  final String authorName;
  final String authorId;
  final DateTime date;
  final List<String> likes;
  final String? replyToId;
  final String? replyToUserName;
  final int depth;

  Comment({
    required this.id,
    required this.postId,
    required this.text,
    required this.authorName,
    required this.authorId,
    required this.date,
    this.likes = const [],
    this.replyToId,
    this.replyToUserName,
    this.depth = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'text': text,
      'authorName': authorName,
      'authorId': authorId,

      'date': Timestamp.fromDate(date),
      'likes': likes,
      'replyToId': replyToId,
      'replyToUserName': replyToUserName,
      'depth': depth,
    };
  }

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    // Handle date being either int (legacy) or Timestamp (Firestore)
    DateTime date;
    if (map['date'] is Timestamp) {
      date = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is int) {
      date = DateTime.fromMillisecondsSinceEpoch(map['date']);
    } else {
      date = DateTime.now();
    }

    return Comment(
      id: id,
      postId: map['postId'] ?? '', // Handle missing postId for legacy/error cases
      text: map['text'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      authorId: map['authorId'] ?? '',

      date: date,
      likes: List<String>.from(map['likes'] ?? []),
      replyToId: map['replyToId'],
      replyToUserName: map['replyToUserName'],
      depth: map['depth'] ?? 0,
    );
  }
}
