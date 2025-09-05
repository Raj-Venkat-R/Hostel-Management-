import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getCurrentUid() {
    return _auth.currentUser!.uid;
  }

  Future<String?> getRegisterNumber() async {
    final uid = getCurrentUid();

    final query = await _firestore
        .collection('students')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id; // ✅ documentId = Register Number
    }
    return null;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getStudentDoc() async {
    final registerNumber = await getRegisterNumber();
    if (registerNumber == null) {
      throw Exception("Student document not found for this UID.");
    }
    return await _firestore.collection('students').doc(registerNumber).get();
  }

  Future<void> sendEmergencyRequest(String message) async {
    final uid = getCurrentUid();
    final registerNumber = await getRegisterNumber();

    await _firestore.collection('emergencies').add({
      'studentId': registerNumber,
      'uid': uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> sendVisitorRequest(String visitorName, String purpose) async {
    final uid = getCurrentUid();
    final registerNumber = await getRegisterNumber();

    await _firestore.collection('visitors').add({
      'studentId': registerNumber,
      'uid': uid,
      'visitorName': visitorName,
      'purpose': purpose,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> requestOutpass(String reason, DateTime from, DateTime to) async {
    final uid = getCurrentUid();
    final registerNumber = await getRegisterNumber();

    await _firestore.collection('outpass').add({
      'studentId': registerNumber,
      'uid': uid,
      'reason': reason,
      'fromDate': from,
      'toDate': to,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
