import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  var isTeacher = false.obs;
  var searchRoll = "".obs; // রেজাল্ট সার্চ করার জন্য

  // Controllers
  final rollSearchCtrl = TextEditingController();

  // Add Seat Plan Controllers
  final roomCtrl = TextEditingController();
  final rollRangeCtrl = TextEditingController(); // e.g. 101-150
  final examNameCtrl = TextEditingController();

  // Add Result Controllers
  final studentRollCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRole();
  }

  void checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) isTeacher.value = (doc.data() as Map)['role'] == 'teacher';
    }
  }

  // --- 1. Seat Plan Management ---
  void addSeatPlan() async {
    if (roomCtrl.text.isEmpty || rollRangeCtrl.text.isEmpty) return;

    await _firestore.collection('seat_plans').add({
      'examName': examNameCtrl.text,
      'roomNo': roomCtrl.text,
      'rollRange': rollRangeCtrl.text,
      'date': FieldValue.serverTimestamp(),
    });

    Get.back();
    Get.snackbar("Success", "Seat Plan Added!", backgroundColor: Colors.green, colorText: Colors.white);
    roomCtrl.clear(); rollRangeCtrl.clear(); examNameCtrl.clear();
  }

  // --- 2. Result Management ---
  void publishResult() async {
    if (studentRollCtrl.text.isEmpty || gpaCtrl.text.isEmpty) return;

    await _firestore.collection('results').add({
      'roll': studentRollCtrl.text,
      'subject': subjectCtrl.text,
      'gpa': gpaCtrl.text,
      'publishedAt': FieldValue.serverTimestamp(),
    });

    Get.back();
    Get.snackbar("Success", "Result Published!", backgroundColor: Colors.green, colorText: Colors.white);
    studentRollCtrl.clear(); gpaCtrl.clear(); subjectCtrl.clear();
  }

  // --- 3. Delete Function ---
  void deleteItem(String collection, String docId) {
    Get.defaultDialog(
        title: "Delete?",
        middleText: "Are you sure?",
        textConfirm: "Delete",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          _firestore.collection(collection).doc(docId).delete();
          Get.back();
        }
    );
  }
}