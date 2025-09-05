import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class NoticeBoard extends StatefulWidget {
  const NoticeBoard({super.key});

  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  String searchQuery = "";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final CollectionReference noticesCollection = FirebaseFirestore.instance
      .collection('notices');

  Future<void> saveNotice({String? docId, bool isEdit = false}) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) return;

    if (isEdit && docId != null) {
      await noticesCollection.doc(docId).update({
        "title": title,
        "description": description,
      });
    } else {
      await noticesCollection.add({"title": title, "description": description});
    }
  }

  Future<void> deleteNotice(String docId) async {
    await noticesCollection.doc(docId).delete();
  }

  void clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
  }

  void openNoticeDialog({
    Map<String, dynamic>? notice,
    String? docId,
    bool isEdit = false,
  }) {
    if (isEdit && notice != null) {
      _titleController.text = notice['title'] ?? "";
      _descriptionController.text = notice['description'] ?? "";
    } else {
      clearControllers();
    }

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
              colors:
                  Provider.of<ThemeNotifier>(context, listen: false).isDarkMode
                  ? [Colors.deepPurple, Colors.black87]
                  : [Colors.pinkAccent, Colors.deepPurpleAccent],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? "Edit Notice" : "Add Notice",
                  style: GoogleFonts.exo2(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                buildTextField(_titleController, "Title"),
                buildTextField(
                  _descriptionController,
                  "Description",
                  maxLines: 4,
                ),
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
                      child: Text("Cancel", style: GoogleFonts.exo2(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await saveNotice(docId: docId, isEdit: isEdit);
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
      ),
    );
  }

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

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: GoogleFonts.exo2(),
        maxLines: maxLines,
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
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

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
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => openNoticeDialog(
                                notice: data,
                                docId: doc.id,
                                isEdit: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => deleteNotice(doc.id),
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
        onPressed: () => openNoticeDialog(),
      ),
    );
  }
}
