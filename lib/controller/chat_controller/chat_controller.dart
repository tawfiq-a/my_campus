import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController extends GetxController {
  // --- Instances ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Observables ---
  var searchText = "".obs; // সার্চ টেক্সট রিয়েক্টিভ
  final searchController = TextEditingController();
  final messageController = TextEditingController();

  // --- Init ---
  @override
  void onInit() {
    super.onInit();
    // সার্চ টেক্সট লিসেনার
    searchController.addListener(() {
      searchText.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // --- Helper: Get Current User ---
  User? get currentUser => _auth.currentUser;

  // --- Helper: Chat Room ID ---
  String getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "$user1\_$user2";
    } else {
      return "$user2\_$user1";
    }
  }

  // --- Send Message ---
  void sendMessage(String chatRoomId) async {
    if (messageController.text.isNotEmpty) {
      String msg = messageController.text;
      messageController.clear(); // UI ক্লিন করে দিচ্ছে সাথে সাথে

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': msg,
        'sender': _auth.currentUser!.email,
        'time': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  // --- Mark Messages as Read ---
  void markMessagesAsRead(String chatRoomId) async {
    final currentUserEmail = _auth.currentUser!.email;

    final unreadMessages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('sender', isNotEqualTo: currentUserEmail)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // --- Delete Message ---
  void deleteMessage(String chatRoomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();

    Get.snackbar("Deleted", "Message deleted successfully",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white, duration: Duration(seconds: 1));
  }
}