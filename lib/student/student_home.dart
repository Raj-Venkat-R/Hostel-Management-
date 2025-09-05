import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme_notifier.dart';
import 'student_services.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final StudentService _studentService = StudentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String studentName = "Student";
  String studentId = ""; // ✅ Register Number
  String roomNo = "Not Assigned";
  String email = "";
  String phone = "";
  String department = "";

  int noticesCount = 0;
  int emergenciesCount = 0;

  List<Map<String, String>> recentNotices = [];

  @override
  void initState() {
    super.initState();
    fetchStudentData();
    fetchStats();
  }

  Future<void> fetchStudentData() async {
    try {
      final doc = await _studentService.getStudentDoc();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          studentId = doc.id; // ✅ Register Number (documentId)
          studentName = (data['name'] ?? "Student").toString();
          roomNo = (data['roomNo'] ?? "Not Assigned").toString();
          email = (data['email'] ?? "Not Provided").toString();
          phone = (data['phone'] ?? "Not Provided").toString();
          department = (data['department'] ?? "Not Provided").toString();
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching student data: $e");
    }
  }

  Future<void> fetchStats() async {
    try {
      final noticesSnap = await _firestore.collection('notices').get();
      final emergenciesSnap = await _firestore.collection('emergencies').get();

      final noticesPreview =
          await _firestore.collection('notices').orderBy('timestamp', descending: true).limit(3).get();

      setState(() {
        noticesCount = noticesSnap.docs.length;
        emergenciesCount = emergenciesSnap.docs.length;

        recentNotices = noticesPreview.docs.map((doc) {
          final data = doc.data();
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("❌ Error fetching stats: $e");
    }
  }

  Widget buildInfoCard(String title, String value, Color start, Color end) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.exo2(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildNoticePreviewCard(String title, String description, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.deepPurple, Colors.black87]
              : [Colors.pinkAccent, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.exo2(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text("Welcome, $studentName",
              style: GoogleFonts.exo2(
                  fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Register No: $studentId",
              style: GoogleFonts.exo2(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 20),

          // Room Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.deepPurple, Colors.black87]
                    : [Colors.pinkAccent, Colors.deepPurpleAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Room Details",
                        style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text("Room: $roomNo",
                        style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.bed, size: 40, color: Colors.white),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Student Info Grid
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2),
            children: [
              buildInfoCard("Email", email, Colors.indigo, Colors.blueAccent),
              buildInfoCard("Phone", phone, Colors.teal, Colors.green),
              buildInfoCard(
                  "Department", department, Colors.orange, Colors.deepOrange),
              buildInfoCard("Notices", "$noticesCount",
                  Colors.pinkAccent, Colors.deepPurpleAccent),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Notices
          Text("Recent Notices",
              style: GoogleFonts.exo2(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...recentNotices.map((notice) => buildNoticePreviewCard(
              notice['title'] ?? '',
              notice['description'] ?? '',
              isDark)),
        ],
      ),
    );
  }
}
