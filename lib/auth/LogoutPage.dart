import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

User? currentAdmin = FirebaseAuth.instance.currentUser;

Future<void> _logout(BuildContext context) async {
  try {
    // Update the user's online status in Firestore
    if (currentAdmin != null) {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(currentAdmin!.uid)
          .update({'isOnline': false});
    }

    // Sign out from Firebase Auth
    await FirebaseAuth.instance.signOut();

    // Navigate to the welcome screen
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  } catch (e) {
    print('Logout failed: $e');
    // Optionally, handle the error more gracefully
  }
}

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmLogout(context),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  // Confirmation dialog for logging out
  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Do you really want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }
}
