import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/club_controller/club_controller.dart';
import 'add_club.dart';
import 'club_admin.dart';
import 'club_member_list.dart';

class ClubListView extends StatelessWidget {
  final ClubController controller = Get.put(ClubController());

 ClubListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Clubs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
        actions: [
          Obx(
            () => controller.isTeacher.value
                ? IconButton(
                    icon: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.limeAccent,
                    ),
                    onPressed: () => Get.to(() => ClubAdminView()),
                  )
                : SizedBox(),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => controller.isTeacher.value
            ? FloatingActionButton(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  controller.initForm(null);
                  Get.to(() => AddClubView());
                },
              )
            : Container(),
      ),

      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.indigo,
            child: TextField(
              controller: controller.searchCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Clubs...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    controller.searchCtrl.clear();
                    controller.searchText.value = "";
                  },
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clubs')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final allClubs = snapshot.data!.docs;

                return Obx(() {
                  String search = controller.searchText.value;
                  final filteredClubs = allClubs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toLowerCase();
                    return name.contains(search);
                  }).toList();

                  if (filteredClubs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 60, color: Colors.grey),
                          Text(
                            "No clubs found!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredClubs.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final doc = filteredClubs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () => Get.to(
                            () => ClubMembersView(
                              clubId: doc.id,
                              clubName: data['name'],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: data['logoUrl'] != null
                                          ? NetworkImage(data['logoUrl'])
                                          : null,
                                      backgroundColor: Colors.indigo.shade50,
                                      child: data['logoUrl'] == null
                                          ? Icon(
                                              Icons.groups,
                                              color: Colors.indigo,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (data['slogan'] != null)
                                            Text(
                                              data['slogan'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    if (controller.isTeacher.value) ...[
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          controller.initForm(doc);
                                          Get.to(
                                            () => AddClubView(docId: doc.id),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _showDeleteDialog(doc.id),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 15),
                                Text(
                                  data['description'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 15),

                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(() {
                                    String? status =
                                        controller.myClubStatus[doc.id];

                                    if (status != null) {
                                      return OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: status == 'Approved'
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                          foregroundColor: status == 'Approved'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        onPressed: null,
                                        icon: Icon(
                                          status == 'Approved'
                                              ? Icons.verified
                                              : Icons.hourglass_empty,
                                        ),
                                        label: Text(
                                          status == 'Approved'
                                              ? "Joined"
                                              : "Request Sent",
                                        ),
                                      );
                                    } else {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                        ),
                                        onPressed: () => controller.joinClub(
                                          doc.id,
                                          data['name'],
                                        ),
                                        child: Text(
                                          "Request to Join",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Show Delete Dialog ---
  void _showDeleteDialog(String clubId) {
    Get.dialog(
      AlertDialog(
        title: Text("Delete Club?", style: TextStyle(color: Colors.red)),
        content: Text(
          "Warning: This will remove the club and all its members.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          // Cancel Button
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
            onPressed: () {
              Get.back();
            },
          ),

          // Delete Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete All", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Get.back();
              await controller.deleteClubLogic(clubId);
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
