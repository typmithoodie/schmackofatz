import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                Image.asset(
                  'lib/images/schmackofatz_logo.png',
                  height: 25,
                  width: 25,
                ),
                SizedBox(height: 30),
                Text(
                  "schmackofatz",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 50),
                Icon(
                  Icons.notifications_outlined,
                  fontWeight: FontWeight.normal,
                  size: 30,
                ),
              ],
            ),
            Stack(
              children: [
                Image.asset(
                  'lib/images/home01.png',
                  height: 225,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    "Guten Tag Küchenchef! 👋🏽"
                    "\nWas kochen wir heute Leckeres?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 25,
                    fontWeight: FontWeight.w100,
                  ),
                  label: Text(
                    "KI-Rezeptvorschläge",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 26, 169, 48),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
