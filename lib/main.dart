import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schmackofatz/screens/analysis_screen.dart';
import 'package:schmackofatz/screens/fridge_screen.dart';
import 'package:schmackofatz/screens/home_screen.dart';
import 'package:schmackofatz/screens/recipes_screen.dart';
import 'package:schmackofatz/screens/shopping_screen.dart';
import 'package:schmackofatz/start_decider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: StartDecider());
  }
}

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});
  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          HomeScreen(),
          FridgeScreen(),
          RecipeScreen(),
          ShoppingScreen(),
          AnalysisScreen(),
        ],
        onPageChanged: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Color.fromARGB(255, 26, 169, 48),
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedFontSize: 14,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Startseite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            label: 'Vorrat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Rezepte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Einkauf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Analyse',
          ),
        ],
        onTap: (newIndex) {
          _pageController.jumpToPage(newIndex);
          setState(() {
            _currentIndex = newIndex;
          });
        },
      ),
    );
  }
}
