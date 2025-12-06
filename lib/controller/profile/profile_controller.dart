import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screen/auth/login_screen.dart';


class ProfileController extends GetxController {
  // --- Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Observables (Reactive State) ---
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isEditing = false.obs; // Tracks edit mode
  var userRole = 'student'.obs;
  var selectedBloodGroup = RxnString(); // Nullable reactive string

  // --- Text Controllers ---
  final nameCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final deptCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final sessionCtrl = TextEditingController();

  // --- Static Data ---
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    rollCtrl.dispose();
    deptCtrl.dispose();
    phoneCtrl.dispose();
    sessionCtrl.dispose();
    super.onClose();
  }

  // ---  Fetch User Data ---
  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;

          userRole.value = data['role'] ?? 'student';
          nameCtrl.text = data['name'] ?? '';
          rollCtrl.text = data['roll'] ?? '';
          phoneCtrl.text = data['phone'] ?? '';
          selectedBloodGroup.value = data['bloodGroup'];

          if (userRole.value == 'teacher') {
            deptCtrl.text = data['dept'] ?? '';
          } else {
            sessionCtrl.text = data['session'] ?? '';
          }
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to fetch profile: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    isLoading.value = false;
  }

  // ---  Toggle Edit Mode ---
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // If canceled, reload original data
      fetchUserData();
    }
  }

  // ---   Update Profile ---
  void updateProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    isSaving.value = true;
    try {
      // Update Display Name in Auth
      await user.updateDisplayName(nameCtrl.text);
      await user.reload();

      // Prepare Data Map
      Map<String, dynamic> updateData = {
        'name': nameCtrl.text,
        'roll': rollCtrl.text,
        'phone': phoneCtrl.text,
        'bloodGroup': selectedBloodGroup.value,
      };

      if (userRole.value == 'teacher') {
        updateData['dept'] = deptCtrl.text;
      } else {
        updateData['session'] = sessionCtrl.text;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update(updateData);

      Get.snackbar(
        "Success",
        "Profile Updated Successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isEditing.value = false; // Turn off edit mode
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isSaving.value = false;
  }

  // --- 4. Logout Logic ---
  void logout() {
    Get.defaultDialog(
      title: "Log Out",
      titleStyle: TextStyle(color: Colors.redAccent),
      middleText: "Are you sure you want to log out?",
      textCancel: "Cancel",
      textConfirm: "Yes, Log Out",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back(); // Close Dialog
        await _auth.signOut();
        Get.offAll(() => LoginView()); // Navigate to Login and clear stack
      },
    );
  }
}
