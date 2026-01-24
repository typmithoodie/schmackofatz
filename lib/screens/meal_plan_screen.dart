import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons/lucide_icons.dart';

/// ─────────────────────────────────────────
/// MODELS
/// ─────────────────────────────────────────

/// Einfaches Rezept-Modell (später leicht erweiterbar)
class Recipe {
  final String id;
  final String title;
  final int minutes;
  final int portions;

  Recipe({
    required this.id,
    required this.title,
    required this.minutes,
    required this.portions,
  });
}

/// Mahlzeiten-Typen pro Tag
enum MealType { breakfast, lunch, dinner }

/// ─────────────────────────────────────────
/// DATE HELPERS
/// ─────────────────────────────────────────

/// Berechnet den Montag der aktuellen Woche
/// → wichtig für dynamische Wochen-Navigation
DateTime startOfWeek(DateTime date) {
  final weekday = date.weekday; // Montag = 1
  return date.subtract(Duration(days: weekday - 1));
}

/// ─────────────────────────────────────────
/// WEEKLY PLAN SCREEN
/// ─────────────────────────────────────────

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  /// Startdatum der aktuell angezeigten Woche
  late DateTime _weekStart;

  /// Zentrale State-Struktur:
  /// Datum → Mahlzeit → Rezept
  ///
  /// Beispiel:
  /// 2026-03-13 → breakfast → Pasta
  final Map<DateTime, Map<MealType, Recipe?>> _mealPlans = {};

  /// Mock-Rezepte (später aus DB / API)
  final List<Recipe> _recipes = [
    Recipe(id: '1', title: 'Cremige Tomaten-Pasta', minutes: 25, portions: 4),
    Recipe(id: '2', title: 'Gemüse-Pfanne', minutes: 35, portions: 2),
    Recipe(id: '3', title: 'Käse-Omelett', minutes: 10, portions: 1),
    Recipe(id: '4', title: 'Apfel-Zimt-Porridge', minutes: 15, portions: 2),
  ];

  @override
  void initState() {
    super.initState();

    /// Wichtig für deutsche Datumsformate
    initializeDateFormatting('de_DE', null);

    /// Initiale Woche = aktuelle Woche
    _weekStart = startOfWeek(DateTime.now());
  }

  /// Woche vor/zurück navigieren
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  void _previousWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  /// Erzeugt 7 Tage basierend auf _weekStart
  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  /// Holt ein Rezept für einen Slot
  Recipe? _getRecipe(DateTime day, MealType type) {
    final key = DateUtils.dateOnly(day);
    return _mealPlans[key]?[type];
  }

  /// Setzt ein Rezept in einen Slot
  void _setRecipe(DateTime day, MealType type, Recipe recipe) {
    final key = DateUtils.dateOnly(day);
    _mealPlans.putIfAbsent(key, () => {});
    setState(() => _mealPlans[key]![type] = recipe);
  }

  /// Löscht ein Rezept aus einem Slot
  void _removeRecipe(DateTime day, MealType type) {
    final key = DateUtils.dateOnly(day);
    setState(() => _mealPlans[key]?.remove(type));
  }

  /// ─────────────────────────────────────────
  /// UI
  /// ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Keine BottomNav → Screen ist isoliert nutzbar
      appBar: AppBar(
        title: Text('Wochenplan', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeekHeader(),

            /// Baut automatisch alle 7 Tage
            ..._weekDays.map(_buildDayCard),
          ],
        ),
      ),
    );
  }

  /// Kopfzeile mit Datumsbereich + Pfeile
  Widget _buildWeekHeader() {
    final formatter = intl.DateFormat('dd. MMM', 'de_DE');
    final end = _weekStart.add(const Duration(days: 6));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: _previousWeek,
        ),
        Text(
          '${formatter.format(_weekStart)} – ${formatter.format(end)}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        IconButton(icon: Icon(Icons.chevron_right), onPressed: _nextWeek),
      ],
    );
  }

  /// Einzelner Tag (Freitag 13.3.)
  Widget _buildDayCard(DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dayName = intl.DateFormat.EEEE('de_DE').format(date);
    final dateLabel = intl.DateFormat('dd.MM').format(date);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        /// Hervorhebung für Heute
        border: isToday ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dayName $dateLabel',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),

          /// Drei Slots nebeneinander
          Row(
            children: [
              _mealSlot(
                date,
                MealType.breakfast,
                'Frühstück',
                Colors.orange,
                LucideIcons.sun,
              ),
              _mealSlot(
                date,
                MealType.lunch,
                'Mittagessen',
                Colors.green,
                LucideIcons.sunset,
              ),
              _mealSlot(
                date,
                MealType.dinner,
                'Abendessen',
                Colors.indigo,
                LucideIcons.moon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Einzelner Mahlzeiten-Slot
  Widget _mealSlot(
    DateTime day,
    MealType type,
    String label,
    Color color,
    IconData icon,
  ) {
    final recipe = _getRecipe(day, type);
    bool _showDelete = false;

    return Expanded(
      child: Column(
        children: [
          /// Slot-Label (Frühstück etc.)
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                SizedBox(width: 4),
                Text(label, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(height: 6),

          /// LEERER SLOT → öffnet Rezeptauswahl
          if (recipe == null)
            GestureDetector(
              onTap: () => _openRecipePicker(day, type),
              child: Container(
                height: 52,
                width: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.add, color: Colors.grey.shade400),
                ),
              ),
            )
          /// BELEGTER SLOT → zeigt Rezept + Löschen
          else
            StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDelete = !_showDelete;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    height: 52,
                    width: 95,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              maxLines: 2,
                              style: GoogleFonts.poppins(fontSize: 9),
                            ),
                            Text(
                              '${recipe.minutes} Min',
                              style: TextStyle(fontSize: 9),
                            ),
                          ],
                        ),

                        if (_showDelete)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _removeRecipe(day, type);
                                setState(() => _showDelete = false);
                              },
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.red[800],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// BottomSheet zur Rezeptauswahl
  void _openRecipePicker(DateTime day, MealType type) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rezept auswählen',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),

            /// Rezeptliste
            ..._recipes.map(
              (recipe) => ListTile(
                leading: Icon(Icons.restaurant),
                title: Text(recipe.title),
                subtitle: Text(
                  '${recipe.minutes} Min • ${recipe.portions} Portionen',
                ),
                onTap: () {
                  _setRecipe(day, type, recipe);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
