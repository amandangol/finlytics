import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/auth/presentation/pages/auth.dart';
import 'package:expense_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_signup_page.dart';
import 'package:expense_tracker/screens/privacy_policy_page.dart';
import 'package:expense_tracker/screens/terms_conditions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/provider/theme_provider.dart';
import 'firebase_options.dart';

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
          title: 'TrackUrSpends',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthPage(),
          routes: {
            '/login': (context) => const LoginSignupPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/terms-conditions': (context) => TermsConditionsPage(),
            '/privacy-policy': (context) => PrivacyPolicyPage(),
          },
        );
      }),
    );
  }
}
