import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'answer_option.dart';

class OnboardingQuestion extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AnswerOption> options;
  final String? selectedId;
  final void Function(String) onSelect;
  final String cardTitle;
  final String cardText;
  final IconData cardIcon;

  const OnboardingQuestion({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedId,
    required this.onSelect,
    required this.cardTitle,
    required this.cardText,
    required this.cardIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 16),

        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = option.id == selectedId;

              return GestureDetector(
                onTap: () => onSelect(option.id),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? Color.fromARGB(255, 26, 169, 48)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: selected
                                ? Colors.green
                                : Colors.grey.shade200,
                            child: Icon(
                              option.icon,
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                          Spacer(),
                          if (selected)
                            Icon(
                              Icons.check,
                              color: Color.fromARGB(255, 26, 169, 48),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        option.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        option.subtitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Small info card under answer options
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cardIcon, color: Colors.blue.shade600, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cardTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(),
                child: Text(
                  cardText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
