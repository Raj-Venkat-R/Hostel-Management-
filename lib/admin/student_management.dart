import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_notifier.dart';
import 'package:provider/provider.dart';
import 'student_detail_page.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  _StudentManagementState createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  String searchQuery = "";

  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // Add or Update Student with Firebase Auth
  Future<void> saveStudent({bool isEdit = false}) async {
    final regNo = _regNoController.text.trim();
    final name = _nameController.text.trim();
    final roomNo = _roomController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final course = _courseController.text.trim();
    final year = _yearController.text.trim();

    if (regNo.isEmpty || email.isEmpty || phone.isEmpty) return;

    try {
      if (!isEdit) {
        // create new Auth user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: phone,
        );

        // Add new student to Firestore
        await studentsCollection.doc(regNo).set({
          "name": name,
          "roomNo": roomNo,
          "email": email,
          "phone": phone,
          "course": course,
          "year": year,
          "isApproved": false,
        });
      } else {
        // Update existing student
        await studentsCollection.doc(regNo).update({
          "name": name,
          "roomNo": roomNo,
          "email": email,
          "phone": phone,
          "course": course,
          "year": year,
          "isApproved": true,
        });
      }

      clearControllers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Student updated successfully"
                : "Student added successfully",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.message}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Approve Student
  Future<void> approveStudent(String regNo) async {
    await studentsCollection.doc(regNo).update({"isApproved": true});
  }

  // Delete Student and attempt to delete Auth credential
  Future<void> deleteStudent(String regNo) async {
    try {
      final doc = await studentsCollection.doc(regNo).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final email = data['email'];

      // Delete Firestore student record
      await studentsCollection.doc(regNo).delete();

      // Inform admin that Auth user still exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Can't delete Auth user via client. Use backend/Cloud Function.",
          ),
          backgroundColor: Colors.orange,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting student: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void clearControllers() {
    _regNoController.clear();
    _nameController.clear();
    _roomController.clear();
    _emailController.clear();
    _phoneController.clear();
    _courseController.clear();
    _yearController.clear();
  }

  void openStudentDialog({Map<String, dynamic>? student, bool isEdit = false}) {
  if (isEdit && student != null) {
    _regNoController.text = (student['regNo'] ?? '').toString();
    _nameController.text = (student['name'] ?? '').toString();
    _roomController.text = (student['roomNo'] ?? '').toString();
    _emailController.text = (student['email'] ?? '').toString();
    _phoneController.text = (student['phone'] ?? '').toString();
    _courseController.text = (student['course'] ?? '').toString();
    _yearController.text = (student['year'] ?? '').toString();
  } else {
    clearControllers(); // clear when adding new student
  }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                Provider.of<ThemeNotifier>(context, listen: false).isDarkMode
                    ? [Colors.deepPurple, Colors.black87]
                    : [Colors.pinkAccent, Colors.deepPurpleAccent],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                isEdit ? "Edit Student" : "Add Student",
                style: GoogleFonts.exo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              buildTextField(_regNoController, "Reg No", !isEdit),
              buildTextField(_nameController, "Name"),
              buildTextField(_roomController, "Room No"),
              buildTextField(_emailController, "Email"),
              buildTextField(_phoneController, "Phone"),
              buildTextField(_courseController, "Course"),
              buildTextField(_yearController, "Year"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      clearControllers();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Provider.of<ThemeNotifier>(
                        context,
                        listen: false,
                      ).isDarkMode
                              ? Colors.deepPurple
                              : Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.exo2(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveStudent(isEdit: isEdit);
                      clearControllers();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Provider.of<ThemeNotifier>(
                        context,
                        listen: false,
                      ).isDarkMode
                              ? Colors.deepPurple
                              : Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isEdit ? "Update" : "Add",
                      style: GoogleFonts.exo2(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, [
    bool enabled = true,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.exo2(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.exo2(),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          style: GoogleFonts.exo2(),
          decoration: InputDecoration(
            hintText: "Search by name, course, or room",
            hintStyle: GoogleFonts.exo2(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.white,
          ),
          onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'].toString().toLowerCase();
            final course = data['course'].toString().toLowerCase();
            final room = data['roomNo'].toString().toLowerCase();
            return name.contains(searchQuery) ||
                course.contains(searchQuery) ||
                room.contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final doc = students[index];
              final data = doc.data() as Map<String, dynamic>;
              final isApproved = data['isApproved'] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                  child: Ink(
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showStudentDetailsDialog(
                          context,
                          regNo: doc.id,
                          studentData: data,
                          isDark: isDark,
                        );
                      },
                      child: ListTile(
                        title: Text(
                          data['name'],
                          style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Room: ${data['roomNo']} | Course: ${data['course']} | Year: ${data['year']} | Approved: ${isApproved ? 'Yes' : 'No'}",
                          style: GoogleFonts.exo2(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isApproved)
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.greenAccent,
                                ),
                                onPressed: () => approveStudent(doc.id),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                openStudentDialog(
                                  student: {...data, 'regNo': doc.id},
                                  isEdit: true,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => deleteStudent(doc.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Provider.of<ThemeNotifier>(context, listen: false).isDarkMode
                ? Colors.deepPurple
                : Colors.pinkAccent,
        child: const Icon(Icons.add),
        onPressed: () => openStudentDialog(),
      ),
    );
  }
}
