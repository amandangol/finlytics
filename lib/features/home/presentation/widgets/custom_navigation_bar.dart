import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

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
      height: 60,
      style: TabStyle.fixedCircle,
      backgroundColor: Colors.white,
      activeColor: AppTheme.primaryDarkColor,
      color: const Color(0xFF2C2C2C),
      initialActiveIndex: selectedIndex,
      items: const [
        TabItem(icon: LucideIcons.home, title: 'Home'),
        TabItem(icon: LucideIcons.barChart3, title: 'Insights'),
        TabItem(icon: LucideIcons.bookPlus, title: 'Add'),
        TabItem(icon: LucideIcons.bot, title: 'FinlyticsAI'),
        TabItem(icon: LucideIcons.settings, title: 'Settings'),
      ],
      onTap: onItemTapped,
    );
  }
}
