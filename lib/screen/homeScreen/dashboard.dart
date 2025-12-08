import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/main_screen_controller/dashboard_controller.dart';
import '../attendence/attendence_home.dart';
import '../notice/notice_screen.dart';
import '../routin/routine_home.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        bool isTeacher = controller.userRole.value == 'teacher';

        return SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Bar ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          controller.userName.value.split(" ")[0],
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepPurple, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(Icons.person, color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // --- Hero Card (Role Based) ---
                if (isTeacher)
                  _buildTeacherStatsCard(controller)
                else
                  _buildStudentStatsCard(controller),

                SizedBox(height: 30),

                // --- Dashboard Grid ---
                Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    _buildModernCard(
                      title: "Today's Classes",
                      value: "${controller.todayClassCount.value}",
                      icon: Icons.school_rounded,
                      color: Colors.orange,
                      bg: Colors.orange.shade50,
                    ),
                    _buildModernCard(
                      title: "Next Exam",
                      value: controller.nextExamDate.value,
                      icon: Icons.calendar_month_rounded,
                      color: Colors.blue,
                      bg: Colors.blue.shade50,
                      isDate: true,
                    ),
                    if (!isTeacher) // Only Student
                      _buildModernCard(
                        title: "Library Books",
                        value: "${controller.borrowedBookCount.value}",
                        icon: Icons.book_rounded,
                        color: Colors.pink,
                        bg: Colors.pink.shade50,
                      ),
                    if (!isTeacher) // Only Student
                      _buildModernCard(
                        title: "Pending Dues",
                        value: controller.totalDue.value,
                        icon: Icons.attach_money_rounded,
                        color: Colors.green,
                        bg: Colors.green.shade50,
                        isDate: true,
                      ),
                    if (isTeacher) // Only Teacher
                      _buildModernCard(
                        title: "Total Absent",
                        value: "${controller.totalStudentsAbsent.value}",
                        icon: Icons.person_off,
                        color: Colors.red,
                        bg: Colors.red.shade50,
                      ),
                  ],
                ),

                SizedBox(height: 30),

                // --- Quick Actions ---
                Text(
                  "Quick Access",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickAction(
                        Icons.notifications,
                        "Notices",
                        Colors.purple,
                        () => Get.to(() => NoticeListView()),
                      ),
                      _buildQuickAction(
                        Icons.schedule,
                        "Routine",
                        Colors.teal,
                        () => Get.to(() => RoutineHomeScreen()),
                      ),
                      _buildQuickAction(
                        Icons.how_to_reg,
                        "Attendance",
                        Colors.blue,
                        () => Get.to(() => AttendanceHomeView()),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Student Hero Card ---
  Widget _buildStudentStatsCard(DashboardController ctrl) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2575FC).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Academic Status",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "${(ctrl.attendanceRate.value * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Attendance Rate",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ctrl.attendanceRate.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
                Text("👍", style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Teacher Hero Card ---
  Widget _buildTeacherStatsCard(DashboardController ctrl) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.greenAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 30),
                  Text(
                    "${ctrl.totalStudentsPresent.value}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Present", style: TextStyle(color: Colors.white70)),
                ],
              ),
              Container(height: 40, width: 1, color: Colors.white30),
              Column(
                children: [
                  Icon(Icons.cancel, color: Colors.white, size: 30),
                  Text(
                    "${ctrl.totalStudentsAbsent.value}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Absent", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Modern Card ---
  Widget _buildModernCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
    bool isDate = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isDate ? 16 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Quick Action ---
  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
