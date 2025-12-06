import 'package:chat_app/screen/accounts/request_doc_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/accounts_controller/accounts_controller.dart';
import 'admin_request.dart';

class AccountsHomeView extends StatelessWidget {
  final AccountsController controller = Get.put(AccountsController());

  AccountsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register & Accounts"),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildOptionCard(
              context,
              "Request Document",
              "Apply for Transcript, ID Card, etc.",
              Icons.file_copy,
              () => Get.to(() => RequestDocumentView()),
            ),

            // Teacher Option
            if (controller.isTeacher.value) ...[
              SizedBox(height: 20),
              Text(
                "Admin Zone",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
              _buildOptionCard(
                context,
                "Manage Requests",
                "Approve or reject student applications",
                Icons.admin_panel_settings,
                () => Get.to(() => AdminRequestsView()),
              ),
            ],
          ],
        );
      }),
    );
  }


  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
