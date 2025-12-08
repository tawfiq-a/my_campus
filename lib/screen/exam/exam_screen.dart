import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/exam/exam_controller.dart';

class ExamHomeView extends StatelessWidget {
  final ExamController controller = Get.put(ExamController());

  ExamHomeView({super.key});

  // --- Dialogs ---
  void _showAddSeatPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Seat Plan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller.examNameCtrl, decoration: InputDecoration(labelText: "Exam Name")),
            TextField(controller: controller.roomCtrl, decoration: InputDecoration(labelText: "Room No")),
            TextField(controller: controller.rollRangeCtrl, decoration: InputDecoration(labelText: "Roll Range (e.g. 101-150)")),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => controller.addSeatPlan(), child: Text("Add"))
        ],
      ),
    );
  }

  void _showAddResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Publish Result"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller.studentRollCtrl, decoration: InputDecoration(labelText: "Student Roll")),
            TextField(controller: controller.subjectCtrl, decoration: InputDecoration(labelText: "Subject / Semester")),
            TextField(controller: controller.gpaCtrl, decoration: InputDecoration(labelText: "GPA / Marks")),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => controller.publishResult(), child: Text("Publish"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Exam Control", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigoAccent,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: "Seat Plan"), Tab(text: "Check Result")],
          ),
          actions: [
            Obx(() => controller.isTeacher.value
                ? PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'seat') _showAddSeatPlanDialog(context);
                if (val == 'result') _showAddResultDialog(context);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'seat', child: Text("Add Seat Plan")),
                PopupMenuItem(value: 'result', child: Text("Publish Result")),
              ],
            )
                : SizedBox())
          ],
        ),
        body: TabBarView(
          children: [
            _buildSeatPlanTab(),
            _buildResultTab(),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: Seat Plan List ---
  Widget _buildSeatPlanTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('seat_plans').orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final plans = snapshot.data!.docs;

        return ListView.builder(
          itemCount: plans.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final data = plans[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.chair), backgroundColor: Colors.indigo.shade100),
                title: Text(data['examName'] ?? 'Exam'),
                subtitle: Text("Room: ${data['roomNo']} | Roll: ${data['rollRange']}"),
                trailing: Obx(() => controller.isTeacher.value
                    ? IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => controller.deleteItem('seat_plans', plans[index].id))
                    : SizedBox()),
              ),
            );
          },
        );
      },
    );
  }

  // --- Tab 2: Result Search ---
  Widget _buildResultTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: controller.rollSearchCtrl,
            decoration: InputDecoration(
              labelText: "Enter Your Roll Number",
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  controller.searchRoll.value = controller.rollSearchCtrl.text;
                },
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.searchRoll.value.isEmpty) {
              return Center(child: Text("Enter roll number to see results"));
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('results')
                  .where('roll', isEqualTo: controller.searchRoll.value)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final results = snapshot.data!.docs;

                if (results.isEmpty) return Center(child: Text("No result found for Roll: ${controller.searchRoll.value}"));

                return ListView.builder(
                  itemCount: results.length,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final data = results[index].data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        title: Text(data['subject'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Roll: ${data['roll']}"),
                        trailing: Text(
                            "GPA: ${data['gpa']}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}