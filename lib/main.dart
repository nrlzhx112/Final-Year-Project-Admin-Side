import 'package:emindmatterssystemadminside/SideBarPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'WelcomePage.dart';
import 'constant.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

class MyApp extends StatelessWidget {
  final Widget initialPage;
  // Constructor to set the initial page
  const MyApp({required this.initialPage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Mind Matters System',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColors,
        primaryColor: pShadeColor9,
      ),
      home: initialPage, // Use the home property here
      routes: {
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  Widget initialPage;

  if (user != null) {
    initialPage = SideBarPage();
  } else {
    initialPage = WelcomePage();
  }

  runApp(MyApp(initialPage: initialPage));
}