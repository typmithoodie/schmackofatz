import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schmackofatz/services/integration_service.dart';
import 'package:schmackofatz/services/fridge_service.dart';
import 'package:schmackofatz/services/recipe_service.dart';
import 'package:schmackofatz/theme/appcolors.dart';
import 'package:schmackofatz/models/recipe.dart';
import 'package:schmackofatz/models/fridge_item.dart';

/// Service-Klasse für Analyse-Berechnungen
class AnalysisLogic {
  static final AnalysisLogic _instance = AnalysisLogic._internal();
  factory AnalysisLogic() => _instance;
  AnalysisLogic._internal();

  /// Berechnet den Nachhaltigkeitsscore (0-100)
  Future<int> calculateSustainabilityScore() async {
    try {
      final fridgeService = FridgeService();
      final stats = await fridgeService.getStatistics();

      final totalItems = stats['totalItems'] as int;
      final expiringItems = stats['expiringItems'] as int;
      final expiredItems = stats['expiredItems'] as int;

      if (totalItems == 0) return 75; // Default score for empty fridge

      // Fresh items contribution (40%)
      final freshRatio =
          (totalItems - expiringItems - expiredItems) / totalItems;
      final freshScore = freshRatio * 40;

      // Low waste contribution (30%) - penalize expired items
      final wasteRatio = expiredItems / totalItems;
      final wasteScore = (1 - wasteRatio.clamp(0.0, 1.0)) * 30;

      // Stock management contribution (30%) - penalize expiring items
      final expiringRatio = expiringItems / totalItems;
      final stockScore = (1 - expiringRatio.clamp(0.0, 1.0)) * 30;

      return (freshScore + wasteScore + stockScore).round().clamp(0, 100);
    } catch (e) {
      return 75; // Default score on error
    }
  }

  /// Berechnet die geschätzten Ersparnisse (in Euro)
  Future<double> calculateSavings() async {
    try {
      final integrationService = IntegrationService();
      final status = await integrationService.getSystemStatus();

      final cookableRecipes = status['cookableRecipes'] as int;
      final expiringItems = status['expiringItems'] as int;

      // Annahmen:
      // - Jedes kochbare Rezept spart durchschnittlich €8 gegenüber Fertiggerichten
      // - Jeder gerettete expierende Artikel spart durchschnittlich €3
      final cookingSavings = cookableRecipes * 8.0;
      final wasteSavings = expiringItems * 3.0;

      return cookingSavings + wasteSavings;
    } catch (e) {
      return 0;
    }
  }

  /// Gibt Tipps zur Verbesserung des Nachhaltigkeitsscores
  List<String> getSustainabilityTips(int score) {
    final tips = <String>[];

    if (score < 50) {
      tips.add('⚠️ Prüfen Sie Ihre ablaufenden Artikel bald!');
      tips.add('💡 Kochen Sie öfter mit vorhandenen Zutaten.');
    } else if (score < 75) {
      tips.add('✨ Gute Arbeit! Versuchen Sie, weniger zu verschwenden.');
      tips.add('🛒 Planen Sie Ihre Einkäufe besser im Voraus.');
    } else {
      tips.add('🌟 Ausgezeichnet! Sie sind sehr nachhaltig!');
      tips.add('🥗 Teilen Sie Ihre Tipps mit Freunden.');
    }

    return tips;
  }

