import 'package:flutter/material.dart';
import 'package:hostel_management/admin_home.dart';
import 'package:hostel_management/login.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(HostelManagement());
}

class HostelManagement extends StatelessWidget {
  const HostelManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AdminHome());
  }
}
