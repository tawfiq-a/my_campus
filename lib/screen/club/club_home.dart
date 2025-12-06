import 'package:flutter/material.dart';
import 'club_list.dart';
import 'my_club.dart';

class ClubHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Clubs & Communities", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: "Explore Clubs"), Tab(text: "My Clubs")],
          ),
        ),
        body: TabBarView(
          children: [
            ClubListView(),
            MyClubsView(),
          ],
        ),
      ),
    );
  }
}