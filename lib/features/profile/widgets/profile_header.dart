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
    super.key,
    required this.user,
    this.onImageTap,
    this.onUsernameTap,
    this.backgroundGradientStart,
    this.backgroundGradientEnd,
    this.expandedHeight = 300.0, // Slightly increased for better proportions
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundGradientStart ?? Colors.indigo.shade500,
                backgroundGradientEnd ?? Colors.blue.shade700,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _ProfileAvatar(
                  imageUrl: user.profileImageUrl,
                  // onTap: isEditable ? onImageTap : null,
                  isEditable: isEditable,
                  radius: 70, // Slightly larger avatar
                ),
                const SizedBox(height: 24),
                _ProfileUserInfo(
                  username: user.username.isEmpty ? "User" : user.username,
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
    this.backgroundColor,
    this.radius = 70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Stack(
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.3),
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/images/pfp.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          // if (isEditable && onTap != null)
          //   Positioned(
          //     bottom: 0,
          //     right: 0,
          //     child: _EditIconButton(onPressed: onTap!),
          //   ),
        ],
      ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.edit,
        color: iconColor ?? Theme.of(context).primaryColor,
        size: 20,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  username,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: usernameStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                  maxLines: 1,
                ),
              ),
              if (isEditable && onUsernameTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onUsernameTap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: emailStyle ??
                TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
