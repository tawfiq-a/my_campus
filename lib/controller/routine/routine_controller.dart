import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoutineController extends GetxController {
  // --- Instances ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Observables ---
  var isTeacher = false.obs;
  var isLoading = false.obs;
  var selectedDay = 'Saturday'.obs;

  // --- Controllers for Class Routine ---
  final subjectCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final roomCtrl = TextEditingController();
  final teacherNameCtrl = TextEditingController();

  // --- Controllers for Exam Routine ---
  final examTitleCtrl = TextEditingController();
  final examDateCtrl = TextEditingController();
  final examTimeCtrl = TextEditingController();

  // --- Static Data ---
  final List<String> days = [
    'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'
  ];

  @override
  void onInit() {
    super.onInit();
    _checkUserRole();
  }

  @override
  void onClose() {
    // Dispose all controllers
    subjectCtrl.dispose();
    timeCtrl.dispose();
    roomCtrl.dispose();
    teacherNameCtrl.dispose();
    examTitleCtrl.dispose();
    examDateCtrl.dispose();
    examTimeCtrl.dispose();
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

  // ===================================
  // CLASS ROUTINE LOGIC
  // ===================================

  // --- Add Class Routine ---
  void addRoutine() async {
    if (subjectCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
      Get.snackbar("Error", "Subject and Time are required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _firestore.collection('routines').add({
        'day': selectedDay.value,
        'subject': subjectCtrl.text,
        'time': timeCtrl.text,
        'room': roomCtrl.text,
        'teacher': teacherNameCtrl.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close screen
      Get.snackbar("Success", "Class Added Successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      subjectCtrl.clear();
      timeCtrl.clear();
      roomCtrl.clear();
      teacherNameCtrl.clear();

    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  // --- Delete Routine ---
  void deleteRoutine(String docId) {
    Get.defaultDialog(
      title: "Delete Class?",
      middleText: "Are you sure you want to remove this class?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection('routines').doc(docId).delete();
        Get.back();
        Get.snackbar("Deleted", "Class removed.");
      },
    );
  }

  // ===================================
  // EXAM ROUTINE LOGIC
  // ===================================

  // --- Add Exam Schedule ---
  void addExam() async {
    if (examTitleCtrl.text.isEmpty) return;

    await _firestore.collection('exams').add({
      'title': examTitleCtrl.text,
      'date': examDateCtrl.text,
      'time': examTimeCtrl.text,
      'created_at': FieldValue.serverTimestamp(),
    });

    Get.back(); // Close dialog
    Get.snackbar("Success", "Exam Added!",
        backgroundColor: Colors.green, colorText: Colors.white);

    // Clear fields
    examTitleCtrl.clear();
    examDateCtrl.clear();
    examTimeCtrl.clear();
  }

  // --- Delete Exam ---
  void deleteExam(String docId) {
    Get.defaultDialog(
      title: "Delete Exam?",
      middleText: "This will remove the exam schedule.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection('exams').doc(docId).delete();
        Get.back();
        Get.snackbar("Deleted", "Exam removed.");
      },
    );
  }
}