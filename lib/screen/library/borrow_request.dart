import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BorrowRequestsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;


  void _deleteRequest(BuildContext context, String reqId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Record?"),
        content: Text("This will permanently remove this borrow record."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _firestore.collection('borrow_requests').doc(reqId).delete();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Record Deleted!")));
            },
          ),
        ],
      ),
    );
  }


  void _approveRequest(String reqId, String bookId) {
    _firestore.runTransaction((transaction) async {
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      DocumentSnapshot bookSnapshot = await transaction.get(bookRef);

      if (bookSnapshot.exists) {
        int newStock = (bookSnapshot['available_copies'] as int) - 1;
        if (newStock >= 0) {
          transaction.update(bookRef, {'available_copies': newStock});

          DateTime returnDate = DateTime.now().add(Duration(days: 7));
          transaction.update(
            _firestore.collection('borrow_requests').doc(reqId),
            {
              'status': 'Approved',
              'returnDate': Timestamp.fromDate(returnDate),
            },
          );
        }
      }
    });
  }


  void _returnBook(String reqId, String bookId) {
    _firestore.runTransaction((transaction) async {
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      DocumentSnapshot bookSnapshot = await transaction.get(bookRef);

      if (bookSnapshot.exists) {
        int newStock = (bookSnapshot['available_copies'] as int) + 1;
        transaction.update(bookRef, {'available_copies': newStock});
        transaction.update(
          _firestore.collection('borrow_requests').doc(reqId),
          {'status': 'Returned'},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Requests"),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
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
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              status,
                              style: TextStyle(
                                color: status == 'Approved'
                                    ? Colors.green
                                    : (status == 'Returned'
                                          ? Colors.grey
                                          : Colors.orange),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),

                      // Action Buttons Row
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
                                _deleteRequest(context, reqs[index].id),
                          ),

                          SizedBox(width: 10),


                          if (status == 'Pending')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                              ),
                              child: Text(
                                "Approve",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _approveRequest(
                                reqs[index].id,
                                data['bookId'],
                              ),
                            )
                          else if (status == 'Approved')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                              ),
                              child: Text(
                                "Mark Return",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () =>
                                  _returnBook(reqs[index].id, data['bookId']),
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
