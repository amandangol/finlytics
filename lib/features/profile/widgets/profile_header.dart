import 'package:flutter/material.dart';

import '../../../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onImageTap;
  final VoidCallback? onUsernameTap;
  final Color? backgroundGradientStart;
  final Color? backgroundGradientEnd;
  final double expandedHeight;
  final bool isEditable;

  const ProfileHeader({
    Key? key,
    required this.user,
    this.onImageTap,
    this.onUsernameTap,
    this.backgroundGradientStart,
    this.backgroundGradientEnd,
    this.expandedHeight = 280.0,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade600, // Top color
                Colors.blue.shade900, // Bottom color
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileAvatar(
                  imageUrl: user.profileImageUrl,
                  onTap: isEditable ? onImageTap : null,
                  isEditable: isEditable,
                ),
                const SizedBox(height: 16),
                _ProfileUserInfo(
                  username: user.username,
                  email: user.email,
                  onUsernameTap: isEditable ? onUsernameTap : null,
                  isEditable: isEditable,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isEditable;
  final double radius;
  final Color? backgroundColor;

  const _ProfileAvatar({
    this.imageUrl,
    this.onTap,
    this.isEditable = true,
    this.radius = 70,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.3),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        if (isEditable && onTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: _EditIconButton(onPressed: onTap!),
          ),
      ],
    );
  }
}

class _EditIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const _EditIconButton({
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.edit,
          color: iconColor ?? const Color(0xFFFF6B6B),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ProfileUserInfo extends StatelessWidget {
  final String username;
  final String email;
  final VoidCallback? onUsernameTap;
  final bool isEditable;
  final TextStyle? usernameStyle;
  final TextStyle? emailStyle;

  const _ProfileUserInfo({
    required this.username,
    required this.email,
    this.onUsernameTap,
    this.isEditable = true,
    this.usernameStyle,
    this.emailStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              username,
              style: usernameStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (isEditable && onUsernameTap != null)
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: onUsernameTap,
              ),
          ],
        ),
        Text(
          email,
          style: emailStyle ??
              const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}