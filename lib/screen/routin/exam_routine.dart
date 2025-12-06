import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/routine/routine_controller.dart';

class ExamRoutineView extends StatelessWidget {
  final RoutineController controller = Get.put(RoutineController());

  // --- Show Add Dialog ---
  void _showAddExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Exam Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.examTitleCtrl,
              decoration: InputDecoration(labelText: "Exam Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller.examDateCtrl,
              decoration: InputDecoration(labelText: "Date (e.g. 12 Oct)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller.examTimeCtrl,
              decoration: InputDecoration(labelText: "Time (e.g. 10:00 AM)"),
            ),
          ],
        ),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () => controller.addExam(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exam Routine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
        actions: [
          Obx(
            () => controller.isTeacher.value
                ? IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddExamDialog(context),
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exams')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final exams = snapshot.data!.docs;

          if (exams.isEmpty) return Center(child: Text("No upcoming exams!"));

          return ListView.builder(
            itemCount: exams.length,
            padding: EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final data = exams[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            data['date'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.access_time, color: Colors.blue, size: 20),
                          SizedBox(width: 10),
                          Text(
                            data['time'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Delete Button (Teacher)
                      Obx(
                        () => controller.isTeacher.value
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      controller.deleteExam(exams[index].id),
                                ),
                              )
                            : SizedBox(),
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
