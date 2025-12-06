import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankController extends GetxController {
  // --- Observables ---
  // RxnString মানে এটি নাল (null) হতে পারে, শুরুতে কোনো গ্রুপ সিলেক্ট করা থাকবে না
  var selectedGroup = RxnString();

  // --- Static Data ---
  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  // --- Stream getter ---
  // সিলেক্ট করা ব্লাড গ্রুপের ওপর ভিত্তি করে স্ট্রিম রিটার্ন করবে
  Stream<QuerySnapshot> get donorsStream {
    return FirebaseFirestore.instance
        .collection('users')
        .where('bloodGroup', isEqualTo: selectedGroup.value)
        .snapshots();
  }

  // --- Phone Call Logic ---
  void callDonor(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar(
          "Error",
          "Could not launch dialer",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }
}