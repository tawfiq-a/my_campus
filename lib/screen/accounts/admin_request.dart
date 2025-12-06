import 'package:chat_app/controller/accounts_controller/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestsView extends StatelessWidget {
  final AccountsController controller = Get.put(AccountsController());

  void _showDetailsDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Get.defaultDialog(
      title: data['doc_type'],
      titleStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Student Name:", data['student_name']),
          _buildDetailRow("Roll No:", data['roll']),
          _buildDetailRow("Department:", data['department'] ?? 'N/A'),
          _buildDetailRow("Phone:", data['phone'] ?? 'N/A'),
          Divider(),
          Text(
            "Reason:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            data['reason'] ?? 'No reason provided',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          Divider(),
          Chip(
            label: Text(data['status'], style: TextStyle(color: Colors.white)),
            backgroundColor: controller.getStatusColor(data['status']),
          ),
        ],
      ),
      confirm: PopupMenuButton<String>(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: null,
          child: Text("Update Status", style: TextStyle(color: Colors.white)),
        ),
        onSelected: (val) => controller.updateStatus(doc.id, val),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'Pending', child: Text("Mark as Pending")),
          PopupMenuItem(value: 'Processing', child: Text("Mark as Processing")),
          PopupMenuItem(
            value: 'Ready to Collect',
            child: Text("Mark as Ready"),
          ),
          PopupMenuItem(
            value: 'Rejected',
            child: Text("Reject Request", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: Text("Close")),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Requests"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('document_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final requests = snapshot.data!.docs;

          if (requests.isEmpty) return Center(child: Text("No requests found"));

          return ListView.builder(
            itemCount: requests.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.description, color: Colors.teal),
                  ),
                  title: Text(
                    data['doc_type'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${data['student_name']} (${data['roll']})\nStatus: ${data['status']}",
                  ),
                  isThreeLine: true,
                  trailing: Icon(Icons.info_outline, color: Colors.teal),
                  onTap: () => _showDetailsDialog(context, doc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
