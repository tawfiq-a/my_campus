import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../screen/mainScreen/main_screen.dart';

class AuthController extends GetxController {
  // --- Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Observables (Variables that change) ---
  var isLoading = false.obs;
  var role = 'student'.obs;
  var selectedDept = RxnString();
  var selectedBloodGroup = RxnString();

  // --- Text Controllers (Login) ---
  final loginInputCtrl = TextEditingController();
  final loginPassCtrl = TextEditingController();
  final resetEmailCtrl = TextEditingController();

  // --- Text Controllers (Registration) ---
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final sessionCtrl = TextEditingController();
  final adminCodeCtrl = TextEditingController();

  // --- Lists ---
  final List<String> departments = [
    'CST',
    'EMT',
    'ENT',
    'RAC',
    'MECHANICAL',
    'ET',
    'CIVIL',
  ];
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

  // ==========================
  // LOGIN FUNCTION
  // ==========================
  void login() async {
    String input = loginInputCtrl.text.trim();
    String password = loginPassCtrl.text.trim();

    if (input.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      String emailToLogin = input;

      if (!input.contains('@')) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .where('roll', isEqualTo: input)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          emailToLogin = snapshot.docs.first['email'];
        } else {
          throw "email or Roll Number not found!";
        }
      }

      await _auth.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );

      Get.offAll(() => MainView());
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  // ==========================
  // REGISTRATION FUNCTION
  // ==========================
  void register() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.length < 6 ||
        selectedDept.value == null) {
      Get.snackbar(
        "Error",
        "Please fill all required fields!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (role.value == 'teacher' && adminCodeCtrl.text != 'admin123') {
      Get.snackbar(
        "Error",
        "Invalid Secret Code!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      UserCredential newUser = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      await newUser.user?.updateDisplayName(nameCtrl.text.trim());

      Map<String, dynamic> userData = {
        'uid': newUser.user!.uid,
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'roll': rollCtrl.text.trim(),
        'role': role.value,
        'dept': selectedDept.value,
        'phone': phoneCtrl.text.trim(),
        'bloodGroup': selectedBloodGroup.value ?? 'N/A',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (role.value == 'student') {
        userData['session'] = sessionCtrl.text.trim();
      }


      await _firestore.collection('users').doc(newUser.user!.uid).set(userData);


      if (role.value == 'teacher') {
        await _firestore.collection('teachers').add({
          'name': nameCtrl.text.trim(),
          'designation': 'Instructor',
          'dept': selectedDept.value,
          'phone': phoneCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
        });
      }

      Get.back();
      Get.snackbar(
        "Success",
        "Account Created Successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  // ==========================
  // GOOGLE SIGN IN
  // ==========================
  Future<void> googleSignIn() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'roll': 'N/A',
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Get.offAll(() => MainView());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Google Sign In Failed: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }

  // ==========================
  // FORGOT PASSWORD
  // ==========================
  void sendPasswordResetEmail() async {
    if (resetEmailCtrl.text.isEmpty) return;
    try {
      await _auth.sendPasswordResetEmail(email: resetEmailCtrl.text.trim());
      Get.back();
      Get.snackbar(
        "Success",
        "Reset link sent to email!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      resetEmailCtrl.clear();
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
