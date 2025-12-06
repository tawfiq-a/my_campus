import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/notice/notice_controller.dart';

class AddNoticeView extends StatelessWidget {
  final NoticeController controller = Get.find();

  AddNoticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white)),
        title: Text("Add Notice",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        height: double.infinity,
        width:  double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.black87
              ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: controller.titleCtrl,
                  decoration: InputDecoration(
                    labelText: "Notice Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                TextField(
                  controller: controller.descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                // PDF Link Input
                TextField(
                  controller: controller.linkCtrl,
                  decoration: InputDecoration(
                    labelText: "PDF / Google Drive Link (Optional)",
                    hintText: "Paste link here...",
                    prefixIcon: Icon(Icons.link, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Tip: Upload PDF to Google Drive > Copy Link > Paste here.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                SizedBox(height: 30),

                // Publish Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.addNotice(),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "PUBLISH NOTICE",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
