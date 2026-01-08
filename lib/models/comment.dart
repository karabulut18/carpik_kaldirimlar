import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String postId; // Added field
  final String id;
  final String text;
  final String authorName;
  final String authorId;
  final DateTime date;

  Comment({
    required this.id,
    required this.postId,
    required this.text,
    required this.authorName,
    required this.authorId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'text': text,
      'authorName': authorName,
      'authorId': authorId,
      'date': Timestamp.fromDate(date),
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
    );
  }
}
