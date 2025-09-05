import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class RoomBedManagement extends StatefulWidget {
  const RoomBedManagement({super.key});

  @override
  _RoomBedManagementState createState() => _RoomBedManagementState();
}

class _RoomBedManagementState extends State<RoomBedManagement> {
  String searchQuery = "";

  final TextEditingController _roomNoController = TextEditingController();
  final TextEditingController _bedCountController = TextEditingController();
  final TextEditingController _occupiedBedsController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  final CollectionReference roomsCollection = FirebaseFirestore.instance
      .collection('rooms');

  Future<void> saveRoom({String? docId, bool isEdit = false}) async {
    final roomNo = _roomNoController.text.trim();
    final bedCount = int.tryParse(_bedCountController.text.trim()) ?? 0;
    final occupiedBeds = int.tryParse(_occupiedBedsController.text.trim()) ?? 0;
    final floor = _floorController.text.trim();

    if (roomNo.isEmpty) return;

    final data = {
      "bedCount": bedCount,
      "occupiedBeds": occupiedBeds,
      "floor": floor,
    };

    if (isEdit && docId != null) {
      await roomsCollection.doc(docId).update(data);
    } else {
      await roomsCollection.doc(roomNo).set(data);
    }
  }

  Future<void> deleteRoom(String docId) async {
    await roomsCollection.doc(docId).delete();
  }

  void clearControllers() {
    _roomNoController.clear();
    _bedCountController.clear();
    _occupiedBedsController.clear();
    _floorController.clear();
  }

  void openRoomDialog({
    Map<String, dynamic>? room,
    String? docId,
    bool isEdit = false,
  }) {
    if (isEdit && room != null) {
      _roomNoController.text = docId ?? "";
      _bedCountController.text = room['bedCount']?.toString() ?? "";
      _occupiedBedsController.text = room['occupiedBeds']?.toString() ?? "";
      _floorController.text = room['floor'] ?? "";
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
                  isEdit ? "Edit Room" : "Add Room",
                  style: GoogleFonts.exo2(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                buildTextField(_roomNoController, "Room No", enabled: !isEdit),
                buildTextField(_bedCountController, "Total Beds"),
                buildTextField(_occupiedBedsController, "Occupied Beds"),
                buildTextField(_floorController, "Floor"),
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
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.exo2(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await saveRoom(docId: docId, isEdit: isEdit);
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

  void showRoomDetails(Map<String, dynamic> room, String roomNo, bool isDark) {
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
                "Room $roomNo",
                style: GoogleFonts.exo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              buildDetailRow("Total Beds", room['bedCount']?.toString() ?? ""),
              buildDetailRow(
                "Occupied Beds",
                room['occupiedBeds']?.toString() ?? "",
              ),
              buildDetailRow("Floor", room['floor'] ?? ""),
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

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.exo2(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.exo2(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.exo2(),
        keyboardType: TextInputType.text,
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
            hintText: "Search by room no",
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
        stream: roomsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final rooms = snapshot.data!.docs.where((doc) {
            final roomNo = doc.id.toLowerCase();
            return roomNo.contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final doc = rooms[index];
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
                      onTap: () => showRoomDetails(data, doc.id, isDark),
                      child: ListTile(
                        title: Text(
                          "Room ${doc.id}",
                          style: GoogleFonts.exo2(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Beds: ${data['occupiedBeds'] ?? 0}/${data['bedCount'] ?? 0}, Floor: ${data['floor'] ?? ''}",
                          style: GoogleFonts.exo2(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => openRoomDialog(
                                room: data,
                                docId: doc.id,
                                isEdit: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => deleteRoom(doc.id),
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
        onPressed: () => openRoomDialog(),
      ),
    );
  }
}
