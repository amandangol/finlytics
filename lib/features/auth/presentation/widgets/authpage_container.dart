import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthPageContainer extends StatelessWidget {
  final Widget child;
  final String pageTitle;

  const AuthPageContainer({
    Key? key,
    required this.child,
    required this.pageTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4CAF50), // Green for financial health
                  Color(0xFF0D47A1), // Blue for trustworthiness
                ],
              ),
            ),
          ),

          // Circular Decorations for Depth
          Positioned(
            top: -80,
            right: -60,
            child: CircleAvatar(
              radius: 140,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: CircleAvatar(
              radius: 160,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),

          // Content Centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/images/finlogo.png",
                    height: 60,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fade(duration: 300.ms)
                    .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),

                const SizedBox(height: 24),

                // App Title
                Text(
                  pageTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: 'Roboto',
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Track your expenses, save smarter!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontFamily: 'OpenSans',
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Login Form (Glassmorphism Card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(3, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }
}
