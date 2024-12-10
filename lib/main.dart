import 'package:expense_tracker/features/intro/onboarding/presentation/onboarding_page.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/provider/theme_provider.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/signin_page.dart.dart';
import 'features/intro/splash/splash_page.dart';
import 'screens/privacy_policy_page.dart';
import 'screens/terms_conditions_page.dart'; // New import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Finlytics', // Updated app name
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(), // Change home to SplashScreen
          routes: {
            '/login': (context) => const SigninPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/terms-conditions': (context) => TermsConditionsPage(),
            '/privacy-policy': (context) => PrivacyPolicyPage(),
          },
        );
      }),
    );
  }
}
