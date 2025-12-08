import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/attendence_controller.dart'; // পাথ ঠিক রাখুন

class TakeAttendanceView extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    // পেজ লোড হলে ডাটা আনবে
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadStudents();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Take Attendance", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // --- Input Header ---
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.courseCtrl,
                      decoration: InputDecoration(
                        labelText: "Course Name / Code",
                        prefixIcon: Icon(Icons.book, color: Colors.teal),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          "Date: ${DateFormat('dd MMM yyyy').format(controller.selectedDate.value)}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: Colors.teal),
                          onPressed: () => controller.pickDate(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // --- Student List Checkbox ---
            Expanded(
              // মেইন Obx: লিস্ট লোড হওয়া পর্যন্ত অপেক্ষা করবে
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.studentList.isEmpty) {
                  return Center(child: Text("No students found"));
                }

                return ListView.builder(
                  itemCount: controller.studentList.length,
                  itemBuilder: (context, index) {
                    var doc = controller.studentList[index];
                    var data = doc.data() as Map<String, dynamic>;
                    String uid = doc.id;

                    // 🔥 FIX: প্রতিটি কার্ডের জন্য আলাদা Obx 🔥
                    // এতে করে শুধু এই আইটেমটি আপডেট হবে, পুরো লিস্ট নয়
                    return Obx(() {
                      bool isChecked = controller.attendanceStatus[uid] ?? false;

                      return Card(
                        // চেক করা থাকলে কালার চেঞ্জ হবে
                        color: isChecked ? Colors.teal.shade50 : Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: CheckboxListTile(
                          activeColor: Colors.teal,
                          title: Text(
                            data['name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Roll: ${data['roll'] ?? 'N/A'}"),
                          value: isChecked,
                          onChanged: (val) {
                            controller.toggleAttendance(uid);
                          },
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),

      // --- Submit Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          height: 50,
          child: Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: controller.isLoading.value ? null : () => controller.submitAttendance(),
            child: controller.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text("SUBMIT ATTENDANCE", style: TextStyle(color: Colors.white, fontSize: 16)),
          )),
        ),
      ),
    );
  }
}