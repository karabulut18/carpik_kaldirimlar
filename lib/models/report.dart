import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String reporterId;
  final String reportedItemId; // ID of the post or comment
  final String reportedAuthorId;
  final String type; // 'post' or 'comment'
  final String reason;
  final DateTime date;
  final String status; // 'open', 'resolved'

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedItemId,
    required this.reportedAuthorId,
    required this.type,
    required this.reason,
    required this.date,
    this.status = 'open',
  });

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedItemId': reportedItemId,
      'reportedAuthorId': reportedAuthorId,
      'type': type,
      'reason': reason,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reportedItemId: map['reportedItemId'] ?? '',
      reportedAuthorId: map['reportedAuthorId'] ?? '',
      type: map['type'] ?? 'unknown',
      reason: map['reason'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'open',
    );
  }
}
