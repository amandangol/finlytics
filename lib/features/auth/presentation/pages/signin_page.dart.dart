import 'dart:io';

import 'package:finlytics/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/error_utils.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/authpage_container.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isPasswordObscured = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isFirstLogin = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAuth();

    // Set Firebase Auth locale if required
    FirebaseAuth.instance.setLanguageCode('en');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    // Set language code
    await FirebaseAuth.instance
        .setLanguageCode(Platform.localeName.split('_')[0]);

    // Check if this is first login
    final prefs = await SharedPreferences.getInstance();
    _isFirstLogin = !(prefs.getBool('hasLoggedInBefore') ?? false);
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ErrorUtils.showSnackBar(
        context: context,
        message: 'Please enter email and password',
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          ErrorUtils.showSnackBar(
            context: context,
            message: 'Please verify your email',
            color: AppTheme.errorColor,
            icon: Icons.error_outline,
          );
          setState(() => _isLoading = false);
          return;
        }

        // Set login state and first login flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('hasLoggedInBefore', true);

        // Navigate to auth page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Special handling for first-time login errors
      if (_isFirstLogin && e.code == 'invalid-credential') {
        // Wait briefly and retry authentication
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final retryCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (retryCredential.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setBool('hasLoggedInBefore', true);

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            }
            return;
          }
        } catch (retryError) {
          _handleLoginError(e);
        }
      } else {
        _handleLoginError(e);
      }
    } catch (e) {
      ErrorUtils.showSnackBar(
        context: context,
        message: 'An unexpected error occurred. Please try again.',
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLoginError(FirebaseAuthException e) {
    print('Firebase Auth Error Code: ${e.code}');
    print('Firebase Auth Error Message: ${e.message}');

    String errorMessage;
    switch (e.code) {
      case 'invalid-credential':
        errorMessage = _isFirstLogin
            ? 'First-time login in progress. Please try again.'
            : 'The email or password is incorrect. Please try again.';
        break;
      case 'user-not-found':
        errorMessage = 'No user found with this email. Please sign up.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again.';
        break;
      default:
        errorMessage = 'An error occurred. Please try again.';
    }

    ErrorUtils.showSnackBar(
      context: context,
      message: errorMessage,
      color: AppTheme.errorColor,
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageContainer(
      pageTitle: 'Welcome Back',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _isPasswordObscured,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: AppTheme.primaryColor,
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Remember me',
                      style: TextStyle(
                          color: AppTheme.lightTextColor, letterSpacing: 0.5)),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage()));
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: AppTheme.lightTextColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: AppTheme.elevatedButtonStyle,
            child: _isLoading
                ? const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )
                : const Text('Login'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an account?',
                style: TextStyle(
                    color: AppTheme.lightTextColor, letterSpacing: 0.5),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
