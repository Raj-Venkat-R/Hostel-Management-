import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class StudentNotice extends StatefulWidget {
  const StudentNotice({super.key});

  @override
  _StudentNoticeState createState() => _StudentNoticeState();
}

class _StudentNoticeState extends State<StudentNotice> {
  String searchQuery = "";
  final CollectionReference noticesCollection =
      FirebaseFirestore.instance.collection('notices');

  void showNoticeDetails(Map<String, dynamic> notice, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
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
                notice['title'] ?? "",
                style: GoogleFonts.exo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                notice['description'] ?? "",
                style: GoogleFonts.exo2(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          style: GoogleFonts.exo2(),
          decoration: InputDecoration(
            hintText: "Search notices",
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
        stream: noticesCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notices = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'].toString().toLowerCase();
            final desc = data['description'].toString().toLowerCase();
            return title.contains(searchQuery) || desc.contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final doc = notices[index];
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      onTap: () => showNoticeDetails(data, isDark),
                      child: ListTile(
                        title: Text(
                          data['title'] ?? "",
                          style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data['description'] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.exo2(color: Colors.white70),
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
    );
  }
}
