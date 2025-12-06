import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? user;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sessionController = TextEditingController();

  String? selectedBloodGroup;
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  String userRole = 'student';
  bool isLoading = true;
  bool isSaving = false;

  // Edit Mode Variable
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // --- Fetch User Data ---
  void _getUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user!.uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              userRole = data['role'] ?? 'student';
              _nameController.text = data['name'] ?? '';
              _rollController.text = data['roll'] ?? '';
              _phoneController.text = data['phone'] ?? '';
              selectedBloodGroup = data['bloodGroup'];

              if (userRole == 'teacher') {
                _deptController.text = data['dept'] ?? '';
              } else {
                _sessionController.text = data['session'] ?? '';
              }
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print("Error: $e");
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  // --- Update Profile ---
  Future<void> _updateProfile() async {
    setState(() => isSaving = true);
    try {
      await user!.updateDisplayName(_nameController.text);
      await user!.reload();

      Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'roll': _rollController.text,
        'phone': _phoneController.text,
        'bloodGroup': selectedBloodGroup,
      };

      if (userRole == 'teacher') {
        updateData['dept'] = _deptController.text;
      } else {
        updateData['session'] = _sessionController.text;
      }

      await _firestore.collection('users').doc(user!.uid).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile Updated Successfully!")),
        );
        // Turn off edit mode after save
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
    if (mounted) setState(() => isSaving = false);
  }

  // --- Logout Dialog ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 10),
              Text("Log Out", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                "Yes, Log Out",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Edit Toggle Button
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? "Cancel Editing" : "Edit Profile",
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                // If canceled, reload original data
                if (!_isEditing) {
                  _getUserData();
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- Header ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: userRole == 'teacher'
                            ? [Colors.deepPurple, Colors.indigo]
                            : [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text[0].toUpperCase()
                                : "U",
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _nameController.text,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user!.email ?? "",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- Form Fields ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTextField(
                          _nameController,
                          "Full Name",
                          Icons.person,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          _phoneController,
                          "Phone Number",
                          Icons.phone,
                          isNumber: true,
                        ),
                        SizedBox(height: 15),

                        // Warning if Blood Group is missing
                        if (selectedBloodGroup == null && !_isEditing) ...[
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Please add Blood Group to help others in emergency!",
                                    style: TextStyle(
                                      color: Colors.orange.shade900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],

                        // Blood Group Dropdown
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Blood Group",
                            prefixIcon: Icon(
                              Icons.bloodtype,
                              color: _isEditing ? Colors.pink : Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: _isEditing
                                    ? Colors.grey
                                    : Colors.transparent,
                              ),
                            ),
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.grey[50]
                                : Colors.grey[200],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedBloodGroup,
                              hint: Text("Select Group"),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: _isEditing ? Colors.black : Colors.grey,
                              ),
                              style: TextStyle(
                                color: _isEditing
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontSize: 16,
                              ),
                              items: bloodGroups
                                  .map(
                                    (bg) => DropdownMenuItem(
                                      value: bg,
                                      child: Text(bg),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isEditing
                                  ? (val) =>
                                        setState(() => selectedBloodGroup = val)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Role Specific Fields
                        if (userRole == 'teacher') ...[
                          _buildTextField(
                            _deptController,
                            "Department",
                            Icons.school,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            _rollController,
                            "Teacher ID",
                            Icons.badge,
                          ),
                        ] else ...[
                          _buildTextField(
                            _rollController,
                            "Roll Number",
                            Icons.confirmation_number,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            _sessionController,
                            "Session (e.g. 2020-21)",
                            Icons.calendar_today,
                          ),
                        ],

                        SizedBox(height: 30),

                        // Update Button (Visible only in Edit Mode)
                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: isSaving ? null : _updateProfile,
                              child: isSaving
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "UPDATE PROFILE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                        if (_isEditing) SizedBox(height: 20),

                        Divider(),
                        SizedBox(height: 10),

                        // Logout Button
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.logout, color: Colors.redAccent),
                          ),
                          title: Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          onTap: () {
                            _showLogoutDialog();
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Styled Text Field
  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      enabled: _isEditing, // Only enabled when editing
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: _isEditing ? Colors.black : Colors.grey[700]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _isEditing ? Colors.deepPurple : Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: _isEditing ? Colors.deepPurple : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: _isEditing ? Colors.grey : Colors.transparent,
          ),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[200],
      ),
    );
  }
}
