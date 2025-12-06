import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/profile/profile_controller.dart';

class ProfileView extends StatelessWidget {
  // Inject Controller
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Edit Toggle Button
          Obx(
            () => IconButton(
              icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit),
              tooltip: controller.isEditing.value
                  ? "Cancel Editing"
                  : "Edit Profile",
              onPressed: () => controller.toggleEditMode(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // --- Header Section ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: controller.userRole.value == 'teacher'
                        ? [Colors.deepPurple, Colors.indigo]
                        : [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        controller.nameCtrl.text.isNotEmpty
                            ? controller.nameCtrl.text[0].toUpperCase()
                            : "U",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      controller.nameCtrl.text,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.userRole.value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      controller.userEmail.value,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // --- Form Fields ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller.nameCtrl,
                      "Full Name",
                      Icons.person,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller.phoneCtrl,
                      "Phone Number",
                      Icons.phone,
                      isNumber: true,
                    ),
                    SizedBox(height: 15),

                    // Blood Group Warning
                    if (controller.selectedBloodGroup.value == null &&
                        !controller.isEditing.value) ...[
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Please add Blood Group to help others in emergency!",
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],

                    // Blood Group Dropdown
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Blood Group",
                        prefixIcon: Icon(
                          Icons.bloodtype,
                          color: controller.isEditing.value
                              ? Colors.deepPurple
                              : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: controller.isEditing.value
                                ? Colors.grey
                                : Colors.transparent,
                          ),
                        ),
                        filled: true,
                        fillColor: controller.isEditing.value
                            ? Colors.grey[50]
                            : Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedBloodGroup.value,
                          hint: Text("Select Group"),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: controller.isEditing.value
                                ? Colors.black
                                : Colors.grey,
                          ),
                          style: TextStyle(
                            color: controller.isEditing.value
                                ? Colors.black
                                : Colors.grey[700],
                            fontSize: 16,
                          ),
                          items: controller.bloodGroups
                              .map(
                                (bg) => DropdownMenuItem(
                                  value: bg,
                                  child: Text(bg),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isEditing.value
                              ? (val) =>
                                    controller.selectedBloodGroup.value = val
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Role Specific Fields
                    if (controller.userRole.value == 'teacher') ...[
                      _buildTextField(
                        controller.deptCtrl,
                        "Department",
                        Icons.school,
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller.rollCtrl,
                        "Teacher ID",
                        Icons.badge,
                      ),
                    ] else ...[
                      _buildTextField(
                        controller.rollCtrl,
                        "Roll Number",
                        Icons.confirmation_number,
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller.sessionCtrl,
                        "Session (e.g. 2020-21)",
                        Icons.calendar_today,
                      ),
                    ],

                    SizedBox(height: 30),

                    // Update Button (Visible only in Edit Mode)
                    if (controller.isEditing.value)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: controller.isSaving.value
                              ? null
                              : () => controller.updateProfile(),
                          child: controller.isSaving.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "UPDATE PROFILE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                    if (controller.isEditing.value) SizedBox(height: 20),

                    Divider(),
                    SizedBox(height: 10),

                    // Logout Button
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.logout, color: Colors.redAccent),
                      ),
                      title: Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      onTap: () => controller.logout(),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // --- Helper: Styled Text Field ---
  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      enabled: controller.isEditing.value, // Enabled only in edit mode
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: TextStyle(
        color: controller.isEditing.value ? Colors.black : Colors.grey[700],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: controller.isEditing.value ? Colors.deepPurple : Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: controller.isEditing.value ? Colors.deepPurple : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: controller.isEditing.value
                ? Colors.grey
                : Colors.transparent,
          ),
        ),
        filled: true,
        fillColor: controller.isEditing.value
            ? Colors.grey[50]
            : Colors.grey[200],
      ),
    );
  }
}
