import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class PredefinedQueriesRow extends StatelessWidget {
  final List<String> predefinedQueries;
  final Function(String) onQuerySelected;

  const PredefinedQueriesRow({
    super.key,
    required this.predefinedQueries,
    required this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: predefinedQueries.map((query) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () => onQuerySelected(query),
              child: Text(query, style: GoogleFonts.roboto()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
