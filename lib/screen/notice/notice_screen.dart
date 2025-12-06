import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // ১. এই প্যাকেজটি ইম্পোর্ট করুন
import 'add_notice.dart';

class NoticeScreen extends StatefulWidget {
  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isTeacher = false;

  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  void _checkUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            isTeacher = (doc.data() as Map)['role'] == 'teacher';
          });
        }
      }
    }
  }

  // --- Delete Function ---
  void _deleteNotice(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Notice?"),
        content: Text("Are you sure you want to delete this notice?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _firestore.collection('notices').doc(docId).delete();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // --- Edit Function ---
  void _showEditDialog(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final _titleCtrl = TextEditingController(text: data['title']);
    final _descCtrl = TextEditingController(text: data['description']);
    // লিংক এডিট করার জন্য কন্ট্রোলার (Optional)
    final _linkCtrl = TextEditingController(text: data['pdfUrl'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Notice"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _linkCtrl,
              decoration: InputDecoration(labelText: "PDF Link"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text("Update"),
            onPressed: () {
              _firestore.collection('notices').doc(document.id).update({
                'title': _titleCtrl.text,
                'description': _descCtrl.text,
                'pdfUrl': _linkCtrl.text, // লিংক আপডেট
              });
              Navigator.of(ctx).pop();
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
        title: Text("Campus Notices", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (isTeacher)
            IconButton(
              icon: Icon(Icons.add_circle, size: 30),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoticeScreen()),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          //----------------- search bar ----------------
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.deepPurple,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Notices...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = "";
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
            ),
          ),

          // --- notice list ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('notices')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final allNotices = snapshot.data!.docs;

                // --- filtering logic ---
                final filteredNotices = allNotices.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toLowerCase();
                  final desc = (data['description'] ?? '').toLowerCase();

                  if (_searchText.isEmpty) return true;
                  return title.contains(_searchText) ||
                      desc.contains(_searchText);
                }).toList();

                if (filteredNotices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        Text(
                          "No notice found!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredNotices.length,
                  padding: EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final doc = filteredNotices[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String formattedDate = "Recently";
                    if (data['date'] != null) {
                      formattedDate = DateFormat(
                        'dd MMM, hh:mm a',
                      ).format((data['date'] as Timestamp).toDate());
                    }

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.orangeAccent,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),

                                if (isTeacher)
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete')
                                        _deleteNotice(doc.id);
                                      if (value == 'edit') _showEditDialog(doc);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text("Edit"),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                data['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                data['description'],
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),


                            if (data['pdfUrl'] != null &&
                                data['pdfUrl'].toString().isNotEmpty) ...[
                              SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.redAccent),
                                      foregroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                  ),
                                  icon: Icon(Icons.picture_as_pdf),
                                  label: Text("View PDF / Attachment"),
                                  onPressed: () async {
                                    final String url = data['pdfUrl'];
                                    final Uri uri = Uri.parse(url);
                                    try {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Could not open link: $e"))
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                            // ------------------------------------

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}