import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherScreen extends StatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
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
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            isTeacher = (doc.data() as Map)['role'] == 'teacher';
          });
        }
      }
    }
  }

  // --- Phone Call Function ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Error launching phone: $e");
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    }
  }

  // --- Email Function ---
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      query: 'subject=Contact from Campus App',
    );
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Error launching email: $e");
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    }
  }

  // --- Delete Function ---
  void _deleteTeacher(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Teacher?"),
        content: Text(
          "Are you sure you want to remove this teacher from the list?",
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _firestore.collection('teachers').doc(docId).delete();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Teacher Deleted Successfully")),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Add / Edit Dialog Function ---
  void _showTeacherDialog({DocumentSnapshot? document}) {
    final isEdit = document != null;
    final data = isEdit ? document.data() as Map<String, dynamic> : null;

    final _nameCtrl = TextEditingController(text: isEdit ? data!['name'] : '');
    final _desigCtrl = TextEditingController(
      text: isEdit ? data!['designation'] : '',
    );
    final _deptCtrl = TextEditingController(text: isEdit ? data!['dept'] : '');
    final _phoneCtrl = TextEditingController(
      text: isEdit ? data!['phone'] : '',
    );
    final _emailCtrl = TextEditingController(
      text: isEdit ? data!['email'] : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Edit Teacher Info" : "Add New Teacher",
          style: TextStyle(color: Colors.deepPurple),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameCtrl, "Full Name", Icons.person),
              SizedBox(height: 10),
              _buildTextField(_desigCtrl, "Designation", Icons.work),
              SizedBox(height: 10),
              _buildTextField(_deptCtrl, "Department", Icons.school),
              SizedBox(height: 10),
              _buildTextField(
                _phoneCtrl,
                "Phone Number",
                Icons.phone,
                isNumber: true,
              ),
              SizedBox(height: 10),
              _buildTextField(_emailCtrl, "Email Address", Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: Text(
              isEdit ? "Update" : "Add",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (_nameCtrl.text.isEmpty) return;

              final teacherData = {
                'name': _nameCtrl.text,
                'designation': _desigCtrl.text,
                'dept': _deptCtrl.text,
                'phone': _phoneCtrl.text,
                'email': _emailCtrl.text,
              };

              if (isEdit) {
                _firestore
                    .collection('teachers')
                    .doc(document.id)
                    .update(teacherData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Updated Successfully!")),
                );
              } else {
                _firestore.collection('teachers').add(teacherData);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Teacher Added!")));
              }
              Navigator.of(ctx).pop();
            },
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


      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Teacher", style: TextStyle(color: Colors.white)),
              onPressed: () => _showTeacherDialog(),
            )
          : null,

      body: Container(
        color: Colors.grey[100],
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('teachers').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

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

                final name = data['name'] ?? 'Unknown';
                final designation = data['designation'] ?? 'Teacher';
                final phone = data['phone'] ?? '';
                final email = data['email'] ?? '';
                final dept = data['dept'] ?? 'General';

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
                        // Avatar Section
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),

                        // Info Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "$designation",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Dept: $dept",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Actions Section
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (phone.isNotEmpty)
                              IconButton(
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                onPressed: () => _makePhoneCall(phone),
                              ),
                            if (email.isNotEmpty)
                              IconButton(
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.email,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                onPressed: () => _sendEmail(email),
                              ),


                            if (isTeacher)
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: Colors.grey),
                                onSelected: (value) {
                                  if (value == 'edit')
                                    _showTeacherDialog(document: doc);
                                  if (value == 'delete') _deleteTeacher(doc.id);
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
