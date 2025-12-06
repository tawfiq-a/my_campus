import 'package:chat_app/screen/mainScreen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'club_list.dart';
import 'my_club.dart';

class ClubHomeScreen extends StatelessWidget {
  const ClubHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.to(() => MainView());
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            "Clubs & Communities",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Explore Clubs"),
              Tab(text: "My Clubs"),
            ],
          ),
        ),
        body: TabBarView(children: [ClubListView(), MyClubsView()]),
      ),
    );
  }
}
