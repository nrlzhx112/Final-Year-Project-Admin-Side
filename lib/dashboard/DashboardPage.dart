import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../admin/AdminModel.dart';
import '../admin/EditAdminProfile.dart';
import '../constant.dart';
import 'AllUserDailyCountBar.dart';
import 'AllUserWeeklyCountData.dart';
import 'AllUserMonthlyCountBar.dart';
import 'AllUserYearlyCountBar.dart';
import 'dataModelMoods/MoodEntryModel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  User? currentAdmin = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? adminProfileData;
  Stream<List<MoodEntryModel>>? moodEntriesStream; // Stream to hold mood entries
  String _selectedTimeframe = 'daily'; // Default timeframe
  Map<String, int> moodCounts = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchAllUsersMoodEntries();
  }

  Future<void> _fetchProfileData() async {
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
        .collection('admins')
        .doc(currentAdmin?.uid)
        .get();

    if (profileSnapshot.exists) {
      setState(() {
        adminProfileData = profileSnapshot.data() as Map<String, dynamic>?;
      });
    }
  }

  void _fetchAllUsersMoodEntries() async {
    moodEntriesStream = _getAllUsersMoodEntriesStream();
    _calculateMoodCounts(_selectedTimeframe);
  }

  Stream<List<MoodEntryModel>> _getAllUsersMoodEntriesStream() {
    return FirebaseFirestore.instance
        .collection('moods')
        .orderBy('moodDateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) =>
            MoodEntryModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Map<String, int> _calculateMoodCountsForTimeframe(String timeframe,
      List<MoodEntryModel> moodEntries) {
    Map<String, int> moodCounts = {};

    DateTime now = DateTime.now();
    DateTime startDateTime;

    switch (timeframe) {
      case 'daily':
        startDateTime = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDateTime = now.subtract(
            Duration(days: now.weekday - 1));
        break;
      case 'monthly':
        startDateTime = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        startDateTime = DateTime(now.year, 1, 1);
        break;
      default:
        startDateTime = now;
        break;
    }

    for (var moodEntry in moodEntries) {
      if (moodEntry.moodDateTime.isAfter(startDateTime)) {
        String moodTypeName = moodEntry.moodType.emojiName;
        moodCounts[moodTypeName] = (moodCounts[moodTypeName] ?? 0) + 1;
      }
    }

    return moodCounts;
  }

  void _calculateMoodCounts(String timeframe) {
    if (moodEntriesStream != null) {
      moodEntriesStream!.listen((moodEntries) {
        setState(() {
          moodCounts = _calculateMoodCountsForTimeframe(timeframe, moodEntries);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // first half of page
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: pShadeColor2,  // You can change the color to your preference
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: pShadeColor1.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8.0),  // Adjust padding as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _selectedTimeframe,
                      items: ['daily', 'weekly', 'monthly', 'yearly'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTimeframe = newValue!;
                        });
                        _calculateMoodCounts(_selectedTimeframe);
                      },
                    ),
                    if (moodCounts.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_selectedTimeframe == 'daily')
                                DailyMoodCountBarGraphPage(
                                  moodCounts: moodCounts,
                                  timeframe: _selectedTimeframe,
                                  selectedDate: selectedDate,
                                ),
                              if (_selectedTimeframe == 'weekly')
                                WeeklyMoodCountBarGraphPage(
                                  moodCounts: moodCounts,
                                  timeframe: _selectedTimeframe,
                                ),
                              if (_selectedTimeframe == 'monthly')
                                MonthlyMoodCountBarGraphPage(
                                  moodCounts: moodCounts,
                                  timeframe: _selectedTimeframe,
                                ),
                              if (_selectedTimeframe == 'yearly')
                                YearlyMoodCountBarGraphPage(
                                  moodCounts: moodCounts,
                                  timeframe: _selectedTimeframe,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // second half of page
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'lib/assets/logo1.png',
                        fit: BoxFit.cover,  // You can adjust the fit based on your requirements
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: adminProfileData == null
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                      height: 400,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: pShadeColor1,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Center( // Wrap the Text widget with a Center widget
                            child: Text(
                              'Your Profile Details',
                              style: GoogleFonts.openSans( // Using Google Fonts for styling
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: pShadeColor9,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          _profileInfo('Username', adminProfileData?['username']),
                          _profileInfo('Email', adminProfileData?['email']),
                          _profileInfo('Birthdate', adminProfileData?['birthdate']),
                          _profileInfo('Bio', adminProfileData?['bio']),
                          Align(
                            alignment: Alignment.center,
                            child: _editProfileButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: pShadeColor1.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: pShadeColor9,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not specified',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: pShadeColor8,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editProfileButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          if (adminProfileData != null) {
            DateTime? birthdate;
            if (adminProfileData?['birthdate'] != null) {
              birthdate = DateTime.tryParse(adminProfileData!['birthdate']);
            }

            // Create a UserModel instance
            AdminModel adminModel = AdminModel(
              adminId: currentAdmin!.uid,
              email: adminProfileData!['email'],
              username: adminProfileData!['username'],
              birthdate: birthdate,
              bio: adminProfileData?['bio'],
              isOnline: true,
              role: UserRole.admin,
            );

            // Navigate to EditUserProfile with the UserModel instance
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditAdminProfile(admin: adminModel)),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: pShadeColor8,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 135.0),
        ),
        child: Text(
          "Edit Profile",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
