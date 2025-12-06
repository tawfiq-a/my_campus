import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/library_controller/library_controller.dart';

class AddBookView extends StatelessWidget {
  final String? docId;
  AddBookView({super.key, this.docId});

  final LibraryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docId != null ? "Edit Book" : "Add New Book"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(
              controller: controller.titleCtrl,
              labelText: "Book Title",
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: controller.authorCtrl,
              labelText: "Author Name",
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: controller.copiesCtrl,
              labelText: "Copies",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: controller.coverUrlCtrl,
              labelText: "Image URL",
            ),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.saveBook(docId),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                child: Text("SAVE", style: TextStyle(color: Colors.white)),
              ),
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

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
