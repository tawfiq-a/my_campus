import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Common Obs
  var userName = "".obs;
  var userRole = "student".obs;
  var isLoading = true.obs;

  // Student specific Obs
  var todayClassCount = 0.obs;
  var borrowedBookCount = 0.obs;
  var nextExamDate = "No Exam".obs;
  var attendanceRate = 0.0.obs;
  var totalDue = "0 BDT".obs;

  // Teacher specific Obs
  var totalStudentsPresent = 0.obs;
  var totalStudentsAbsent = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {

      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        userName.value = data['name'] ?? "User";
        userRole.value = data['role'] ?? "student";
        totalDue.value = "${data['due'] ?? 0} BDT";
      }


      String today = DateFormat('EEEE').format(DateTime.now());
      var routineSnapshot = await _firestore
          .collection('routines')
          .where('day', isEqualTo: today)
          .get();
      todayClassCount.value = routineSnapshot.docs.length;

      // --- ROLL BASED DATA FETCHING ---

      if (userRole.value == 'student') {

        var attendSnapshot = await _firestore
            .collection('attendance')
            .where('studentId', isEqualTo: user.uid)
            .get();
        if (attendSnapshot.docs.isNotEmpty) {
          int total = attendSnapshot.docs.length;
          int present = attendSnapshot.docs
              .where((doc) => doc['status'] == 'Present')
              .length;
          attendanceRate.value = present / total;
        }


        var bookSnapshot = await _firestore
            .collection('borrow_requests')
            .where('uid', isEqualTo: user.uid)
            .where('status', isEqualTo: 'Approved')
            .get();
        borrowedBookCount.value = bookSnapshot.docs.length;
      } else {
        // --- TEACHER LOGIC ---

        String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

        var todayAttendSnapshot = await _firestore
            .collection('attendance')
            .where('date', isEqualTo: dateStr)
            .get();

        int present = 0;
        int absent = 0;

        for (var doc in todayAttendSnapshot.docs) {
          if (doc['status'] == 'Present')
            present++;
          else
            absent++;
        }

        totalStudentsPresent.value = present;
        totalStudentsAbsent.value = absent;
      }


      var examSnapshot = await _firestore
          .collection('exams')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();
      if (examSnapshot.docs.isNotEmpty) {
        nextExamDate.value = examSnapshot.docs.first['date'];
      }
    } catch (e) {
      print("Error fetching dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
