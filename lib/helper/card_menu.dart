import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildMenuCard(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  Widget? page,
) {
  return GestureDetector(
    onTap: () {
      if (page != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Coming Soon!")));
      }
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 30, color: color),
          ),
          SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
