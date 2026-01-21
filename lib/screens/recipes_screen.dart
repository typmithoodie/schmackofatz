import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Einfaches Recipe Modell
class Recipe {
  final String id;
  String name;
  String description;

  Recipe({required this.id, required this.name, required this.description});
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    // Lade einfache Beispiel-Rezepte
    _recipes = [
      Recipe(
        id: '1',
        name: 'Spaghetti Bolognese',
        description: 'Klassisches italienisches Gericht',
      ),
      Recipe(
        id: '2',
        name: 'Frühstücks Smoothie',
        description: 'Gesunder Smoothie zum Start in den Tag',
      ),
      Recipe(
        id: '3',
        name: 'Griechischer Salat',
        description: 'Frischer mediterraner Salat',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Rezepte",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        recipe.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        recipe.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        _showRecipeDetail(recipe);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetail(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.name),
        content: Text(recipe.description),
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
