import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  var isLibrarian = false.obs;
  var searchText = "".obs;
  var myRequestedBookIds = <String>[].obs;

  // Text Controllers (Add/Edit Book)
  final titleCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  final copiesCtrl = TextEditingController();
  final coverUrlCtrl = TextEditingController();

  // Search Controller
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRole();
    fetchMyRequests();
    searchController.addListener(() {
      searchText.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    titleCtrl.dispose();
    authorCtrl.dispose();
    copiesCtrl.dispose();
    coverUrlCtrl.dispose();
    super.onClose();
  }

  // ---   Role Check ---
  void checkRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          isLibrarian.value = (doc.data() as Map)['role'] == 'teacher';
        }
      } catch (e) {
        print(e);
      }
    }
  }

  // ---   Request Book (Student) ---
  void fetchMyRequests() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('borrow_requests')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          myRequestedBookIds.value = snapshot.docs
              .where((doc) => doc['status'] != 'Returned')
              .map((doc) => doc['bookId'] as String)
              .toList();
        });
  }

  void requestBook(String bookId, String bookName) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();

      await _firestore.collection('borrow_requests').add({
        'bookId': bookId,
        'bookName': bookName,
        'studentName': userDoc['name'],
        'roll': userDoc['roll'],
        'uid': user.uid,
        'status': 'Pending',
        'requestDate': FieldValue.serverTimestamp(),
        'returnDate': null,
      });
      Get.snackbar(
        "Success",
        "Request Sent!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---  Manage Book (Add/Edit/Delete) - Librarian ---
  void initForm(DocumentSnapshot? doc) {
    if (doc != null) {
      var data = doc.data() as Map<String, dynamic>;
      titleCtrl.text = data['title'];
      authorCtrl.text = data['author'];
      copiesCtrl.text = data['available_copies'].toString();
      coverUrlCtrl.text = data['coverUrl'] ?? '';
    } else {
      titleCtrl.clear();
      authorCtrl.clear();
      copiesCtrl.clear();
      coverUrlCtrl.clear();
    }
  }

  void saveBook(String? docId) async {
    if (titleCtrl.text.isEmpty || copiesCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Title and Copies are required",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Map<String, dynamic> data = {
      'title': titleCtrl.text,
      'author': authorCtrl.text,
      'available_copies': int.parse(copiesCtrl.text),
      'coverUrl': coverUrlCtrl.text.isNotEmpty ? coverUrlCtrl.text : null,
    };

    try {
      if (docId != null) {
        await _firestore.collection('books').doc(docId).update(data);
        Get.back();
        Get.snackbar(
          "Success",
          "Book Updated!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.back();
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('books').add(data);

        Get.snackbar(
          "Success",
          "Book Added!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      // Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void deleteBook(String bookId) {
    Get.defaultDialog(
      title: "Delete Book?",
      middleText: "Are you sure you want to delete this book?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection('books').doc(bookId).delete();
        Get.back();
        Get.snackbar(
          "Deleted",
          "Book removed successfully.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  // ---  Admin Actions (Approve/Return/Delete Request) ---

  void deleteRequest(String reqId) {
    Get.defaultDialog(
      title: "Delete Record?",
      middleText: "This will permanently remove this borrow record.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _firestore.collection('borrow_requests').doc(reqId).delete();
        Get.back();
        Get.snackbar(
          "Deleted",
          "Record Deleted!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void approveRequest(String reqId, String bookId) {
    _firestore.runTransaction((transaction) async {
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      DocumentSnapshot bookSnapshot = await transaction.get(bookRef);

      if (bookSnapshot.exists) {
        int newStock = (bookSnapshot['available_copies'] as int) - 1;
        if (newStock >= 0) {
          transaction.update(bookRef, {'available_copies': newStock});
          DateTime returnDate = DateTime.now().add(Duration(days: 7));
          transaction.update(
            _firestore.collection('borrow_requests').doc(reqId),
            {
              'status': 'Approved',
              'returnDate': Timestamp.fromDate(returnDate),
            },
          );
        }
      }
    });
  }

  void returnBook(String reqId, String bookId) {
    _firestore.runTransaction((transaction) async {
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      DocumentSnapshot bookSnapshot = await transaction.get(bookRef);

      if (bookSnapshot.exists) {
        int newStock = (bookSnapshot['available_copies'] as int) + 1;
        transaction.update(bookRef, {'available_copies': newStock});
        transaction.update(
          _firestore.collection('borrow_requests').doc(reqId),
          {'status': 'Returned'},
        );
      }
    });
  }

  // Helper for Current User ID
  String get currentUid => _auth.currentUser?.uid ?? "";
}
