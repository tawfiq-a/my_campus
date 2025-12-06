import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  final DocumentSnapshot? bookDoc;

  const AddBookScreen({super.key, this.bookDoc});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _copiesCtrl = TextEditingController();
  final _coverUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.bookDoc != null) {
      var data = widget.bookDoc!.data() as Map<String, dynamic>;
      _titleCtrl.text = data['title'];
      _authorCtrl.text = data['author'];
      _copiesCtrl.text = data['available_copies'].toString();
      _coverUrlCtrl.text = data['coverUrl'] ?? '';
    }
  }

  void _saveBook() {
    if (_titleCtrl.text.isEmpty || _copiesCtrl.text.isEmpty) return;

    Map<String, dynamic> data = {
      'title': _titleCtrl.text,
      'author': _authorCtrl.text,
      'available_copies': int.parse(_copiesCtrl.text),
      'coverUrl': _coverUrlCtrl.text.isNotEmpty ? _coverUrlCtrl.text : null,
    };

    if (widget.bookDoc != null) {
      FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookDoc!.id)
          .update(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Book Updated!")));
    } else {
      data['created_at'] = FieldValue.serverTimestamp();
      FirebaseFirestore.instance.collection('books').add(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Book Added!")));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookDoc != null ? "Edit Book" : "Add New Book"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
           CustomTextField(controller: _titleCtrl, labelText: "Book Title"),
            SizedBox(height: 10),
            CustomTextField(controller: _authorCtrl, labelText: "Author Name"),
            SizedBox(height: 10),
            CustomTextField(
              controller: _copiesCtrl,
              labelText: "Copies",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            CustomTextField(controller: _coverUrlCtrl, labelText: "Image URl"),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveBook,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  final String labelText;

  final TextInputType keyboardType;

  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}
