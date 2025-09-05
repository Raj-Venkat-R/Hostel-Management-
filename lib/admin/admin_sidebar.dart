import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/login.dart';
import 'package:provider/provider.dart';

import 'admin_home.dart';
import 'emergency_request.dart';
import 'notice_board.dart';
import 'room_bed_management.dart';
import 'student_management.dart';
import '../theme_notifier.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  int currentPage = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminHome(),
      StudentManagement(),
      const RoomBedManagement(),
      const EmergencyRequest(),
      const NoticeBoard(),
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
        return "Student Management";
      case 2:
        return "Room / Bed Management";
      case 3:
        return "Emergency Request";
      case 4:
        return "Notice Board";
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
          surfaceTintColor: Colors.black,
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
                    "https://imgs.search.brave.com/Gir6JKSLYSYPi0wtcy_yLjrb4FX7ca2AuIQrB_Yf1L8/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzQwLzJh/L2Y1LzQwMmFmNWNk/MjQ3MWIxMjI5OGQ1/NDZjODJiMjAxOTg4/LmpwZw",
                  ),
                ),
                accountName: Text(
                  "Admin Name",
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text("Administrator"),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.home, "Home", 0, isDark),
                    _buildDrawerItem(
                      Icons.account_circle,
                      "Student Management",
                      1,
                      isDark,
                    ),
                    _buildDrawerItem(
                      Icons.room,
                      "Room / Bed Management",
                      2,
                      isDark,
                    ),
                    _buildDrawerItem(
                      Icons.emergency,
                      "Emergency Request",
                      3,
                      isDark,
                    ),
                    _buildDrawerItem(
                      Icons.notifications,
                      "Notice Board",
                      4,
                      isDark,
                    ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black),
          ),
          title: Text(
            title,
            style: GoogleFonts.exo2(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
