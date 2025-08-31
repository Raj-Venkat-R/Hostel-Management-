import 'package:flutter/material.dart';
import 'package:hostel_management/admin/admin_home.dart';
import 'package:hostel_management/admin/admin_sidebar.dart';
import 'package:hostel_management/login.dart';
import 'package:hostel_management/student/student_sidebar.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const HostelManagement(),
    ),
  );
}

class HostelManagement extends StatelessWidget {
  const HostelManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.currentThemeMode,
          home: const StudentSideBar(),
        );
      },
    );
  }
}