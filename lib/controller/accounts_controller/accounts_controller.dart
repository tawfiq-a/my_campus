import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountsController extends GetxController {
  // --- Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Observables ---
  var isTeacher = false.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var selectedDoc = 'Testimonial'.obs;

  // --- Text Controllers ---
  final reasonCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final deptCtrl = TextEditingController();

  final List<String> docTypes = [
    'Testimonial',
    'Transcript',
    'Mark Sheet',
    'ID Card Renewal',
    'Character Certificate',
  ];

  @override
  void onInit() {
    super.onInit();
    checkRole();
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    phoneCtrl.dispose();
    deptCtrl.dispose();
    super.onClose();
  }

  // ---  CHECK ROLE ---
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
    isLoading.value = false;
  }

  // --- SUBMIT REQUEST (Student) ---
  void submitRequest() async {
    if (phoneCtrl.text.isEmpty || deptCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) return;

    isSubmitting.value = true;
    try {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      String name = userDoc['name'] ?? 'Unknown';
      String roll = userDoc['roll'] ?? 'N/A';

      await _firestore.collection('document_requests').add({
        'uid': user.uid,
        'student_name': name,
        'roll': roll,
        'department': deptCtrl.text,
        'phone': phoneCtrl.text,
        'doc_type': selectedDoc.value,
        'reason': reasonCtrl.text.isEmpty
            ? 'No reason provided'
            : reasonCtrl.text,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        "Success",
        "Request Submitted Successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );


      phoneCtrl.clear();
      deptCtrl.clear();
      reasonCtrl.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isSubmitting.value = false;
  }

  // --- 3. ADMIN ACTIONS (Teacher) ---
  void updateStatus(String docId, String newStatus) {
    _firestore.collection('document_requests').doc(docId).update({
      'status': newStatus,
    });
    Get.back();
    Get.snackbar(
      "Updated",
      "Status changed to $newStatus",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Ready to Collect':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
