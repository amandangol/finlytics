import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xE8FFFFFF),
      selectedItemColor: const Color(0xFFEF6C06),
      unselectedItemColor: const Color(0xFF2C2C2C),
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.home),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.bar_chart),
          ),
          label: 'Charts',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Icon(Icons.all_inclusive_outlined),
          ),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Icon(Icons.person),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
