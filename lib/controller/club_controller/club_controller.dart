import 'dart:math';
import 'package:chat_app/screen/club/club_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screen/club/club_list.dart';

class ClubController extends GetxController {
  // --- Instances ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Observables ---
  var isTeacher = false.obs;
  var searchText = "".obs;
  var memberSearchText = "".obs;

  var myClubStatus = <String, String>{}.obs;

  // --- Text Controllers ---
  // For Club List
  final searchCtrl = TextEditingController();

  // For Club Add/Edit
  final nameCtrl = TextEditingController();
  final sloganCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final logoCtrl = TextEditingController();

  // For Member List
  final memberSearchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRole();
    fetchMyClubs();

    // Club Search Listener
    searchCtrl.addListener(() {
      searchText.value = searchCtrl.text.toLowerCase();
    });

    // Member Search Listener
    memberSearchCtrl.addListener(() {
      memberSearchText.value = memberSearchCtrl.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    memberSearchCtrl.dispose();
    nameCtrl.dispose();
    sloganCtrl.dispose();
    descCtrl.dispose();
    logoCtrl.dispose();
    super.onClose();
  }

  // --- Helper: Get Current User ID ---
  String get currentUid => _auth.currentUser?.uid ?? "";

  // ============================================
  //  AUTH & ROLE CHECK
  // ============================================
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

  // ============================================
  //  CLUB MANAGEMENT (Create, Update, Delete)
  // ============================================

  void initForm(DocumentSnapshot? doc) {
    if (doc != null) {
      var data = doc.data() as Map<String, dynamic>;
      nameCtrl.text = data['name'];
      sloganCtrl.text = data['slogan'] ?? '';
      descCtrl.text = data['description'] ?? '';
      logoCtrl.text = data['logoUrl'] ?? '';
    } else {
      nameCtrl.clear();
      sloganCtrl.clear();
      descCtrl.clear();
      logoCtrl.clear();
    }
  }

  void saveClub(String? docId) async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Club Name is required",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Map<String, dynamic> data = {
      'name': nameCtrl.text,
      'slogan': sloganCtrl.text,
      'description': descCtrl.text,
      'logoUrl': logoCtrl.text.isNotEmpty ? logoCtrl.text : null,
    };

    try {
      if (docId != null) {
        // Update
        await _firestore.collection('clubs').doc(docId).update(data);
        Get.snackbar(
          "Success",
          "Club Updated!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('clubs').add(data);
        Get.snackbar(
          "Success",
          "Club Created!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      Get.to(() => ClubHomeScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- Delete Club Function (Only Logic) ---
  Future<void> deleteClubLogic(String clubId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).delete();

      var members = await _firestore
          .collection('club_members')
          .where('clubId', isEqualTo: clubId)
          .get();
      for (var doc in members.docs) {
        await doc.reference.delete();
      }

      Get.snackbar(
        "Deleted",
        "Club removed successfully.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    }
  }

  // ============================================
  //  JOIN & LEAVE LOGIC (For Students)
  // ============================================

  void fetchMyClubs() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('club_members')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          myClubStatus.clear();
          for (var doc in snapshot.docs) {
            myClubStatus[doc['clubId']] = doc['status'];
          }
        });
  }

  void joinClub(String clubId, String clubName) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();

      await _firestore.collection('club_members').add({
        'clubId': clubId,
        'clubName': clubName,
        'uid': user.uid,
        'name': userDoc['name'],
        'roll': userDoc['roll'],
        'status': 'Pending',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        "Sent",
        "Join Request Sent!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to join: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void leaveClub(String docId, String clubName) {
    Get.defaultDialog(
      title: "Leave Club?",
      middleText: "Are you sure you want to leave $clubName?",
      textCancel: "Cancel",
      textConfirm: "Leave",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await _firestore.collection('club_members').doc(docId).delete();
        Get.back();
        Get.snackbar("Left", "You left $clubName.");
      },
    );
  }

  // ============================================
  //  ADMIN & MEMBER MANAGEMENT (For Teachers)
  // ============================================

  String _generateMemberId(String clubName) {
    String prefix = clubName.length >= 3
        ? clubName.substring(0, 3).toUpperCase()
        : "CLB";
    String year = DateTime.now().year.toString().substring(2);
    int randomNum = Random().nextInt(900) + 100;
    return "$prefix-$year-$randomNum";
  }

  void approveMember(String docId, String clubName) {
    String newId = _generateMemberId(clubName);
    _firestore.collection('club_members').doc(docId).update({
      'status': 'Approved',
      'memberId': newId,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    Get.snackbar(
      "Approved",
      "Member ID: $newId generated.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void rejectMember(String docId) {
    _firestore.collection('club_members').doc(docId).delete();
    Get.snackbar(
      "Rejected",
      "Request removed.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void removeMember(String memberDocId, String studentName) {
    Get.defaultDialog(
      title: "Remove Member?",
      middleText: "Are you sure you want to remove $studentName?",
      textCancel: "Cancel",
      textConfirm: "Remove",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await _firestore.collection('club_members').doc(memberDocId).delete();
        Get.back();
        Get.snackbar(
          "Removed",
          "$studentName has been removed.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
    );
  }
}
