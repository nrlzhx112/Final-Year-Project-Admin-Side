import 'package:flutter/material.dart';
import 'auth/Login.dart';
import 'auth/Signup.dart';
import 'constant.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: pShadeColor2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo Image
            Image.asset(
              'lib/assets/logo1.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium,
                    children: [
                      TextSpan(
                        text: "E-Mind",
                        style: TextStyle(
                          color: pShadeColor9,
                        ),
                      ),
                      TextSpan(
                        text: "Matters",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pShadeColor9,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //button => SignUpPage()
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: pShadeColor6,
                      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 25), // Increased padding to make the button larger
                      backgroundColor: pShadeColor5, // Background color
                      elevation: 5, // Elevation for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: pShadeColor6,
                      padding: EdgeInsets.symmetric(horizontal: 130, vertical: 25), // Increased padding to make the button larger
                      backgroundColor: pShadeColor5, // Background color
                      elevation: 5, // Elevation for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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