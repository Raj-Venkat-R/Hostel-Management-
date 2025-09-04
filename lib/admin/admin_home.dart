import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int totalStudents = 0;
  int totalRooms = 0;
  int fullyAvailableRooms = 0;
  int partiallyAvailableRooms = 0;
  int occupiedBeds = 0;
  int availableBeds = 0;

  List<Map<String, String>> topNotices = [];
  List<Map<String, String>> emergenciesList = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchAllStats();
  }

  Future<void> fetchAllStats() async {
    await fetchStudents();
    await fetchRooms();
    await fetchNotices();
    await fetchEmergencies();
  }

  Future<void> fetchStudents() async {
    final snapshot = await _firestore.collection('students').get();
    setState(() {
      totalStudents = snapshot.docs.length;
    });
  }

  Future<void> fetchRooms() async {
    final snapshot = await _firestore.collection('rooms').get();

    int total = 0;
    int occupied = 0;
    int fullyAvailable = 0;
    int partiallyAvailable = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final int bedCount = (data['bedCount'] ?? 0).toInt();
      final int bedsOccupied = (data['occupiedBeds'] ?? 0).toInt();

      total += 1;
      occupied += bedsOccupied;

      if (bedsOccupied == 0) {
        fullyAvailable += 1;
      } else if (bedsOccupied < bedCount) {
        partiallyAvailable += 1;
      }
    }

    setState(() {
      totalRooms = total;
      fullyAvailableRooms = fullyAvailable;
      partiallyAvailableRooms = partiallyAvailable;
      occupiedBeds = occupied;
      availableBeds = snapshot.docs.fold<int>(0, (prev, doc) {
        final data = doc.data();
        final bedCount = (data['bedCount'] ?? 0).toInt();
        final bedsOccupied = (data['occupiedBeds'] ?? 0).toInt();
        return (prev + (bedCount - bedsOccupied)).toInt();
      });
    });
  }

  Future<void> fetchNotices() async {
    final snapshot = await _firestore
        .collection('notices')
        .limit(5)
        .get();

    setState(() {
      topNotices = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': (data['title'] ?? '').toString(),
          'description': (data['description'] ?? '').toString(),
        };
      }).toList();
    });
  }

  Future<void> fetchEmergencies() async {
    final snapshot = await _firestore
        .collection('emergencies')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      emergenciesList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'message': (data['message'] ?? '').toString(),
          'status': (data['status'] ?? '').toString(),
        };
      }).toList();
    });
  }

  Widget buildStatCard(String title, String value, Color start, Color end) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.exo2(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildCard(String title, String description, bool isDark) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple, Colors.black87]
                : [Colors.pinkAccent, Colors.deepPurpleAccent]),
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
              style: GoogleFonts.exo2(color: Colors.white70, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
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
          Text("Dashboard",
              style: GoogleFonts.exo2(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            children: [
              buildStatCard("Total Students", "$totalStudents",
                  Colors.pinkAccent, Colors.deepPurpleAccent),
              buildStatCard("Total Rooms", "$totalRooms",
                  Colors.deepPurple, Colors.black87),
              buildStatCard("Fully Available Rooms", "$fullyAvailableRooms",
                  Colors.teal, Colors.green),
              buildStatCard("Partially Available Rooms", "$partiallyAvailableRooms",
                  Colors.orange, Colors.deepOrange),
              buildStatCard("Occupied Beds", "$occupiedBeds",
                  Colors.redAccent, Colors.red),
              buildStatCard("Available Beds", "$availableBeds",
                  Colors.greenAccent, Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          Text("Notices",
              style: GoogleFonts.exo2(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...topNotices.map((notice) =>
              buildCard(notice['title'] ?? '', notice['description'] ?? '', isDark)),
          const SizedBox(height: 20),
          Text("Emergencies",
              style: GoogleFonts.exo2(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...emergenciesList.map((emergency) =>
              buildCard(emergency['status'] ?? '', emergency['message'] ?? '', isDark)),
        ],
      ),
    );
  }
}
