import 'package:get/get.dart';

class MainController extends GetxController {
  // বর্তমান সিলেক্ট করা ট্যাবের ইনডেক্স (Reactive)
  var selectedIndex = 0.obs;

  // ট্যাব পরিবর্তন করার ফাংশন
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}