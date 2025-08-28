import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  List<String> background = ["assets/light-bg.png", "assets/dark-bg.png"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  bool _light = true;
  int currentPage = 0;
  int currentIndex = 0;
  final List<Widget> _pages = [];

  void _currentPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _switchBackground() {
    setState(() {
      currentIndex = (currentIndex + 1) % background.length;
      _light = !_light;
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
          fit: BoxFit.fill,
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
              ? SizedBox()
              : IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: _light ? Colors.black : Colors.white,
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
                color: _light ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
          width: 200,
          backgroundColor: Colors.transparent,
          elevation: 5,
          surfaceTintColor: Colors.transparent,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 80,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Text(
                    'Admin Menu',
                    style: GoogleFonts.exo2(
                      color: _light ? Colors.black : Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              ListTile(
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                 hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(0),
                leading: Icon(
                  Icons.message,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Home',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                 hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(1),
                leading: Icon(
                  Icons.account_circle,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Student Management',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                 hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(2),
                leading: Icon(
                  Icons.room,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Room / Bed Management',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(3),
                leading: Icon(
                  Icons.person_2,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Visitor Management',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                 hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(4),
                leading: Icon(
                  Icons.emergency,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Emergency Request',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                 hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(5),
                leading: Icon(
                  Icons.notifications,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Notice Board',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                 ),
                hoverColor: _light
                    ? const Color.fromARGB(255, 254, 187, 209)
                    : const Color.fromARGB(255, 126, 31, 118),
                onTap: () => _currentPage(6),
                leading: Icon(
                  Icons.settings,
                  color: _light ? Colors.black : Colors.white,
                ),
                title: Text(
                  'Settings / Profile',
                  style: GoogleFonts.exo2(
                    color: _light ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        //body : _pages[currentPage],
      ),
    );
  }
}
