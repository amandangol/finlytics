import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models.dart';

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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Finanalytics',
            style: TextStyle(
              color: const Color(0xFFEF6C06),
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
            backgroundColor: const Color(0xFFEF6C06).withOpacity(0.1),
            child: Icon(
              Icons.notifications_outlined,
              color: const Color(0xFFEF6C06),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
