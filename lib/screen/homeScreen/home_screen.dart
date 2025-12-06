import 'package:chat_app/screen/about.dart';
import 'package:chat_app/screen/notice/notice_screen.dart';
import 'package:chat_app/screen/routin/routine_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helper/card_menu.dart';
import '../accounts/accounts_home.dart';
import '../chat/chat_user_list.dart';
import '../club/club_home.dart';
import '../features/blood_bank_screen.dart';
import '../features/event_gallery.dart';
import '../library/library_home.dart';
import '../teachers/teacher_screen.dart';

class HomeDashboard extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("My Campus", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: 30, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${user?.displayName ?? 'Student'}!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "What do you want to check today?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(15),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                buildMenuCard(
                  context,
                  "Notices",
                  Icons.notifications_active,
                  Colors.orange,
                  NoticeListView(),
                ),
                buildMenuCard(
                  context,
                  "Teachers",
                  Icons.school,
                  Colors.blue,
                  TeacherView(),
                ),
                buildMenuCard(
                  context,
                  "Chat Room",
                  Icons.chat,
                  Colors.green,
                  ChatUserListView(),
                ),
                buildMenuCard(
                  context,
                  "Routine",
                  Icons.calendar_today,
                  Colors.purple,
                  RoutineHomeScreen(),
                ),
                buildMenuCard(
                  context,
                  "Register & Accounts",
                  Icons.account_balance,
                  Colors.teal,
                  AccountsHomeView(),
                ),
                buildMenuCard(
                  context,
                  "Library",
                  Icons.library_books,
                  Colors.brown,
                  LibraryHomeView(),
                ),
                buildMenuCard(
                  context,
                  "Blood Bank",
                  Icons.bloodtype,
                  Colors.red,
                  BloodBankView(),
                ),
                buildMenuCard(
                  context,
                  "Events & Gallery",
                  Icons.celebration,
                  Colors.pink,
                  EventGalleryView(),
                ),
                buildMenuCard(
                  context,
                  "Clubs",
                  Icons.diversity_3,
                  Colors.indigo,
                  ClubHomeScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
