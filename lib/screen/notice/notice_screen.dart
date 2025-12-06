import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/notice/notice_controller.dart';
import 'add_notice.dart';

class NoticeListView extends StatelessWidget {
  // Inject Controller
  final NoticeController controller = Get.put(NoticeController());

  // --- Show Edit Dialog ---
  void _showEditDialog(BuildContext context, String docId) {
    Get.defaultDialog(
      title: "Edit Notice",
      content: Column(
        children: [
          TextField(
            controller: controller.titleCtrl,
            decoration: InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: controller.descCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: "Description"),
          ),
          TextField(
            controller: controller.linkCtrl,
            decoration: InputDecoration(labelText: "PDF Link"),
          ),
        ],
      ),
      textCancel: "Cancel",
      textConfirm: "Update",
      confirmTextColor: Colors.white,
      buttonColor: Colors.deepPurple,
      onConfirm: () => controller.updateNotice(docId),
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
          // Add Button (Only for Teachers)
          Obx(
            () => controller.isTeacher.value
                ? IconButton(
                    icon: Icon(Icons.add_circle, size: 30),
                    onPressed: () {
                      // Clear fields before adding new notice
                      controller.titleCtrl.clear();
                      controller.descCtrl.clear();
                      controller.linkCtrl.clear();
                      Get.to(() => AddNoticeView());
                    },
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.deepPurple,
            child: TextField(
              controller: controller.searchCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Notices...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: Obx(
                  () => controller.searchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            controller.searchCtrl.clear();
                            controller.searchText.value = "";
                          },
                        )
                      : SizedBox(),
                ),
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

          // --- Notice List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notices')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final allNotices = snapshot.data!.docs;

                // --- Reactive Filtering ---
                return Obx(() {
                  final filteredNotices = allNotices.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['title'] ?? '').toLowerCase();
                    final desc = (data['description'] ?? '').toLowerCase();

                    if (controller.searchText.value.isEmpty) return true;
                    return title.contains(controller.searchText.value) ||
                        desc.contains(controller.searchText.value);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                                  // Edit/Delete Menu (Only for Teachers)
                                  Obx(
                                    () => controller.isTeacher.value
                                        ? PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'delete')
                                                controller.deleteNotice(doc.id);
                                              if (value == 'edit') {
                                                controller.prepareEdit(data);
                                                _showEditDialog(
                                                  context,
                                                  doc.id,
                                                );
                                              }
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
                                          )
                                        : SizedBox(),
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

                              // PDF Button
                              if (data['pdfUrl'] != null &&
                                  data['pdfUrl'].toString().isNotEmpty) ...[
                                SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.redAccent),
                                      foregroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: Icon(Icons.picture_as_pdf),
                                    label: Text("View PDF / Attachment"),
                                    onPressed: () async {
                                      final Uri uri = Uri.parse(data['pdfUrl']);
                                      try {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } catch (e) {
                                        Get.snackbar(
                                          "Error",
                                          "Could not open link",
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