  /// Kategorisiert Items nach Ablaufstatus
  Future<Map<String, int>> getExpirationStats() async {
    final fridgeService = FridgeService();
    final items = await fridgeService.getAllItems();

    int fresh = 0, soon = 0, urgent = 0, expired = 0;

    for (final item in items) {
      switch (item.expirationStatus) {
        case ExpirationStatus.fresh:
          fresh++;
          break;
        case ExpirationStatus.soon:
          soon++;
          break;
        case ExpirationStatus.urgent:
          urgent++;
          break;
        case ExpirationStatus.expired:
          expired++;
          break;
      }
    }

    return {'fresh': fresh, 'soon': soon, 'urgent': urgent, 'expired': expired};
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisLogic _analysisLogic = AnalysisLogic();
  final IntegrationService _integrationService = IntegrationService();
  final FridgeService _fridgeService = FridgeService();
  final RecipeService _recipeService = RecipeService();

  bool _isLoading = true;
  Map<String, dynamic>? _systemStatus;
  int _sustainabilityScore = 0;
  double _savings = 0;
  List<Recipe> _cookableRecipes = [];
  List<Recipe> _recommendations = [];
  Map<String, int>? _expirationStats;
  List<String> _tips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final status = await _integrationService.getSystemStatus();
      final score = await _analysisLogic.calculateSustainabilityScore();
      final savings = await _analysisLogic.calculateSavings();
      final recipes = await _integrationService.getCookableRecipes();
      final fridgeItems = await _fridgeService.getAllItems();
      final availableIngredients = fridgeItems.map((e) => e.name).toList();
      final recommendations = await _recipeService.getRecommendations(
        availableIngredients,
      );
      final stats = await _analysisLogic.getExpirationStats();
      final tips = _analysisLogic.getSustainabilityTips(score);

      setState(() {
        _systemStatus = status;
        _sustainabilityScore = score;
        _savings = savings;
        _cookableRecipes = recipes;
        _recommendations = recommendations.take(3).toList();
        _expirationStats = stats;
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.green,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Lade Analyse...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.green,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildOverviewCards(),
            _buildSustainabilitySection(),
            _buildSavingsSection(),
            _buildRecipeInsights(),
            _buildExpirationAnalysis(),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Image.asset(
            'lib/images/schmackofatz_logo.png',
            height: 28,
            width: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analyse',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalItems = _systemStatus?['fridgeItems'] ?? 0;
    final expiringItems = _systemStatus?['expiringItems'] ?? 0;
    final cookableRecipes = _systemStatus?['cookableRecipes'] ?? 0;
    final shoppingItems = _systemStatus?['shoppingItems'] ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.refrigerator,
                  value: totalItems.toString(),
                  label: 'Kühlschrank',
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.clock,
                  value: expiringItems.toString(),
                  label: 'Läuft ab',
                  color: expiringItems > 2 ? Colors.orange : AppColors.green,
                  warning: expiringItems > 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.chefHat,
                  value: cookableRecipes.toString(),
                  label: 'Kochbar',
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.shoppingCart,
                  value: shoppingItems.toString(),
                  label: 'Einkauf',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool warning = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: warning ? Border.all(color: Colors.orange, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: warning ? Colors.orange : AppColors.textDark,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSustainabilitySection() {
    final scoreColor = _sustainabilityScore >= 70
        ? AppColors.green
        : _sustainabilityScore >= 40
        ? Colors.orange
        : Colors.red;

    return _buildSection(
      title: 'Nachhaltigkeits-Score',
      icon: LucideIcons.leaf,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _sustainabilityScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_sustainabilityScore%',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    _getScoreLabel(_sustainabilityScore),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreBreakdown(),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Ausgezeichnet';
    if (score >= 60) return 'Gut';
    if (score >= 40) return 'Verbesserungsfähig';
    return 'Handlungsbedarf';
  }

  Widget _buildScoreBreakdown() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreItem('Frische Artikel', 40),
          SizedBox(height: 10),
          _buildScoreItem('Abfallvermeidung', 30),
          SizedBox(height: 10),
          _buildScoreItem('Bestandsmanagement', 30),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int maxPoints) {
    final currentScore = (maxPoints * _sustainabilityScore / 100).round();
    final percentage = currentScore / maxPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$currentScore/$maxPoints',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsSection() {
    return _buildSection(
      title: 'Ersparnisse',
      icon: LucideIcons.piggyBank,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.green, AppColors.green.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.trendingUp,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_savings.toStringAsFixed(0)}€',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'gespart durch das Kochen!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildRecipeInsights() {
    return _buildSection(
      title: 'Rezept-Empfehlungen',
      icon: LucideIcons.sparkles,
      child: Column(
        children: [
          if (_cookableRecipes.isEmpty)
            _buildEmptyState(
              'Keine kochbaren Rezepte',
              'Füge Zutaten hinzu, um Rezepte zu sehen',
            )
          else ...[
            ..._cookableRecipes
                .take(3)
                .map((recipe) => _buildRecipeCard(recipe)),
            if (_recommendations.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildRecommendationSection(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final coverage = recipe.getCompletionPercentage(
      _systemStatus?['availableIngredients']
              ?.map<String>((e) => e.toLowerCase())
              .toList() ??
          [],
    );

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.utensilsCrossed,
                size: 24,
                color: AppColors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime} min',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        LucideIcons.users,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${recipe.servings} Pers.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: coverage / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            coverage >= 70 ? AppColors.green : Colors.orange,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${coverage.round()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: coverage >= 70
                                  ? AppColors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Tipp für heute',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_recommendations.isNotEmpty)
            Text(
              'Probieren Sie "${_recommendations.first.name}" mit Ihren vorhandenen Zutaten!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue.shade600,
              ),
            )
          else
            Text(
              'Fügen Sie mehr Zutaten hinzu, um personalisierte Empfehlungen zu erhalten.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpirationAnalysis() {
    final stats = _expirationStats;
    if (stats == null) return const SizedBox.shrink();

    return _buildSection(
      title: 'Ablauf-Analyse',
      icon: LucideIcons.calendarClock,
      child: Row(
        children: [
          _buildExpirationItem('Frisch', stats['fresh'] ?? 0, AppColors.green),
          SizedBox(width: 10),
          _buildExpirationItem('Bald', stats['soon'] ?? 0, Colors.amber),
          SizedBox(width: 10),
          _buildExpirationItem('Dringend', stats['urgent'] ?? 0, Colors.orange),
          SizedBox(width: 10),
          _buildExpirationItem('Abgelaufen', stats['expired'] ?? 0, Colors.red),
        ],
      ),
    );
  }

  Widget _buildExpirationItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    if (_tips.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Verbesserungstipps',
      icon: LucideIcons.lightbulb,
      child: Column(
        children: _tips
            .map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
