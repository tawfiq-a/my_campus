import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Observables
  var isLoading = false.obs;
  var isTeacher = false.obs;
  var selectedDate = DateTime.now().obs;

  // স্টুডেন্ট লিস্ট এবং তাদের উপস্থিতি স্ট্যাটাস (Map<Uid, bool>)
  var studentList = <QueryDocumentSnapshot>[].obs;
  var attendanceStatus = <String, bool>{}.obs;

  // Controllers
  final courseCtrl = TextEditingController();
  final semesterCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkRole();
  }

  // 🔥 মেমোরি লিক আটকাতে কন্ট্রোলার ডিসপোজ করা ভালো 🔥
  @override
  void onClose() {
    courseCtrl.dispose();
    semesterCtrl.dispose();
    super.onClose();
  }

  void _checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        isTeacher.value = (doc.data() as Map)['role'] == 'teacher';
      }
    }
  }

  void loadStudents() async {
    isLoading.value = true;
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      studentList.value = snapshot.docs;

      attendanceStatus.clear();
      for (var doc in snapshot.docs) {
        attendanceStatus[doc.id] = false; // শুরুতে সব আনচেকড
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load students");
    }
    isLoading.value = false;
  }

  void toggleAttendance(String uid) {
    if (attendanceStatus.containsKey(uid)) {
      attendanceStatus[uid] = !attendanceStatus[uid]!;
      // 🔥 UI আপডেট করার জন্য এই লাইনটি খুব জরুরি 🔥
      attendanceStatus.refresh();
    }
  }

  void submitAttendance() async {
    if (courseCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter course name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    // Batch Write (একসাথে অনেক ডাটা সেভ করার জন্য)
    WriteBatch batch = _firestore.batch();

    for (var doc in studentList) {
      String uid = doc.id;
      bool isPresent = attendanceStatus[uid] ?? false;

      DocumentReference ref = _firestore.collection('attendance').doc();

      batch.set(ref, {
        'date': dateStr,
        'course': courseCtrl.text,
        'studentId': uid,
        'studentName': doc['name'],
        'roll': doc['roll'],
        'status': isPresent ? 'Present' : 'Absent',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      Get.back();
      Get.snackbar(
        "Success",
        "Attendance Submitted!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      courseCtrl.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  // তারিখ পিক করা
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) selectedDate.value = picked;
  }
}
