import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/club_controller/club_controller.dart';

class MyClubsView extends StatelessWidget {
  final ClubController controller = Get.find();

 MyClubsView({super.key}); // Find existing controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Memberships", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('club_members')
            .where('uid', isEqualTo: controller.currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final myClubs = snapshot.data!.docs;

          if (myClubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diversity_3, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text(
                    "You haven't joined any clubs yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: myClubs.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var data = myClubs[index].data() as Map<String, dynamic>;
              String status = data['status'];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(Icons.groups, color: Colors.indigo),
                  ),
                  title: Text(
                    data['clubName'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Status: $status",
                    style: TextStyle(
                      color: status == 'Approved'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),

                  // --- Status Chip or Leave Button ---
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'Approved')
                        Chip(
                          label: Text("Member"),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      SizedBox(width: 5),

                      // Leave Button (Controller Call)
                      IconButton(
                        icon: Icon(Icons.exit_to_app, color: Colors.red),
                        tooltip: "Leave Club / Cancel Request",
                        onPressed: () => controller.leaveClub(
                          myClubs[index].id,
                          data['clubName'],
                        ),
                      ),
                    ],
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
