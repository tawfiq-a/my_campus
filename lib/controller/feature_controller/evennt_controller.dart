import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventGalleryController extends GetxController {
  // --- Instances ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Observables ---
  var isTeacher = false.obs;

  // --- Text Controllers (Add Event) ---
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  // --- Text Controllers (Add Photo) ---
  final linkCtrl = TextEditingController();
  final captionCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRole();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    dateCtrl.dispose();
    linkCtrl.dispose();
    captionCtrl.dispose();
    super.onClose();
  }

  // --- Role Check ---
  void checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          isTeacher.value = (doc.data() as Map)['role'] == 'teacher';
        }
      } catch (e) {
        print("Role check error: $e");
      }
    }
  }

  // --- Add Event Function ---
  void addEvent() async {
    if (titleCtrl.text.isNotEmpty) {
      User? user = _auth.currentUser;
      String postedBy = user?.displayName ?? "Unknown";

      await _firestore.collection('events').add({
        'title': titleCtrl.text,
        'date': dateCtrl.text,
        'description': descCtrl.text,
        'postedBy': postedBy,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        "Success",
        "Event Added!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );


      titleCtrl.clear();
      descCtrl.clear();
      dateCtrl.clear();
    }
  }

  // --- Add Photo Function ---
  void addPhoto() async {
    if (linkCtrl.text.isNotEmpty) {
      User? user = _auth.currentUser;
      String uploadedBy = user?.displayName ?? "Unknown";

      await _firestore.collection('gallery').add({
        'imageUrl': linkCtrl.text.trim(),
        'caption': captionCtrl.text,
        'uploadedBy': uploadedBy,
        'uploaderEmail': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        "Success",
        "Photo added to gallery!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );


      linkCtrl.clear();
      captionCtrl.clear();
    }
  }

  // --- Delete Item Function ---
  void deleteItem(String collection, String docId) {
    if (!isTeacher.value) {
      Get.snackbar(
        "Permission Denied",
        "Only teachers can delete items.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.defaultDialog(
      title: "Delete Item?",
      middleText: "Are you sure you want to delete this item?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection(collection).doc(docId).delete();
        Get.back();
        Get.snackbar(
          "Deleted",
          "Item removed successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }
}
