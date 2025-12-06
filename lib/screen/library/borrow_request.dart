import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../controller/library_controller/library_controller.dart';

class BorrowRequestsView extends StatelessWidget {
  final LibraryController controller = Get.find();

  BorrowRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Requests"),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrow_requests')
            .orderBy('requestDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final reqs = snapshot.data!.docs;

          if (reqs.isEmpty) return Center(child: Text("No requests found"));

          return ListView.builder(
            itemCount: reqs.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var data = reqs[index].data() as Map<String, dynamic>;
              String status = data['status'];
              String reqDate = DateFormat(
                'dd MMM',
              ).format((data['requestDate'] as Timestamp).toDate());

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          data['bookName'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${data['studentName']} (${data['roll']})\nDate: $reqDate",
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          status,
                          style: TextStyle(
                            color: status == 'Approved'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () =>
                                controller.deleteRequest(reqs[index].id),
                          ),
                          SizedBox(width: 10),
                          if (status == 'Pending')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text(
                                "Approve",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => controller.approveRequest(
                                reqs[index].id,
                                data['bookId'],
                              ),
                            )
                          else if (status == 'Approved')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                              ),
                              child: Text(
                                "Mark Return",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => controller.returnBook(
                                reqs[index].id,
                                data['bookId'],
                              ),
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
    );
  }
}
