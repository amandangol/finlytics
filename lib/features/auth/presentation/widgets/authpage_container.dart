import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthPageContainer extends StatelessWidget {
  final Widget child;
  final String pageTitle;

  const AuthPageContainer({
    super.key,
    required this.child,
    required this.pageTitle,
  });

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
                  Color(0xFF4CAF50),
                  Color(0xFF0D47A1),
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
                Image.asset(
                  "assets/images/finlylogo.png",
                  height: 150,
                ).animate().fade(duration: 300.ms).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                const SizedBox(height: 16),

                // App Title
                Text(
                  pageTitle,
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
