import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/login.dart';
import 'package:provider/provider.dart';

import 'student_home.dart';
import 'student_notice.dart';
import 'student_emergency.dart';
import 'student_outpass.dart';
import 'student_settings.dart';
import 'package:hostel_management/theme_notifier.dart';

class StudentSideBar extends StatefulWidget {
  const StudentSideBar({super.key});

  @override
  State<StudentSideBar> createState() => _StudentSideBarState();
}

class _StudentSideBarState extends State<StudentSideBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  int currentPage = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const StudentHome(),
      const StudentNotice(),
      const StudentEmergency(),
      const StudentOutpass(),
      const StudentSettings(),
    ];
  }

  void _currentPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  String _getPageTitle() {
    switch (currentPage) {
      case 0:
        return "Home";
      case 1:
        return "Notice";
      case 2:
        return "Emergency";
      case 3:
        return "Outpass";
      case 4:
        return "Settings";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: (isOpened) {
          setState(() {
            _isDrawerOpen = !_isDrawerOpen;
          });
        },
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: _isDrawerOpen
              ? const SizedBox()
              : IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: _toggleDrawer,
                ),
          title: Text(
            _getPageTitle(),
            style: GoogleFonts.exo2(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: themeNotifier.toggleTheme,
              icon: Icon(
                Icons.brightness_6,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
          width: 240,
          backgroundColor: Colors.transparent,
          elevation: 5,
          surfaceTintColor: Colors.transparent,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.deepPurple, Colors.black87]
                        : [Colors.pinkAccent, Colors.deepPurpleAccent],
                  ),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://imgs.search.brave.com/vF27fXxXUM4ThRhr7sCPp2o9DIm0v5uLZ9xSkZbxXyQ/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9pLmli/Yi5jby9wcm9maWxl/LWltYWdlcy9kZWZl/YXVsdC11c2VyLnBu/Zw",
                  ),
                ),
                accountName: Text(
                  "Student Name",
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text("Student"),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildGroupTitle("Main"),
                    _buildDrawerItem(Icons.home, "Home", 0, isDark),
                    _buildDrawerItem(Icons.notifications, "Notice", 1, isDark),
                    _buildDrawerItem(Icons.emergency, "Emergency", 2, isDark),
                    _buildDrawerItem(Icons.exit_to_app, "Outpass", 3, isDark),
                    _buildGroupTitle("Settings"),
                    _buildDrawerItem(Icons.settings, "Settings", 4, isDark),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    "Logout",
                    style: GoogleFonts.exo2(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: _pages[currentPage],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, bool isDark) {
    final bool isSelected = currentPage == index;

    return InkWell(
      onTap: () => _currentPage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.deepPurple, Colors.black87]
                      : [Colors.pinkAccent, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
          ),
          title: Text(
            title,
            style: GoogleFonts.exo2(
              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.exo2(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}
