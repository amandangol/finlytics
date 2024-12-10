import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/pages/signin_page.dart.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'icon': LucideIcons.pieChart,
      'title': 'Comprehensive Financial Overview',
      'description':
          'Get a holistic view of your financial health with detailed tracking of expenses and incomes across all your accounts.',
    },
    {
      'icon': LucideIcons.wallet,
      'title': 'Effortless Expense Tracking',
      'description':
          'Quickly add and categorize your expenses and income with just a few taps. Stay on top of your financial transactions in real-time.',
    },
    {
      'icon': LucideIcons.barChart3,
      'title': 'Insightful Data Visualization',
      'description':
          'Transform your financial data into easy-to-understand charts and graphs. Identify spending patterns and make informed financial decisions.',
    },
    {
      'icon': LucideIcons.dollarSign,
      'title': 'Multi-Currency Support',
      'description':
          'View and manage your finances in your preferred currency. Seamless currency conversion and formatting for global financial tracking.',
    },
    {
      'icon': LucideIcons.bot,
      'title': 'Finlytics AI Assistant',
      'description':
          'Leverage AI-powered insights powered by Gemini. Get personalized financial advice, budget recommendations, and smart money management tips.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                icon: onboardingPages[index]['icon'],
                title: onboardingPages[index]['title']!,
                description: onboardingPages[index]['description']!,
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingPages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == onboardingPages.length - 1) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('first_time', false);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SigninPage(),
                        ),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_currentPage == onboardingPages.length - 1
                      ? 'Get Started'
                      : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
