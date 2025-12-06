import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/teacher/teachers_controller.dart';


class TeacherView extends StatelessWidget {
  final TeacherController controller = Get.put(TeacherController());


  void _showTeacherDialog(BuildContext context, {DocumentSnapshot? doc}) {
    controller.initForm(doc);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          doc != null ? "Edit Teacher Info" : "Add New Teacher",
          style: TextStyle(color: Colors.deepPurple),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(controller.nameCtrl, "Full Name", Icons.person),
              SizedBox(height: 10),
              _buildTextField(controller.desigCtrl, "Designation", Icons.work),
              SizedBox(height: 10),
              _buildTextField(controller.deptCtrl, "Department", Icons.school),
              SizedBox(height: 10),
              _buildTextField(
                controller.phoneCtrl,
                "Phone Number",
                Icons.phone,
                isNumber: true,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller.emailCtrl,
                "Email Address",
                Icons.email,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: Text(
              doc != null ? "Update" : "Add",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => controller.saveTeacher(doc?.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Directory", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),

      // Floating Action Button (Only for Teacher)
      floatingActionButton: Obx(
        () => controller.isTeacher.value
            ? FloatingActionButton.extended(
                backgroundColor: Colors.deepPurple,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Add Teacher",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _showTeacherDialog(context),
              )
            : Container(),
      ), // Empty Container for Student

      body: Container(
        color: Colors.grey[100],
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teachers')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final teachers = snapshot.data!.docs;

            if (teachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No Teacher Info Available",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: teachers.length,
              padding: EdgeInsets.only(
                bottom: 80,
                left: 10,
                right: 10,
                top: 10,
              ),
              itemBuilder: (context, index) {
                final doc = teachers[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Text(
                            (data['name'] ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                data['designation'] ?? '',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Dept: ${data['dept'] ?? ''}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (data['phone'] != null &&
                                data['phone'].toString().isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    controller.makePhoneCall(data['phone']),
                              ),
                            if (data['email'] != null &&
                                data['email'].toString().isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.email,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    controller.sendEmail(data['email']),
                              ),

                            // Edit/Delete Menu (Only Teacher)
                            Obx(
                              () => controller.isTeacher.value
                                  ? PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showTeacherDialog(context, doc: doc);
                                        }
                                        if (value == 'delete') {
                                          controller.deleteTeacher(doc.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Edit"),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Delete"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
