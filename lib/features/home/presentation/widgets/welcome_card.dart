import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../models.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeCard extends StatelessWidget {
  final UserModel userModel;
  final double totalIncome;
  final double totalExpense;
  final bool isDarkMode;
  final VoidCallback? onToggleDarkMode;

  const WelcomeCard({
    Key? key,
    required this.userModel,
    required this.totalIncome,
    required this.totalExpense,
    this.isDarkMode = false,
    this.onToggleDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Replaced CustomScrollView with SingleChildScrollView
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.darkTheme.cardColor.withOpacity(0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Username
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userModel.username.isNotEmpty
                            ? '${userModel.username}!'
                            : 'User!',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person_outline,
                      color:
                          isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                      size: 35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Financial Insights
              Text(
                _getInsightText(),
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms),
    );
  }

  Widget _buildFinancialStat(String label, double amount, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getInsightText() {
    double netIncome = totalIncome - totalExpense;
    if (netIncome > 0) {
      return 'Great job! You\'re saving more than you spend.';
    } else if (netIncome == 0) {
      return 'Breaking even. Keep tracking your expenses.';
    } else {
      return 'Looks like expenses are higher. Time to review your budget.';
    }
  }
}
