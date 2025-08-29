import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/admin/admin_sidebar.dart' as sidebar;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool light = sidebar.light;
  final studentCount = 0;
  final visitorCount = 0;
  final partiallyAvailable = 0;
  final fullyAvailable = 0;
  final emergencyCount = 0;

  Future _fetchStats() async {
    setState(() async {
      final studentCount =
          (await FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'student')
                  .get())
              .docs
              .length;
      final visitorCount =
          (await FirebaseFirestore.instance.collection('visitors').get())
              .docs
              .length;
      final partiallyAvailable =
          (await FirebaseFirestore.instance
                  .collection('rooms')
                  .where('occupiedBeds', isGreaterThan: 0)
                  .where(
                    'occupiedBeds',
                    isLessThan: FieldPath.documentId,
                  ) // check < totalBeds
                  .get())
              .docs
              .length;
      final fullyAvailable =
          (await FirebaseFirestore.instance
                  .collection('rooms')
                  .where('occupiedBeds', isEqualTo: 0)
                  .get())
              .docs
              .length;
      final emergencyCount =
          (await FirebaseFirestore.instance
                  .collection('emergencies')
                  .where('status', isEqualTo: 'pending')
                  .get())
              .docs
              .length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _fetchStats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          StatCard(
            title: "Total Students",
            value: studentCount.toString(),
            icon: Icons.person,
            light: light,
          ),
          StatCard(
            title: "Partially Available Rooms",
            value: partiallyAvailable.toString(),
            icon: Icons.meeting_room,
            light: light,
          ),
          StatCard(
            title: "Fully Available Rooms",
            value: fullyAvailable.toString(),
            icon: Icons.meeting_room,
            light: light,
          ),
          StatCard(
            title: "Visitors Today",
            value: visitorCount.toString(),
            icon: Icons.group,
            light: light,
          ),
          StatCard(
            title: "Emergency Requests",
            value: emergencyCount.toString(),
            icon: Icons.pending_actions,
            light: light,
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final bool light;
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.light,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: light ? Colors.black : Colors.white),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.exo2(
                color: light ? Colors.black : Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.exo2(
                color: light ? Colors.black : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
