import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schmackofatz/screens/auth/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'answer_option.dart';
import 'onboarding_question.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int currentPage = 0;

  final Map<int, String> answers = {};

  final questions = [
    {
      "title": "Wie oft kochst du selbst?",
      "subtitle": "Die Rezepte werden an dich angepasst",
      "cardTitle": "Personalisierte Rezepte",
      "cardText":
          "schmackofatz erstellt für Dich personalisierte Rezeptvorschläge.",
      "cardIcon": LucideIcons.chefHat,
      "options": [
        AnswerOption(
          id: "daily",
          title: "Täglich",
          subtitle: "Kochen ist meine Leidenschaft",
          icon: Icons.favorite_outline,
        ),
        AnswerOption(
          id: "often",
          title: "3-5x pro Woche",
          subtitle: "Regelmäßig",
          icon: Icons.schedule_outlined,
        ),
        AnswerOption(
          id: "rare",
          title: "Selten",
          subtitle: "Wenn es die Zeit erlaubt",
          icon: LucideIcons.users2,
        ),
        AnswerOption(
          id: "never",
          title: "Nie",
          subtitle: "Ich liebe es, Essen zu bestellen",
          icon: Icons.fastfood_outlined,
        ),
      ],
    },
    {
      "title": "Wirfst du oft Lebensmittel weg?",
      "subtitle": "Ehrlich sein – wir helfen dir",
      "cardTitle": "Ablaufdaten im Blick",
      "cardText":
          "schmackofatz erinnert Dich rechtzeitig, bevor die Lebensmittel schlecht werden.",
      "cardIcon": LucideIcons.calendarDays,
      "options": [
        AnswerOption(
          id: "nothing",
          title: "Fast nichts wegwerfen",
          subtitle: "Ich plane sehr gut",
          icon: LucideIcons.leaf,
        ),
        AnswerOption(
          id: "sometimes",
          title: "Manchmal etwas",
          subtitle: "Ab und zu vergesse ich was",
          icon: LucideIcons.trash2,
        ),
        AnswerOption(
          id: "often",
          title: "Leider öfter",
          subtitle: "Das möchte ich ändern",
          icon: Icons.schedule_outlined,
        ),
        AnswerOption(
          id: "much",
          title: "Zu viel",
          subtitle: "Hier brauche ich dringend Hilfe",
          icon: LucideIcons.trendingDown,
        ),
      ],
    },
    {
      "title": "Wie planst du Einkäufe?",
      "subtitle": "Gemeinsam optimieren wir deinen Einkauf",
      "cardTitle": "Smarte Einkaufsplanung",
      "cardText":
          "schmackofatz erstellt für Dich automatisch Einkaufslisten aus Rezepten.",
      "cardIcon": LucideIcons.shoppingBag,
      "options": [
        AnswerOption(
          id: "list",
          title: "Mit einer Liste",
          subtitle: "Ich plane alles vorher",
          icon: LucideIcons.clipboardList,
        ),
        AnswerOption(
          id: "spontaneous",
          title: "Spontan",
          subtitle: "Ich entscheide im Laden",
          icon: LucideIcons.shoppingBag,
        ),
        AnswerOption(
          id: "mixed",
          title: "Unterschiedlich",
          subtitle: "Mal spontan - mal mit einer Liste",
          icon: LucideIcons.shoppingCart,
        ),
        AnswerOption(
          id: "online",
          title: "Online",
          subtitle: "Ich bestelle online",
          icon: LucideIcons.monitorSmartphone,
        ),
      ],
    },
    {
      "title": "Woher holst du Ideen für Rezepte?",
      "subtitle": "Wir bringen frischen Wind in deine Küche",
      "cardTitle": "Neue Geschmackserlebnisse",
      "cardText":
          "schmackofatz schlägt dir basierend auf deinen Vorräten passende Rezepte vor.",
      "cardIcon": LucideIcons.sparkles,
      "options": [
        AnswerOption(
          id: "internet",
          title: "Internet",
          subtitle: "YouTube, Blogs, Social Media",
          icon: LucideIcons.globe,
        ),
        AnswerOption(
          id: "books",
          title: "Kochbücher",
          subtitle: "neue Kochbücher",
          icon: LucideIcons.book,
        ),
        AnswerOption(
          id: "family",
          title: "Familie",
          subtitle: "Überlieferte Rezepte",
          icon: LucideIcons.users2,
        ),
        AnswerOption(
          id: "improvising",
          title: "Improvisieren",
          subtitle: "Was im Kühlschrank ist",
          icon: LucideIcons.chefHat,
        ),
      ],
    },
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              Row(
                children: [
                  Text(
                    "Frage ${currentPage + 1} von $total",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: finishOnboarding,
                    child: Text(
                      "Überspringen",
                      style: TextStyle(color: Color.fromARGB(255, 26, 169, 48)),
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: (currentPage + 1) / total,
                color: Color.fromARGB(255, 26, 169, 48),
                backgroundColor: Colors.grey.shade200,
              ),
              SizedBox(height: 24),

              Expanded(
                child: PageView.builder(
                  controller: controller,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return OnboardingQuestion(
                      title: q["title"] as String,
                      subtitle: q["subtitle"] as String,
                      cardTitle: q["cardTitle"] as String,
                      cardText: q["cardText"] as String,
                      cardIcon: q["cardIcon"] as IconData,
                      options: q["options"] as List<AnswerOption>,
                      selectedId: answers[index],
                      onSelect: (value) {
                        setState(() {
                          answers[index] = value;
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 24),
              Row(
                children: [
                  if (currentPage > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 26, 169, 48),
                        side: BorderSide(
                          color: Color.fromARGB(255, 26, 169, 48),
                          width: 2,
                        ),
                      ),
                      onPressed: () {
                        setState(() => currentPage--);
                        controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Text(
                        "Zurück",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 26, 169, 48),
                    ),
                    onPressed: answers[currentPage] == null
                        ? null
                        : () {
                            if (currentPage == total - 1) {
                              finishOnboarding();
                            } else {
                              setState(() => currentPage++);
                              controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                    child: Text(
                      "Weiter",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
