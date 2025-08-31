import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_management/admin/admin_sidebar.dart';
import 'package:hostel_management/student/student_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isAdmin = true; // Switch for Admin/Student

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (isAdmin) {
      // Admin Login using Firebase Auth
      try {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check user collection for admin data
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminSideBar()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Admin record not found in Firestore")),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Admin Login Failed: ${e.message}")),
        );
      }
    } else {
      // Student login using Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .where('phone', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final studentData = snapshot.docs.first.data();
        final isApproved = studentData['isApproved'] ?? false;

        if (isApproved) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => StudentHome()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your account is not approved yet")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid student email or phone number")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login Here",
                style: GoogleFonts.exo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Admin", style: GoogleFonts.exo2(fontSize: 16)),
                  Switch(
                    value: !isAdmin,
                    onChanged: (val) {
                      setState(() {
                        isAdmin = !val;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                  ),
                  Text("Student", style: GoogleFonts.exo2(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                style: GoogleFonts.exo2(),
                decoration: InputDecoration(
                  labelText: isAdmin ? "Admin Email" : "Student Email",
                  labelStyle: GoogleFonts.exo2(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.exo2(),
                decoration: InputDecoration(
                  labelText: isAdmin ? "Password" : "Phone Number",
                  labelStyle: GoogleFonts.exo2(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Login",
                  style: GoogleFonts.exo2(fontSize: 18, color: Colors.white),
                ),
              ),
              if (!isAdmin) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentRegistrationScreen()),
                    );
                  },
                  child: Text("New Student? Register Here",
                      style: GoogleFonts.exo2(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Student Registration Screen
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _regNo = TextEditingController();
  final TextEditingController _roomNo = TextEditingController();

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(_regNo.text.trim()) // use regNo as docId
            .set({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'registerNumber': _regNo.text.trim(),
          'roomNo': _roomNo.text.trim(),
          'isApproved': false, // must be approved by Admin
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student Registered Successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Registration"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (val) => val!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _regNo,
                decoration: const InputDecoration(labelText: "Register Number"),
                validator: (val) =>
                    val!.isEmpty ? "Enter register number" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _roomNo,
                decoration: const InputDecoration(labelText: "Room No"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Register",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
