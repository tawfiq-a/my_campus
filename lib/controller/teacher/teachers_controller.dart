import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherController extends GetxController {
  // Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  var isTeacher = false.obs;
  var isLoading = true.obs;

  // Controllers for Add/Edit
  final nameCtrl = TextEditingController();
  final desigCtrl = TextEditingController();
  final deptCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRole();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    desigCtrl.dispose();
    deptCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }

  // --- 1. Role Check ---
  void checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          isTeacher.value = (doc.data() as Map)['role'] == 'teacher';
        }
      } catch (e) {
        print("Error checking role: $e");
      }
    }
    isLoading.value = false;
  }

  // --- 2. Phone Call ---
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar("Error", "Could not launch dialer",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 3. Email ---
  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      query: 'subject=Contact from Campus App',
    );
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar("Error", "Could not launch email app",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 4. Delete Teacher ---
  void deleteTeacher(String docId) {
    Get.defaultDialog(
      title: "Delete Teacher?",
      middleText: "Are you sure you want to remove this teacher?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection('teachers').doc(docId).delete();
        Get.back();
        Get.snackbar("Deleted", "Teacher removed successfully",
            backgroundColor: Colors.red, colorText: Colors.white);
      },
    );
  }

  // --- 5. Add / Edit Teacher Logic ---

  // ফর্ম সেটআপ করা (এডিট বা অ্যাড মোডের জন্য)
  void initForm(DocumentSnapshot? doc) {
    if (doc != null) {
      var data = doc.data() as Map<String, dynamic>;
      nameCtrl.text = data['name'];
      desigCtrl.text = data['designation'] ?? '';
      deptCtrl.text = data['dept'] ?? '';
      phoneCtrl.text = data['phone'] ?? '';
      emailCtrl.text = data['email'] ?? '';
    } else {
      nameCtrl.clear();
      desigCtrl.clear();
      deptCtrl.clear();
      phoneCtrl.clear();
      emailCtrl.clear();
    }
  }

  void saveTeacher(String? docId) async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar("Error", "Name is required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Map<String, dynamic> teacherData = {
      'name': nameCtrl.text,
      'designation': desigCtrl.text,
      'dept': deptCtrl.text,
      'phone': phoneCtrl.text,
      'email': emailCtrl.text,
    };

    try {
      if (docId != null) {
        // Update
        await _firestore.collection('teachers').doc(docId).update(teacherData);
        Get.snackbar("Success", "Updated Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Add
        await _firestore.collection('teachers').add(teacherData);
        Get.snackbar("Success", "Teacher Added!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      Get.back(); // ডায়লগ বন্ধ
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}