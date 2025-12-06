import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoticeScreen extends StatefulWidget {
  @override
  _AddNoticeScreenState createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController(); // লিংকের জন্য কন্ট্রোলার

  bool isLoading = false;

  Future uploadNotice() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title is required")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // ডাটাবেসে নোটিশ সেভ (লিংক সহ)
      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text,
        'description': _descController.text,
        'date': FieldValue.serverTimestamp(),
        'pdfUrl': _linkController.text.trim(), // গুগল ড্রাইভের লিংক এখানে সেভ হবে
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notice Published!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Notice"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Notice Title", border: OutlineInputBorder())
              ),
              SizedBox(height: 15),

              TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder())
              ),
              SizedBox(height: 15),

              // লিংক পেস্ট করার বক্স
              TextField(
                  controller: _linkController,
                  decoration: InputDecoration(
                      labelText: "PDF / Google Drive Link (Optional)",
                      hintText: "Paste link here...",
                      prefixIcon: Icon(Icons.link, color: Colors.blue),
                      border: OutlineInputBorder()
                  )
              ),
              SizedBox(height: 10),
              Text(
                "Tip: Upload PDF to Google Drive > Copy Link > Paste here.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: isLoading ? null : uploadNotice,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("PUBLISH NOTICE", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}