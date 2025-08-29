import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/login.dart';
import 'admin_home.dart';
import 'admin_settings.dart';
import 'emergency_request.dart';
import 'notice_board.dart';
import 'room_bed_management.dart';
import 'student_management.dart';
import 'visitor_management.dart';

bool light = true;

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  List<String> background = ["assets/light-bg.png", "assets/dark-bg.png"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  int currentPage = 0;
  int currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHome(),
    const StudentManagement(),
    const RoomBedManagement(),
    const VisitorManagement(),
    const EmergencyRequest(),
    const NoticeBoard(),
    const AdminSettings(),
  ];

  void _currentPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _switchBackground() {
    setState(() {
      currentIndex = (currentIndex + 1) % background.length;
      light = !light;
    });
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background[currentIndex]),
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
                    color: light ? Colors.black : Colors.white,
                  ),
                  onPressed: () {
                    _toggleDrawer();
                  },
                ),
          actions: [
            IconButton(
              onPressed: () {
                _switchBackground();
              },
              icon: Icon(
                Icons.brightness_6,
                color: light ? Colors.black : Colors.white,
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
                    colors: light
                        ? [Colors.pinkAccent, Colors.deepPurpleAccent]
                        : [Colors.deepPurple, Colors.black87],
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
                    _buildGroupTitle("Management"),
                    _buildDrawerItem(Icons.home, "Home", 0, light),
                    _buildDrawerItem(
                      Icons.account_circle,
                      "Student Management",
                      1,
                      light,
                    ),
                    _buildDrawerItem(
                      Icons.room,
                      "Room / Bed Management",
                      2,
                      light,
                    ),
                    _buildDrawerItem(
                      Icons.person_2,
                      "Visitor Management",
                      3,
                      light,
                    ),

                    _buildGroupTitle("Communication"),
                    _buildDrawerItem(
                      Icons.emergency,
                      "Emergency Request",
                      4,
                      light,
                    ),
                    _buildDrawerItem(
                      Icons.notifications,
                      "Notice Board",
                      5,
                      light,
                    ),

                    _buildGroupTitle("Settings"),
                    _buildDrawerItem(
                      Icons.settings,
                      "Settings / Profile",
                      6,
                      light,
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

  Widget _buildDrawerItem(IconData icon, String title, int index, bool light) {
    final bool isSelected = currentPage == index;

    return InkWell(
      onTap: () => _currentPage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: light
                      ? [Colors.pinkAccent, Colors.deepPurpleAccent]
                      : [Colors.deepPurple, Colors.black87],
                ),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (light ? Colors.black : Colors.white),
          ),
          title: Text(
            title,
            style: GoogleFonts.exo2(
              color: isSelected
                  ? Colors.white
                  : (light ? Colors.black : Colors.white),
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
