import 'package:chat_app/controller/accounts_controller/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestDocumentView extends StatelessWidget {
  final AccountsController controller = Get.put(AccountsController());

  RequestDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Document"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Select Document Type"),

              // Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(
                    () => DropdownButton<String>(
                      value: controller.selectedDoc.value,
                      isExpanded: true,
                      items: controller.docTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          controller.selectedDoc.value = newValue!,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15),
              _buildTextField(
                controller.deptCtrl,
                "Department (e.g. CSE)",
                Icons.school,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.phoneCtrl,
                "Contact Number",
                Icons.phone,
                isNumber: true,
              ),
              SizedBox(height: 15),
              _buildTextField(
                controller.reasonCtrl,
                "Reason / Note (Optional)",
                Icons.note,
                maxLines: 3,
              ),

              SizedBox(height: 30),

              // Submit Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitRequest(),
                    child: controller.isSubmitting.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "SUBMIT REQUEST",
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
