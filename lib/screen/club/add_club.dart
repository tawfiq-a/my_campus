import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/club_controller/club_controller.dart';


class AddClubView extends StatelessWidget {
  final String? docId; // এডিটের জন্য ID (নাল হলে নতুন)
  AddClubView({this.docId});

  final ClubController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docId != null ? "Edit Club" : "Create New Club"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(controller.nameCtrl, "Club Name"),
              SizedBox(height: 15),
              _buildTextField(controller.sloganCtrl, "Slogan"),
              SizedBox(height: 15),
              _buildTextField(controller.descCtrl, "Description", maxLines: 3),
              SizedBox(height: 15),
              _buildTextField(controller.logoCtrl, "Logo Image URL"),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () => controller.saveClub(docId),
                  child: Text(docId != null ? "UPDATE CLUB" : "CREATE CLUB", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}