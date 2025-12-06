import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticeController extends GetxController {
  // --- Instances ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Observables ---
  var isTeacher = false.obs;
  var isLoading = false.obs;
  var searchText = "".obs;

  // --- Text Controllers ---
  final searchCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final linkCtrl = TextEditingController(); // For PDF/Drive Link

  @override
  void onInit() {
    super.onInit();
    _checkUserRole();

    // Listener for search input
    searchCtrl.addListener(() {
      searchText.value = searchCtrl.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    linkCtrl.dispose();
    super.onClose();
  }

  // --- 1. Check User Role ---
  void _checkUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          isTeacher.value = (doc.data() as Map)['role'] == 'teacher';
        }
      } catch (e) {
        debugPrint("Error checking role: $e");
      }
    }
  }

  // --- 2. Add New Notice ---
  void addNotice() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar("Error", "Title is required",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _firestore.collection('notices').add({
        'title': titleCtrl.text,
        'description': descCtrl.text,
        'pdfUrl': linkCtrl.text.trim(),
        'date': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close screen
      Get.snackbar("Success", "Notice Published!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      titleCtrl.clear();
      descCtrl.clear();
      linkCtrl.clear();
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  // --- 3. Update Existing Notice ---
  void updateNotice(String docId) async {
    try {
      await _firestore.collection('notices').doc(docId).update({
        'title': titleCtrl.text,
        'description': descCtrl.text,
        'pdfUrl': linkCtrl.text.trim(),
      });

      Get.back(); // Close dialog
      Get.snackbar("Success", "Notice Updated!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      titleCtrl.clear();
      descCtrl.clear();
      linkCtrl.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to update notice",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 4. Delete Notice ---
  void deleteNotice(String docId) {
    Get.defaultDialog(
      title: "Delete Notice?",
      middleText: "Are you sure you want to delete this notice? This action cannot be undone.",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await _firestore.collection('notices').doc(docId).delete();
        Get.back(); // Close dialog
        Get.snackbar("Deleted", "Notice removed successfully",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      },
    );
  }

  // --- 5. Populate Fields for Editing ---
  void prepareEdit(Map<String, dynamic> data) {
    titleCtrl.text = data['title'] ?? '';
    descCtrl.text = data['description'] ?? '';
    linkCtrl.text = data['pdfUrl'] ?? '';
  }
}