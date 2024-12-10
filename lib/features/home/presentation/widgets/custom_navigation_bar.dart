import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
      style: TabStyle.reactCircle, // React-style animations
      backgroundColor: Colors.white,
      activeColor: AppTheme.primaryColor,
      color: const Color(0xFF2C2C2C),
      initialActiveIndex: selectedIndex,
      items: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.bar_chart, title: 'Charts'),
        TabItem(icon: Icons.add, title: 'Add'),
        TabItem(icon: Icons.all_out_rounded, title: 'FinlyticsAI'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
      onTap: onItemTapped,
    );
  }
}
