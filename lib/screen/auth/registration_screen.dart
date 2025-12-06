import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller/auth_controller.dart';

class RegistrationView extends StatelessWidget {
  final AuthController controller = Get.find();

  RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Role Selection  ---
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I am a: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: controller.role.value,
                      items: [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text("Student"),
                        ),
                        DropdownMenuItem(
                          value: 'teacher',
                          child: Text("Teacher"),
                        ),
                      ],
                      onChanged: (value) => controller.role.value = value!,
                    ),
                  ],
                ),
              ),

              // --- Admin Code (For Teacher) ---
              Obx(
                () => controller.role.value == 'teacher'
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: TextField(
                          controller: controller.adminCodeCtrl,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.security, color: Colors.red),
                            hintText: "Secret Code (admin123)",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.red.shade50,
                          ),
                        ),
                      )
                    : SizedBox(),
              ),

              // --- Common Fields ---
              _buildTextField(controller.nameCtrl, "Full Name", Icons.person),
              SizedBox(height: 15),
              _buildTextField(
                controller.emailCtrl,
                "Email Address",
                Icons.email,
                isEmail: true,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.passwordCtrl,
                "Password (6+ chars)",
                Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 15),


              Obx(
                () => _buildTextField(
                  controller.rollCtrl,
                  controller.role.value == 'student'
                      ? "Roll Number"
                      : "Teacher ID",
                  Icons.badge,
                ),
              ),

              SizedBox(height: 15),
              _buildTextField(
                controller.phoneCtrl,
                "Phone Number",
                Icons.phone,
                isNumber: true,
              ),
              SizedBox(height: 15),

              // --- Department Dropdown ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Select Department"),
                      value: controller.selectedDept.value,
                      items: controller.departments
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => controller.selectedDept.value = val,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // --- Session (Only for Student) ---
              Obx(
                () => controller.role.value == 'student'
                    ? Column(
                        children: [
                          _buildTextField(
                            controller.sessionCtrl,
                            "Session (e.g. 2020-2021)",
                            Icons.calendar_today,
                          ),
                          SizedBox(height: 15),
                        ],
                      )
                    : SizedBox(),
              ),

              // --- Blood Group Dropdown ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Blood Group (Optional)"),
                      value: controller.selectedBloodGroup.value,
                      items: controller.bloodGroups
                          .map(
                            (bg) =>
                                DropdownMenuItem(value: bg, child: Text(bg)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          controller.selectedBloodGroup.value = val,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // --- Register Button ---
              Obx(
                () => controller.isLoading.value
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          onPressed: () => controller.register(),
                          child: Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isNumber ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }
}
