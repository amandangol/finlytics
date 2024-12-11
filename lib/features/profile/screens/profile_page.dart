import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/provider/currency_provider.dart';
import '../../../core/utils/error_utils.dart';
import '../../../models/user_model.dart';
import '../../auth/services/user_auth_service.dart';
import '../../auth/services/user_data_service.dart';
import '../../auth/presentation/pages/auth_page.dart';
import '../widgets/account_setting_section.dart';
import '../widgets/danger_zone_section.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late UserModel _currentUser;
  final ImagePicker _picker = ImagePicker();
  final UserAuthenticationService _authService = UserAuthenticationService();
  final UserDataService _userDataService = UserDataService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

    // Initialize animation controller for fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Slightly longer duration
      vsync: this,
    );

    // Create a fade animation with more pronounced curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // More dramatic easing
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final updatedUser = await _userDataService.updateProfileImage(
            userId: _currentUser.id, imageFile: imageFile);

        Navigator.of(context).pop();

        setState(() {
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      ErrorUtils.showSnackBar(
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
        context: context,
        message: 'Failed to update profile image: $e',
      );
    }
  }

  void _editUsername() {
    final TextEditingController usernameController =
        TextEditingController(text: _currentUser.username);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Edit Username",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Enter new username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon:
                      const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                maxLength: 30,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newUsername = usernameController.text.trim();
                        if (newUsername.isNotEmpty) {
                          try {
                            await _userDataService.updateUsername(
                              widget.user.id,
                              newUsername,
                            );

                            setState(() {
                              _currentUser.username = newUsername;
                              widget.user.username = newUsername;
                            });

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Username updated successfully',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating username: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  AlertDialog _buildCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    Color? iconColor,
    required List<Widget> actions,
    String? additionalMessage,
    Widget? customContent,
  }) {
    return AlertDialog(
      backgroundColor: DialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? DialogTheme.infoColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: iconColor ?? DialogTheme.infoColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: DialogTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (additionalMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              additionalMessage,
              style: TextStyle(
                fontSize: 14,
                color: iconColor ?? DialogTheme.warningColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 20),
            customContent,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          child: const Text("Cancel"),
        ),
        ...actions,
      ],
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to sign out"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildCustomDialog(
          context: context,
          title: "Sign Out",
          message: "Are you sure you want to sign out of Finlytics?",
          icon: Icons.exit_to_app,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DialogTheme.infoColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    String? emailErrorMessage;
    String? passwordErrorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildCustomDialog(
              context: context,
              title: "Delete Account",
              message:
                  "Are you sure you want to permanently delete your account?",
              icon: Icons.delete_forever,
              iconColor: DialogTheme.warningColor,
              additionalMessage:
                  "This will remove all your data across all devices.",
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      emailErrorMessage = null;
                      passwordErrorMessage = null;
                    });

                    if (emailController.text.isEmpty) {
                      setState(() {
                        emailErrorMessage = "Email cannot be empty.";
                      });
                    } else if (emailController.text != widget.user.email) {
                      setState(() {
                        emailErrorMessage =
                            "Incorrect email. Please try again.";
                      });
                    } else if (passwordController.text.isEmpty) {
                      setState(() {
                        passwordErrorMessage = "Password cannot be empty.";
                      });
                    } else {
                      try {
                        bool isReauthenticated =
                            await _authService.reauthenticateUser(
                          emailController.text,
                          passwordController.text,
                        );

                        if (isReauthenticated) {
                          // Delete user data first
                          await _userDataService.deleteUserData(widget.user.id);

                          // Then delete the user account
                          await _authService.deleteUserAccount();

                          // Sign out and navigate to auth page
                          _signOut(context);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "All data has been reset successfully",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.black,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ));
                        } else {
                          setState(() {
                            passwordErrorMessage =
                                "Incorrect password. Please try again.";
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error deleting account: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DialogTheme.warningColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Delete Account"),
                ),
              ],
              customContent: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Confirm Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: emailErrorMessage,
                      prefixIcon:
                          const Icon(Icons.email, color: DialogTheme.infoColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: passwordErrorMessage,
                      prefixIcon:
                          const Icon(Icons.lock, color: DialogTheme.infoColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
              parent: _animationController, curve: Curves.easeOut)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 230, 236, 241),
                  Color.fromARGB(255, 220, 239, 225),
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // Profile Header with only fade effect
                ProfileHeader(
                  user: _currentUser,
                  onImageTap: _pickAndUploadImage,
                  onUsernameTap: () => _editUsername(),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Account Settings Section
                      AccountSettingsSection(
                        onPrivacyTap: () =>
                            Navigator.of(context).pushNamed('/privacy-policy'),
                        onTermsofServicesTap: () => Navigator.of(context)
                            .pushNamed('/terms-of-services'),
                        onSignOutTap: () => _confirmSignOut(context),
                        onAboutTap: () => _showAboutBottomSheet(context),
                        onCurrencyExchangeTap: () =>
                            _showCurrencyBottomSheet(context),
                      ),

                      // Danger Zone Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.accentColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DangerZoneSection(
                            onDeleteAccountTap: () =>
                                _confirmDeleteAccount(context),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyBottomSheet(BuildContext context) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: CurrencyProvider.supportedCurrencies.length,
          itemBuilder: (context, index) {
            final currencyEntry =
                CurrencyProvider.supportedCurrencies.entries.elementAt(index);
            return ListTile(
              title: Text('${currencyEntry.key} - ${currencyEntry.value.name}'),
              subtitle: Text('Symbol: ${currencyEntry.value.symbol}'),
              onTap: () {
                currencyProvider.changeCurrency(currencyEntry.key);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

void _showAboutBottomSheet(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Finlytics',
    applicationVersion: '1.0.0',
    applicationIcon: const CircleAvatar(
      backgroundColor: Colors.blue,
      child: Icon(Icons.analytics_outlined, color: Colors.white),
    ),
    applicationLegalese: '© 2024 Finlytics. All rights reserved.',
    barrierColor: Colors.black54, // Dim background
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Text(
          'A comprehensive financial tracking and analytics app designed to help you manage your finances with precision and ease.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Key Features:',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Expense Tracking'),
            Text('• Budget Planning'),
            Text('• Financial Insights'),
            Text('• Finlytics AI'),
          ],
        ),
      ),
    ],
  );
}

class DialogTheme {
  static const Color warningColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color infoColor = AppTheme.primaryColor;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
}
