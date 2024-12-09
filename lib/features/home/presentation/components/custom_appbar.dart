import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models.dart';
import '../../../../screens/setting_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? userModel;
  final User? user;

  const CustomAppBar({
    Key? key,
    required this.userModel,
    required this.user,
  }) : super(key: key);

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
            'Finanalytics',
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
                      builder: (context) => SettingsPage(),
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