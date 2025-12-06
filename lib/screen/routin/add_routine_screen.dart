import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/routine/routine_controller.dart';

class AddRoutineView extends StatelessWidget {
  final RoutineController controller = Get.find();

   AddRoutineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Class Routine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Day Dropdown (Reactive) ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(
                    () => DropdownButton<String>(
                      value: controller.selectedDay.value,
                      isExpanded: true,
                      items: controller.days.map((String day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(
                            day,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          controller.selectedDay.value = newValue!,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                controller.subjectCtrl,
                "Subject Name",
                Icons.book,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.timeCtrl,
                "Time (e.g. 10:00 AM)",
                Icons.access_time,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.roomCtrl,
                "Room Number",
                Icons.meeting_room,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.teacherNameCtrl,
                "Teacher Name (Optional)",
                Icons.person,
              ),

              SizedBox(height: 30),

              // --- Add Button ---
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.addRoutine(),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "ADD TO ROUTINE",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget
  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
