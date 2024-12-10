import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SleekNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const SleekNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      backgroundColor: Colors.white,
      activeColor: AppTheme.primaryDarkColor,
      color: const Color(0xFF2C2C2C),
      initialActiveIndex: selectedIndex,
      items: const [
        TabItem(icon: LucideIcons.home, title: 'Home'),
        TabItem(icon: LucideIcons.barChart3, title: 'Charts'),
        TabItem(icon: LucideIcons.bookPlus, title: 'Add'),
        TabItem(icon: LucideIcons.bot, title: 'FinlyticsAI'),
        TabItem(icon: LucideIcons.settings, title: 'Settings'),
      ],
      onTap: onItemTapped,
    );
  }
}
