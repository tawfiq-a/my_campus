import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/club_controller/club_controller.dart';


class ClubAdminView extends StatelessWidget {
  final ClubController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Club Requests"), backgroundColor: Colors.indigo),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('club_members')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final reqs = snapshot.data!.docs;

          if (reqs.isEmpty) return Center(child: Text("No pending requests"));

          return ListView.builder(
            itemCount: reqs.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var data = reqs[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text("Roll: ${data['roll']}\nClub: ${data['clubName']}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: () => controller.approveMember(reqs[index].id, data['clubName']),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 30),
                        onPressed: () => controller.rejectMember(reqs[index].id),
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