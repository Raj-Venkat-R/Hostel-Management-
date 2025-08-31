import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class EmergencyRequest extends StatefulWidget {
  const EmergencyRequest({super.key});

  @override
  State<EmergencyRequest> createState() => _EmergencyRequestState();
}

class _EmergencyRequestState extends State<EmergencyRequest> {
  String searchQuery = "";
  String filterStatus = "All"; // All / Pending / Resolved

  final CollectionReference _emergencyCol =
      FirebaseFirestore.instance.collection('emergencyRequests');

  Future<void> _markResolved(String docId) async {
    await _emergencyCol.doc(docId).update({'status': 'Resolved'});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marked as Resolved")),
    );
  }

  // Helper to format Timestamp
  String _formatTimestamp(dynamic ts) {
    if (ts == null) return "Unknown";
    if (ts is Timestamp) {
      final dt = ts.toDate();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "${dt.day}-${dt.month}-${dt.year} $hh:$mm";
    }
    return ts.toString();
  }

  void _showDetailsDialog(Map<String, dynamic> data, String docId, bool isDark) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['studentId'] != null
                      ? "Student: ${data['studentId']}"
                      : "Student",
                  style: GoogleFonts.exo2(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "UID: ",
                      style: GoogleFonts.exo2(color: Colors.white70),
                    ),
                    Expanded(
                      child: Text(
                        data['uid'] ?? 'N/A',
                        style: GoogleFonts.exo2(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['message'] ?? "",
                  style: GoogleFonts.exo2(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Text(
                  "Status: ${data['status'] ?? 'Pending'}",
                  style: GoogleFonts.exo2(
                    color: (data['status'] == 'Resolved') ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Time: ${_formatTimestamp(data['timestamp'])}",
                  style: GoogleFonts.exo2(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text("Close", style: GoogleFonts.exo2()),
                    ),
                    const SizedBox(width: 12),
                    if ((data['status'] ?? 'Pending') != 'Resolved')
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _markResolved(docId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text("Mark Resolved", style: GoogleFonts.exo2()),
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

  // Client-side filtering after snapshot
  List<QueryDocumentSnapshot> _applyFilters(
      List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final message = (data['message'] ?? '').toString().toLowerCase();
      final studentId = (data['studentId'] ?? '').toString().toLowerCase();
      final status = (data['status'] ?? 'Pending').toString();

      final matchesSearch = searchQuery.isEmpty ||
          message.contains(searchQuery) ||
          studentId.contains(searchQuery);

      final matchesStatus =
          (filterStatus == 'All') ? true : (status == filterStatus);

      return matchesSearch && matchesStatus;
    }).toList();
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
            hintText: "Search by student id or message",
            hintStyle: GoogleFonts.exo2(),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.white,
          ),
          onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor:
                    isDark ? Colors.grey[900] : Colors.white,
                value: filterStatus,
                items: const [
                  DropdownMenuItem(value: "All", child: Text("All")),
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),
                  DropdownMenuItem(value: "Resolved", child: Text("Resolved")),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => filterStatus = val);
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _emergencyCol.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          final filtered = _applyFilters(docs);

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                "No emergency requests found.",
                style: GoogleFonts.exo2(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? 'Pending').toString();
              final timeStr = _formatTimestamp(data['timestamp']);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                      onTap: () => _showDetailsDialog(data, doc.id, isDark),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor:
                              (status == 'Resolved') ? Colors.green : Colors.orange,
                          child: Icon(
                            status == 'Resolved' ? Icons.check : Icons.warning,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          data['studentId'] ?? 'Unknown Student',
                          style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              data['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeStr,
                              style: GoogleFonts.exo2(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.white),
                              onPressed: () => _showDetailsDialog(data, doc.id, isDark),
                            ),
                            if (status != 'Resolved') 
                              ElevatedButton(
                                onPressed: () => _markResolved(doc.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Resolve", style: GoogleFonts.exo2()),
                              )
                            else
                              const SizedBox(width: 6),
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
    );
  }
}
