
import 'package:chat_app/screen/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../chat/chat_user_list.dart';
import '../homeScreen/home_screen.dart';
import '../notice/notice_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeDashboard(),
    NoticeScreen(),
    ChatUserListView(),
    ProfileScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],


      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.white,
             color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.deepPurple,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.notifications, text: 'Notice'),
              GButton(icon: Icons.chat_bubble, text: 'Chat'),
              GButton(icon: Icons.person_3, text: 'profile'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
