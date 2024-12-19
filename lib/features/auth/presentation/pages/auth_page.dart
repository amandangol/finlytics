import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'signin_page.dart.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool? isLoggedIn;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAuthFlag();
  }

  Future<void> _getAuthFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      isLoading = false;
    });
  }

  Future<void> _resetAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (isLoading) {
            return const Center(
              child: SpinKitThreeBounce(
                color: AppTheme.primaryDarkColor,
                size: 20.0,
              ),
            );
          }

          // Check for authentication errors
          if (snapshot.hasError) {
            print('Auth Stream Error: ${snapshot.error}');
            _resetAuthState();
            return const SigninPage();
          }

          // User logged in
          if (snapshot.hasData && isLoggedIn == true) {
            return const HomePage();
          }

          // User not logged in
          return const SigninPage();
        },
      ),
    );
  }
}
