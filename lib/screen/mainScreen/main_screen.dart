import 'package:chat_app/screen/homeScreen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../controller/main_screen_controller/main_screen_controller.dart';

import '../chat/chat_user_list.dart';
import '../homeScreen/home_screen.dart';
import '../notice/notice_screen.dart';
import '../profile/profile_screen.dart';

class MainView extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  final List<Widget> _pages = [
    DashboardView(), // 0
    HomeDashboard(), // 1
    ChatUserListView(), // 2
    ProfileView(), // 3
  ];

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.selectedIndex.value]),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        )),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.white38,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(icon: Icons.dashboard, text: 'Dashboard', hoverColor: Colors.white),
              GButton(icon: Icons.home_outlined, text: 'Home'),
              GButton(icon: Icons.chat_bubble, text: 'Chat'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],

            selectedIndex: controller.selectedIndex.value,
            onTabChange: (index) {
              controller.changeTabIndex(index);
            },
          ),
        ),
      ),
    );
  }
}
