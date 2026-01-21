import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schmackofatz/screens/profile/profile_screen.dart';
import '../services/fridge_service.dart';
import 'fridge_screen.dart';

/// Wöchentliche Tipps für Benutzer
List<String> weeklyTips = [
  'Reste vom Mittagessen eignen sich super als Meal Prep für morgen.',
  'Plane deinen Wocheneinkauf im Voraus, um Impulskäufe zu vermeiden.',
  'Saisonale Produkte sind oft günstiger und nachhaltiger.',
  'Koche größere Portionen und friere Reste ein.',
];

/// Hauptbildschirm der App mit Dashboard-Funktionalität
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String randomTip = "";

  /// Initialisiert den Bildschirm und wählt einen zufälligen Tipp aus
  @override
  void initState() {
    super.initState();
    randomTip = weeklyTips[Random().nextInt(weeklyTips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              buildHeader(),
              SizedBox(height: 20),
              buildHeroSection(),
              SizedBox(height: 20),
              buildAIRecipeButton(),
              SizedBox(height: 20),
              buildFridgeOverviewCard(),
              SizedBox(height: 20),
              buildDailyTipCard(),
              SizedBox(height: 15),
              buildMealPlanCard(),
              SizedBox(height: 20), // Bottom padding for better UX
            ],
          ),
        ),
      ),
    );
  }

  /// Baut den Header mit Logo, Titel und Profil-Button auf
  Widget buildHeader() {
    return Row(
      children: [
        SizedBox(width: 20),
        Image.asset('lib/images/schmackofatz_logo.png', height: 28, width: 28),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            "schmackofatz",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.account_circle_outlined,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Bereich mit Begrüßung
  Widget buildHeroSection() {
    return Stack(
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
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// KI-Rezeptvorschläge-Button
  Widget buildAIRecipeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showComingSoonDialog('KI-Rezeptvorschläge');
          },
          icon: Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 25,
            fontWeight: FontWeight.w100,
          ),
          label: Text(
            "KI-Rezeptvorschläge",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 26, 169, 48),
          ),
        ),
      ],
    );
  }

  /// Vorrats-Übersichtskarte
  Widget buildFridgeOverviewCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: FridgeService().getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return buildLoadingFridgeCard();
        }

        final stats = snapshot.data!;
        final totalItems = stats['totalItems'] ?? 0;
        final expiringItems = stats['expiringItems'] ?? 0;
        final expiredItems = stats['expiredItems'] ?? 0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Color(0xFFF8F8F8),
          child: InkWell(
            onTap: () {
              // Navigation zum Kühlschrank-Bildschirm
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FridgeScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getFridgeStatusColor(expiringItems, expiredItems),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.kitchen_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Vorrat',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 26, 169, 48),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalItems Artikel',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (expiringItems > 0) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.warning_outlined,
                                size: 14,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$expiringItems laufen bald ab',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (expiredItems > 0) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$expiredItems abgelaufen',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (expiringItems == 0 &&
                            expiredItems == 0 &&
                            totalItems > 0) ...[
                          Text(
                            'Alle Artikel sind frisch!',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (totalItems == 0) ...[
                          Text(
                            'Noch keine Artikel im Vorrat',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigation zum Kühlschrank-Bildschirm
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FridgeScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    26,
                                    169,
                                    48,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Artikel hinzufügen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigation zum Kühlschrank-Bildschirm
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FridgeScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 26, 169, 48),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Ansehen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 26, 169, 48),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Lade-Karte für den Vorrat
  Widget buildLoadingFridgeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFFF8F8F8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.kitchen_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vorrat',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lade Daten...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  /// Tages-Tipp-Karte
  Widget buildDailyTipCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFFF8F8F8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 232, 245, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: Color.fromARGB(255, 26, 169, 48),
                size: 22,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Täglicher Tipp',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    randomTip,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  /// Wochenplan-Karte
  Widget buildMealPlanCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFFF8F8F8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFFD32F2F),
                size: 22,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wochenplan erstellen',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Plane deine Mahlzeiten für die Woche",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _showComingSoonDialog('Wochenplanung');
              },
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bestimmt die Farbe des Kühlschrank-Status basierend auf ablaufenden/abgelaufenen Artikeln
  Color _getFridgeStatusColor(int expiringItems, int expiredItems) {
    if (expiredItems > 0) return Colors.red;
    if (expiringItems > 0) return Colors.orange;
    if (expiringItems == 0 && expiredItems == 0)
      return Color.fromARGB(255, 26, 169, 48);
    return Colors.grey;
  }

  /// Zeigt einen "Coming Soon" Dialog für noch nicht implementierte Features
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bald verfügbar'),
        content: Text(
          '$feature wird in einer zukünftigen Version verfügbar sein!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
