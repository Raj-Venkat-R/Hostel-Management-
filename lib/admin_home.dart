import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Admin Home",
              style: GoogleFonts.exo2(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                "https://imgs.search.brave.com/c6L9sCP8Kabw3QVpPYbRPEqRORxEnDtaQT3LZ6RQIUU/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNTgv/NDY1LzQ0Ni9zbWFs/bC9nZW5lcmljLXVz/ZXItcHJvZmlsZS1p/Y29uLWluLTNkLWRl/c2lnbi1tb2Rlcm4t/YXZhdGFyLXBsYWNl/aG9sZGVyLWRpZ2l0/YWwtaWRlbnRpdHkt/c3ltYm9sLWFicy1w/bmcucG5n",
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Admin Dashboard"),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              onTap: () {
                // Navigate to dashboard
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Students"),
              onTap: () {
                // Navigate to students page
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text("Content here")),
    );
  }
}
