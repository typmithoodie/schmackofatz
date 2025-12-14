import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 45),
            Row(
              children: [
                Image.asset(
                  'lib/images/schmackofatz_logo.png',
                  height: 25,
                  width: 25,
                ),
                Text(
                  "Analyse",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 120),
                Icon(
                  Icons.notifications_outlined,
                  fontWeight: FontWeight.normal,
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
