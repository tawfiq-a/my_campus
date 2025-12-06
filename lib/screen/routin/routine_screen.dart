import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/routine/routine_controller.dart';
import 'add_routine_screen.dart';

class RoutineView extends StatelessWidget {
  final RoutineController controller = Get.put(RoutineController());

  RoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Class Routine", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Saturday"),
              Tab(text: "Sunday"),
              Tab(text: "Monday"),
              Tab(text: "Tuesday"),
              Tab(text: "Wednesday"),
              Tab(text: "Thursday"),
            ],
          ),
          actions: [
            // Add Button (Only Teacher)
            Obx(
              () => controller.isTeacher.value
                  ? IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () => Get.to(() => AddRoutineView()),
                    )
                  : SizedBox(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildRoutineList("Saturday"),
            _buildRoutineList("Sunday"),
            _buildRoutineList("Monday"),
            _buildRoutineList("Tuesday"),
            _buildRoutineList("Wednesday"),
            _buildRoutineList("Thursday"),
          ],
        ),
      ),
    );
  }

  // --- Widget for Routine List ---
  Widget _buildRoutineList(String day) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('routines')
          .where('day', isEqualTo: day)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final routines = snapshot.data!.docs;

        if (routines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.weekend, size: 60, color: Colors.grey.shade300),
                Text(
                  "No classes on $day!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: routines.length,
          padding: EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final doc = routines[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border(
                    left: BorderSide(color: Colors.deepPurple, width: 5),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    data['subject'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            data['time'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.room, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Room: ${data['room']}"),
                          Spacer(),
                          if (data['teacher'] != null &&
                              data['teacher'].toString().isNotEmpty)
                            Text(
                              "By: ${data['teacher']}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  // Delete Button (Only Teacher)
                  trailing: Obx(
                    () => controller.isTeacher.value
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteRoutine(doc.id),
                          )
                        : SizedBox(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
