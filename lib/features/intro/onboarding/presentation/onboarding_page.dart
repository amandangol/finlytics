import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../../auth/presentation/pages/signin_page.dart.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'icon': LucideIcons.layoutDashboard,
      'lottie': 'assets/lottie/dashboard.json',
      'title': 'Smart Dashboard',
      'subtitle': 'Your Financial Command Center',
      'description':
          'Get a complete view of your finances with our interactive dashboard. Track income, expenses, and net worth with beautiful visualizations and real-time updates.',
      'gradientColors': [Color(0xFF1A2B88), Color(0xFF2439B6)],
    },
    {
      'icon': LucideIcons.wallet,
      'lottie': 'assets/lottie/finance_tracking.json',
      'title': 'Advanced Transaction Tracking',
      'subtitle': 'Every Penny Counts',
      'description':
          'Effortlessly manage transactions across multiple accounts. Smart validation ensures accuracy while preventing overdrafts. Categorize and track every financial move.',
      'gradientColors': [Color(0xFF14532D), Color(0xFF1F7747)],
    },
    {
      'icon': LucideIcons.barChart3,
      'lottie': 'assets/lottie/charts.json',
      'title': 'Powerful Analytics',
      'subtitle': 'Data-Driven Decisions',
      'description':
          'Transform your financial data into actionable insights with advanced charts and graphs. Compare income vs expenses, track monthly trends, and understand spending patterns.',
      'gradientColors': [Color(0xFF4B255A), Color(0xFF5E3370)],
    },
    {
      'icon': LucideIcons.currency,
      'lottie': 'assets/lottie/multi_currency.json',
      'title': 'Global Currency Support',
      'subtitle': 'Borderless Finance',
      'description':
          'Seamlessly manage your money with support for multiple currency formats. View balances, transactions, and reports in the currency format that suits your needs.',
      'gradientColors': [Color(0xFF805600), Color(0xFFBF8C40)],
    },
    {
      'icon': LucideIcons.brain,
      'lottie': 'assets/lottie/lottie2.json',
      'title': 'AI Financial Assistant',
      'subtitle': 'Powered by Google Gemini',
      'description':
          'Get personalized financial advice and insights from our AI assistant. Receive spending recommendations, future expense forecasts, and smart savings suggestions.',
      'gradientColors': [Color(0xFF7A1A1A), Color(0xFFB24040)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = _currentPage == onboardingPages.length - 1;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: onboardingPages[_currentPage]['gradientColors'],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App Logo/Name
                        const Text(
                          'Finlytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Skip Button
                        if (!_isLastPage)
                          TextButton(
                            onPressed: _skipOnboarding,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: onboardingPages.length,
                      itemBuilder: (context, index) {
                        return FadeTransition(
                          opacity: _animationController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Feature Icon
                                  Icon(
                                    onboardingPages[index]['icon'],
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 24),
                                  // Lottie Animation
                                  Hero(
                                    tag: 'onboarding_${index}',
                                    child: Lottie.asset(
                                      onboardingPages[index]['lottie'],
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      repeat: true,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Title with Gradient Effect
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.white70],
                                    ).createShader(bounds),
                                    child: Text(
                                      onboardingPages[index]['title'],
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Subtitle
                                  Text(
                                    onboardingPages[index]['subtitle'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Description Card
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      onboardingPages[index]['description'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Progress Indicators and Navigation
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Progress Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingPages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: _currentPage == index
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Navigation Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isLastPage
                              ? MediaQuery.of(context).size.width * 0.8
                              : MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: _isLastPage
                                ? _completeOnboarding
                                : () => _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: onboardingPages[_currentPage]
                                  ['gradientColors'][0],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLastPage ? 'Get Started' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_isLastPage) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods remain the same...
  Future<void> _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    _navigateToSignIn();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    _navigateToSignIn();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SigninPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}
