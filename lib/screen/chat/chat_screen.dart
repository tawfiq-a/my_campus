import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/chat_controller/chat_controller.dart';

class ChatView extends StatelessWidget {
  final String chatRoomId;
  final String receiverName;

  ChatView({super.key, required this.chatRoomId, required this.receiverName}) {
    final ChatController controller = Get.find();
    controller.markMessagesAsRead(chatRoomId);
  }

  final ChatController controller = Get.find();

  void showDeleteDialog(BuildContext context, String messageId) {
    Get.defaultDialog(
      title: "Delete Message?",
      middleText: "Are you sure you want to delete this message?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteMessage(chatRoomId, messageId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(receiverName, style: TextStyle(color: Colors.white)),
            Text(
              "Online",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // --- Message List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageData = message.data() as Map<String, dynamic>;
                    final messageText = messageData['text'];
                    final messageSender = messageData['sender'];
                    final messageId = message.id;

                    final currentUser = controller.currentUser!.email;
                    final isMe = currentUser == messageSender;

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) showDeleteDialog(context, messageId);
                      },
                      child: MessageBubble(text: messageText, isMe: isMe),
                    );
                  },
                );
              },
            ),
          ),

          // --- Input Field ---
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => controller.sendMessage(chatRoomId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(30),
            elevation: 5.0,
            color: isMe ? Colors.deepPurple : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
