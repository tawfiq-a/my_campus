import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExamRoutineScreen extends StatefulWidget {
  const ExamRoutineScreen({super.key});

  @override
  _ExamRoutineScreenState createState() => _ExamRoutineScreenState();
}

class _ExamRoutineScreenState extends State<ExamRoutineScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool isTeacher = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            isTeacher = (doc.data() as Map)['role'] == 'teacher';
          });
        }
      }
    }
  }

  void _showAddExamDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Exam Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: "Exam Name (CSE Midterm)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateCtrl,
              decoration: InputDecoration(labelText: "Date ( 12 Oct 2024)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: timeCtrl,
              decoration: InputDecoration(labelText: "Time ( 10:00 AM)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                _firestore.collection('exams').add({
                  'title': titleCtrl.text,
                  'date': dateCtrl.text,
                  'time': timeCtrl.text,
                  'created_at': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exam Routine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
        actions: [
          if (isTeacher)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _showAddExamDialog,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('exams')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final exams = snapshot.data!.docs;

          if (exams.isEmpty) return Center(child: Text("No upcoming exams!"));

          return ListView.builder(
            itemCount: exams.length,
            padding: EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final data = exams[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            data['date'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.access_time, color: Colors.blue, size: 20),
                          SizedBox(width: 10),
                          Text(
                            data['time'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isTeacher)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _firestore
                                .collection('exams')
                                .doc(exams[index].id)
                                .delete(),
                          ),
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
