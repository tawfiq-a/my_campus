import 'package:flutter/material.dart';
import 'exam_routine.dart';
import 'routine_screen.dart';

class RoutineHomeScreen extends StatelessWidget {
  const RoutineHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedules & Routines",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            // --- Class Routine Card ---
            _buildRoutineOptionCard(
              context,
              "Class Routine",
              "Weekly class schedule & teachers info",
              Icons.calendar_view_week,
              Colors.blueAccent,
              RoutineView(),
            ),

            SizedBox(height: 20),

            // --- Exam Routine Card ---
            _buildRoutineOptionCard(
              context,
              "Exam Routine",
              "Midterm & Final exam dates and seat plans",
              Icons.assignment_late,
              Colors.orangeAccent,
              ExamRoutineView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
