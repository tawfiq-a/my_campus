import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/club_controller/club_controller.dart';

class ClubMembersView extends StatelessWidget {
  final String clubId;
  final String clubName;

  ClubMembersView({required this.clubId, required this.clubName});

  final ClubController controller = Get.find(); // Find existing controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$clubName Members", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.indigo,
            child: TextField(
              controller: controller.memberSearchCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search members...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
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
                  .collection('club_members')
                  .where('clubId', isEqualTo: clubId)
                  .where('status', isEqualTo: 'Approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final allMembers = snapshot.data!.docs;

                // 🔥 FIX: Obx ব্যবহার 🔥
                return Obx(() {
                  // ভেরিয়েবলটি রিড করা হচ্ছে
                  String search = controller.memberSearchText.value;

                  final filteredMembers = allMembers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toLowerCase();
                    final roll = (data['roll'] ?? '').toLowerCase();
                    return name.contains(search) || roll.contains(search);
                  }).toList();

                  if (filteredMembers.isEmpty) {
                    return Center(
                      child: Text(
                        "No members found!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredMembers.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      var data =
                          filteredMembers[index].data() as Map<String, dynamic>;

                      return Card(
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            data['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${data['memberId'] ?? 'Pending'}"),
                              Text("Roll: ${data['roll']}"),
                            ],
                          ),

                          // Remove Button (No need for extra Obx here because parent Obx handles it,
                          // but to be safe we check controller.isTeacher.value inside the parent logic or access it directly)
                          trailing: controller.isTeacher.value
                              ? IconButton(
                                  icon: Icon(
                                    Icons.person_remove,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Remove Member",
                                  onPressed: () => controller.removeMember(
                                    filteredMembers[index].id,
                                    data['name'],
                                  ),
                                )
                              : SizedBox(),
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
}
