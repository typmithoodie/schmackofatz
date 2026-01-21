import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schmackofatz/main.dart';

class MealPlanerScreen extends StatelessWidget {
  const MealPlanerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Image.asset(
                  'lib/images/schmackofatz_logo.png',
                  height: 28,
                  width: 28,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Wochenplan erstellen",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigatorPage()),
                    );
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    size: 26,
                    color: Colors.black,
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
