import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/report.dart';

class ReportService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new report
  Future<void> createReport(Report report) async {
    try {
      await _firestore.collection('reports').add(report.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating report: $e');
      rethrow;
    }
  }

  // Get all reports (for admin)
  Stream<List<Report>> getReports() {
    return _firestore
        .collection('reports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Report.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Delete a report (dismiss)
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }
  
  // Resolve a report (could just be updating status or deleting)
  Future<void> resolveReport(String reportId) async {
     try {
      await _firestore.collection('reports').doc(reportId).update({'status': 'resolved'});
      notifyListeners();
    } catch (e) {
      debugPrint('Error resolving report: $e');
      rethrow;
    }
  }
}
