import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../attendence.dart';
import 'attendence_history.dart';


class AttendanceHomeView extends StatefulWidget {
  @override
  _AttendanceHomeViewState createState() => _AttendanceHomeViewState();
}

class _AttendanceHomeViewState extends State<AttendanceHomeView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _navigateBasedOnRole();
  }

  void _navigateBasedOnRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        String role = (doc.data() as Map)['role'] ?? 'student';

        if (role == 'teacher') {

          Get.off(() => TakeAttendanceView());
        } else {

          Get.off(() => StudentAttendanceHistoryView());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}