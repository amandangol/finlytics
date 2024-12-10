import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models.dart';
import '../../../../screens/setting_screen.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? userModel;
  final User? user;
  final String? title;

  const CustomHomeAppBar({super.key, this.userModel, this.user, this.title});

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      title: Row(
        children: [
          Text(
            title!,
            style: TextStyle(
              color: isDarkMode ? Colors.orangeAccent : const Color(0xFFEF6C06),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: isDarkMode
                ? Colors.orangeAccent.withOpacity(0.1)
                : const Color(0xFFEF6C06).withOpacity(0.1),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ));
              },
              child: Icon(
                Icons.settings,
                color:
                    isDarkMode ? Colors.orangeAccent : const Color(0xFFEF6C06),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
