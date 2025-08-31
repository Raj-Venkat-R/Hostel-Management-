import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current student's UID
  String getCurrentUid() {
    return _auth.currentUser!.uid;
  }

  /// Fetch current student's Firestore document
  Future<DocumentSnapshot<Map<String, dynamic>>> getStudentDoc() async {
    final uid = getCurrentUid();
    return await _firestore.collection('students').doc(uid).get();
  }

  /// Get studentId (Register Number) automatically
  Future<String?> getStudentId() async {
    final doc = await getStudentDoc();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['registerNumber'] ?? '';
    }
    return null;
  }

  /// Send Emergency Request
  Future<void> sendEmergencyRequest(String message) async {
    final uid = getCurrentUid();
    final studentId = await getStudentId();

    await _firestore.collection('emergencies').add({
      'studentId': studentId,
      'uid': uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Send Visitor Request
  Future<void> sendVisitorRequest(String visitorName, String purpose) async {
    final uid = getCurrentUid();
    final studentId = await getStudentId();

    await _firestore.collection('visitors').add({
      'studentId': studentId,
      'uid': uid,
      'visitorName': visitorName,
      'purpose': purpose,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Apply for Outpass
  Future<void> requestOutpass(String reason, DateTime from, DateTime to) async {
    final uid = getCurrentUid();
    final studentId = await getStudentId();

    await _firestore.collection('outpass').add({
      'studentId': studentId,
      'uid': uid,
      'reason': reason,
      'fromDate': from,
      'toDate': to,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
