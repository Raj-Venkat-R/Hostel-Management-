import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showStudentDetailsDialog(BuildContext context,
    {required String regNo,
    required Map<String, dynamic> studentData,
    required bool isDark}) {
  showDialog(
    context: context,
    barrierColor: Colors.black38, // semi-transparent background
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple, Colors.black87]
                : [Colors.pinkAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentData['name'] ?? "",
              style: GoogleFonts.exo2(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            buildDetailRow("Reg No", regNo),
            buildDetailRow("Email", studentData['email'] ?? ""),
            buildDetailRow("Phone", studentData['phone'] ?? ""),
            buildDetailRow("Room No", studentData['roomNo'] ?? ""),
            buildDetailRow("Course", studentData['course'] ?? ""),
            buildDetailRow("Year", studentData['year'] ?? ""),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text("Close", style: GoogleFonts.exo2()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.exo2(fontSize: 16, color: Colors.white70),
          ),
        ),
      ],
    ),
  );
}
