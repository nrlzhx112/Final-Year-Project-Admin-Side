import 'package:emindmatterssystemadminside/SideBarPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant.dart';
import 'AdminModel.dart';

class EditAdminProfile extends StatefulWidget {
  final AdminModel admin;

  EditAdminProfile({required this.admin});

  @override
  _EditAdminProfileState createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _birthdateController;
  late TextEditingController _emailController;
  final RegExp _usernameValidator = RegExp(r'^[a-z0-9]+$'); // RegExp for lowercase letters and numbers
  bool _isEditingUsername = false;
  bool _isEditingBio = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _birthdateController = TextEditingController();
    _bioController = TextEditingController();

    // Initialize with user's birthdate if available, else use current date
    _selectedDate = widget.admin.birthdate ?? DateTime.now();

    _fetchProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _bioController.dispose();
    super.dispose();
  }


  Future<void> _deleteAdminAccount() async {
    try {
      // Get current user
      User? currentAdmin = FirebaseAuth.instance.currentUser;

      if (currentAdmin == null) {
        throw Exception("No authenticated user found");
      }

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(currentAdmin.uid)
          .delete();

      // Delete user's authentication record
      await currentAdmin.delete();

      // Navigate to the welcome screen or log-in screen after successful deletion
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } catch (e) {
      // Handle errors, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    }
  }

  // Method to show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    // Ensure _selectedDate is between firstDate and lastDate
    DateTime adjustedInitialDate = _selectedDate;
    DateTime firstDate = DateTime(1963);
    DateTime lastDate = DateTime(2011);

    if (_selectedDate.isBefore(firstDate)) {
      adjustedInitialDate = firstDate;
    } else if (_selectedDate.isAfter(lastDate)) {
      adjustedInitialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: adjustedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _fetchProfileData() async {
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
        .collection('admins')
        .doc(widget.admin.adminId)
        .get(); // Changed from .collection('userProfile').doc('profile').get();

    if (profileSnapshot.exists) {
      final adminProfileData = profileSnapshot.data() as Map<String, dynamic>?;
      final username = adminProfileData?['username'] as String?;
      final email = adminProfileData?['email'] as String?;
      final birthdate = adminProfileData?['birthdate'] as String?;
      final bio = adminProfileData?['bio'] as String?;

      if (username != null) {
        setState(() {
          _usernameController.text = username;
        });
      }
      if (email != null) {
        setState(() {
          _emailController.text = email;
        });
      }
      if (birthdate != null) {
        DateTime parsedDate = DateTime.tryParse(birthdate) ?? DateTime.now();
        setState(() {
          _birthdateController.text = DateFormat('yyyy-MM-dd').format(parsedDate);
          _selectedDate = parsedDate; // Update _selectedDate
        });
      }
      if (bio != null) {
        setState(() {
          _bioController.text = bio;
        });
      }
    }
  }


  Future<void> _saveProfileChanges() async {
    // Validation
    if (!_usernameValidator.hasMatch(_usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username must contain only lowercase letters and numbers")),
      );
      return;
    }

    if (_birthdateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Birthdate cannot be empty")),
      );
      return;
    }

    if (_bioController.text.isEmpty || _bioController.text.split(' ').length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bio cannot be empty and must be less than 150 words")),
      );
      return;
    }

    try {
      final DocumentReference adminRef = FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.admin.adminId);


      Map<String, dynamic> adminProfileData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'birthdate': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'bio' : _bioController.text,
      };

      await adminRef.set(adminProfileData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile successfully updated")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SideBarPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColors,
        automaticallyImplyLeading: false, // Set this to false to hide the back button
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: pShadeColor9,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [
            SizedBox(height: 155.0),

            if (_isEditingUsername)
              Container(
                margin: EdgeInsets.only(left: 300.0, right: 300.0),
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: pShadeColor4),
                  child: TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: pShadeColor9),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: pShadeColor8),
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: pShadeColor6, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: pShadeColor5, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      errorText: _usernameValidator.hasMatch(_usernameController.text)
                          ? null
                          : 'Username can only contain lowercase letters and numbers',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check, color: pShadeColor6),
                        onPressed: () {
                          setState(() {
                            _isEditingUsername = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingUsername = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(left: 300.0, right: 300.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: pShadeColor6, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _usernameController.text.isEmpty ? "Enter your username" : _usernameController.text,
                          style: TextStyle(fontSize: 18.0, color: pShadeColor9),
                        ),
                      ),
                      Icon(Icons.edit, color: pShadeColor6),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 20.0),

            // Email display section
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.only(left: 300.0, right: 300.0),
              decoration: BoxDecoration(
                border: Border.all(color: pShadeColor6, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: TextStyle(fontSize: 18.0, color: pShadeColor9),
                    ),
                  ),
                  Icon(Icons.email, color: pShadeColor6),
                ],
              ),
            ),

            SizedBox(height: 20.0),

            // Birthdate selection section
            GestureDetector(
              onTap: () => _selectDate(context), // Directly call _selectDate
              child: Container(
                margin: EdgeInsets.only(left: 300.0, right: 300.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: pShadeColor6, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _birthdateController.text.isEmpty
                            ? "Select your birthdate"
                            : _birthdateController.text,
                        style: TextStyle(fontSize: 18.0, color: pShadeColor9),
                      ),
                    ),
                    Icon(Icons.calendar_today, color: pShadeColor6),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.0),

            if (_isEditingBio)
              Container(
                margin: EdgeInsets.only(left: 300.0, right: 300.0),
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: pShadeColor4),
                  child: TextFormField(
                    controller: _bioController,
                    style: TextStyle(color: pShadeColor9),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: TextStyle(color: pShadeColor8),
                      hintText: "Enter your bio",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: pShadeColor6, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: pShadeColor5, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check, color: pShadeColor6),
                        onPressed: () {
                          setState(() {
                            _isEditingBio = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingBio = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(left: 300.0, right: 300.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: pShadeColor6, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bioController.text.isEmpty ? "Enter your bio" : _bioController.text,
                          style: TextStyle(fontSize: 18.0, color: pShadeColor9),
                        ),
                      ),
                      Icon(Icons.edit, color: pShadeColor6),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 36),

            // Button Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Aligns the children to the center horizontally
              children: [
                // Save Profile Button with fixed width
                Container(
                  width: 150.0, // Fixed width
                  margin: EdgeInsets.only(right: 15.0), // Margin to the right side
                  child: ElevatedButton(
                    onPressed: _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pShadeColor4,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: Text(
                      "Save Profile",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Delete Account Button with fixed width
                Container(
                  width: 150.0, // Fixed width
                  child: ElevatedButton(
                    onPressed: _deleteAdminAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: Text(
                      "Delete Account",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}



