import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoutineScreen extends StatefulWidget {
  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _firestore = FirebaseFirestore.instance;


  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  final _roomController = TextEditingController();
  final _teacherNameController = TextEditingController();

  String selectedDay = 'Saturday'; // Default selected day

  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  bool isLoading = false;

  void _saveRoutine() async {
    if (_subjectController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill required fields")));
      return;
    }

    setState(() => isLoading = true);
    try {
      await _firestore.collection('routines').add({
        'day': selectedDay,
        'subject': _subjectController.text,
        'time': _timeController.text,
        'room': _roomController.text,
        'teacher': _teacherNameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Class Added!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Class Routine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Day Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDay,
                    isExpanded: true,
                    items: days.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(
                          day,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDay = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),

              _buildTextField(
                _subjectController,
                "Subject Name (e.g. CSE 101)",
                Icons.book,
              ),
              SizedBox(height: 15),
              _buildTextField(
                _timeController,
                "Time (e.g. 10:00 AM - 11:30 AM)",
                Icons.access_time,
              ),
              SizedBox(height: 15),
              _buildTextField(
                _roomController,
                "Room Number (e.g. 302)",
                Icons.meeting_room,
              ),
              SizedBox(height: 15),
              _buildTextField(
                _teacherNameController,
                "Teacher Name (Optional)",
                Icons.person,
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: isLoading ? null : _saveRoutine,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "ADD TO ROUTINE",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
