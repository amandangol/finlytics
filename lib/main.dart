import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/provider/currency_provider.dart';
import 'core/provider/theme_provider.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/signin_page.dart.dart';
import 'features/gemini_chat_ai/services/chatprovider.dart';
import 'features/intro/splash/splash_page.dart';
import 'firebase_options.dart';
import 'screens/privacy_policy_page.dart';
import 'screens/terms_conditions_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setLanguageCode(Platform.localeName.split('_')[0]);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, theme, child) {
        return MaterialApp(
          title: 'Finlytics',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: theme.themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const SigninPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/terms-of-services': (context) => TermsOfServicePage(),
            '/privacy-policy': (context) => PrivacyPolicyPage(),
          },
        );
      }),
    );
  }
}
