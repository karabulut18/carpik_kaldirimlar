import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String authorName;
  final String authorId;
  final DateTime date;

  Comment({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
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
      text: map['text'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      authorId: map['authorId'] ?? '',
      date: date,
    );
  }
}
