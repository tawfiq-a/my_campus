import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/chat_controller/chat_controller.dart';
import '../mainScreen/main_screen.dart';
import 'chat_screen.dart';

class ChatUserListView extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.off(() => MainView()),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.deepPurple,
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by Name or Roll...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                // Clear Button (Reactive)
                suffixIcon: Obx(
                  () => controller.searchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            controller.searchController.clear();
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

          // --- User List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final allUsers = snapshot.data!.docs;
                final currentUser = controller.currentUser;

                // --- Filtering Logic (Reactive) ---
                // Obx দিয়ে র‍্যাপ করা যাতে সার্চ টেক্সট বদলালে লিস্ট আপডেট হয়
                return Obx(() {
                  final filteredUsers = allUsers.where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    final name = (userData['name'] ?? '').toLowerCase();
                    final roll = (userData['roll'] ?? '').toLowerCase();
                    final uid = userData['uid'];

                    if (currentUser?.uid == uid) return false; // নিজেকে বাদ

                    if (controller.searchText.value.isEmpty) return true;
                    return name.contains(controller.searchText.value) ||
                        roll.contains(controller.searchText.value);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 50, color: Colors.grey),
                          Text(
                            "No user found!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final userData =
                          filteredUsers[index].data() as Map<String, dynamic>;
                      final name = userData['name'] ?? 'Unknown';
                      final roll = userData['roll'] ?? 'N/A';
                      final uid = userData['uid'];

                      String roomId = controller.getChatRoomId(
                        currentUser!.uid,
                        uid,
                      );

                      // --- Unread Count Stream ---
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chat_rooms')
                            .doc(roomId)
                            .collection('messages')
                            .where('sender', isNotEqualTo: currentUser.email)
                            .where('isRead', isEqualTo: false)
                            .snapshots(),
                        builder: (context, messageSnapshot) {
                          int unreadCount = 0;
                          if (messageSnapshot.hasData) {
                            unreadCount = messageSnapshot.data!.docs.length;
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.deepPurple,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                unreadCount > 0
                                    ? "$unreadCount new messages"
                                    : "ID/Roll: $roll",
                                style: TextStyle(
                                  color: unreadCount > 0
                                      ? Colors.deepPurple
                                      : Colors.grey[600],
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: unreadCount > 0
                                  ? Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        "$unreadCount",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.message,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                              onTap: () {
                                Get.to(
                                  () => ChatView(
                                    chatRoomId: roomId,
                                    receiverName: name,
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
