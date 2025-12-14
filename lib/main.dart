import 'package:flutter/material.dart';
import 'package:schmackofatz/screens/analysis_screen.dart';
import 'package:schmackofatz/screens/fridge_screen.dart';
import 'package:schmackofatz/screens/home_screen.dart';
import 'package:schmackofatz/screens/recipes_screen.dart';
import 'package:schmackofatz/screens/shopping_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigatorPage(),
    );
  }
}

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

int currentIndex = 0;
PageController pageController = PageController(initialPage: 0);

class _NavigatorPageState extends State<NavigatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: <Widget>[
          HomeScreen(),
          FridgeScreen(),
          RecipeScreen(),
          ShoppingScreen(),
          AnalysisScreen(),
        ],
        onPageChanged: (newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Color.fromARGB(255, 26, 169, 48),
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedFontSize: 14,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
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
          pageController.animateToPage(
            newIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
