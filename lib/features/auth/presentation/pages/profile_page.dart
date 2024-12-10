import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;

  const ProfilePage({super.key, required this.userModel});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation",
              style: TextStyle(
                  color: Color(0xFFEF6C06), fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to Sign Out?",
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFFEF6C06))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              child: const Text("Sign Out",
                  style: TextStyle(color: Color(0xFFEF6C06))),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (route) => false,
    );
  }

  void _confirmDeleteData(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Confirmation",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to delete all your data from our database?",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "All your data (transactions, photos, etc.) will be deleted and cannot be recovered once you confirm this.",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Type your registered email",
                      border: const OutlineInputBorder(),
                      errorText: errorMessage, // Show error here
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      setState(() {
                        errorMessage = "Email cannot be empty.";
                      });
                    } else if (emailController.text != widget.userModel.email) {
                      setState(() {
                        errorMessage = "Incorrect email. Please try again.";
                      });
                    } else {
                      // Navigator.of(context).pop();
                      _deleteAllData(context, "onlyData");
                    }
                  },
                  child: const Text("Delete Data",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
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
            return AlertDialog(
              title: const Text("Confirmation",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Are you sure you want to delete your Account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Account along with all your data (transactions, photos, etc.) will be deleted and cannot be recovered once you confirm this.\n"
                      "If you have signed in with this account in multiple devices, make sure to sign out from all other devices for proper deletion of the account.",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Type your registered email",
                        border: const OutlineInputBorder(),
                        errorText: emailErrorMessage,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Type your password",
                        border: const OutlineInputBorder(),
                        errorText: passwordErrorMessage,
                      ),
                      obscureText: true,
                    ),
                    if (emailErrorMessage != null ||
                        passwordErrorMessage != null) ...[
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      emailErrorMessage = null;
                      passwordErrorMessage = null;
                    });

                    if (emailController.text.isEmpty) {
                      setState(() {
                        emailErrorMessage = "Email cannot be empty.";
                      });
                    } else if (emailController.text != widget.userModel.email) {
                      setState(() {
                        emailErrorMessage =
                            "Incorrect email. Please try again.";
                      });
                    } else if (passwordController.text.isEmpty) {
                      setState(() {
                        passwordErrorMessage = "Password cannot be empty.";
                      });
                    } else {
                      // Attempt to reauthenticate the user
                      bool isReauthenticated = await _reauthenticateUser(
                        emailController.text,
                        passwordController.text,
                      );

                      if (isReauthenticated) {
                        _deleteAllData(context, "Account");
                      } else {
                        setState(() {
                          passwordErrorMessage =
                              "Incorrect password. Please try again.";
                        });
                      }
                    }
                  },
                  child: const Text("Delete Account",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _reauthenticateUser(String email, String password) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credentials);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _deleteAllData(BuildContext context, String toDelete) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SpinKitThreeBounce(
            color: AppTheme.primaryDarkColor,
            size: 20.0,
          ),
        );
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      final uid = user.uid;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Using WriteBatch to perform batched writes
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete transactions
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .get();
      if (transactions.docs.isNotEmpty) {
        for (var doc in transactions.docs) {
          batch.delete(doc.reference);
        }
      }

      // Delete photos from Firestore and Storage
      final photos = await FirebaseFirestore.instance
          .collection('photos')
          .where('userId', isEqualTo: uid)
          .get();
      if (photos.docs.isNotEmpty) {
        for (var doc in photos.docs) {
          final photoUrl = doc['imageUrl'] as String?;
          if (photoUrl != null) {
            await FirebaseStorage.instance.refFromURL(photoUrl).delete();
          }
          batch.delete(doc.reference);
        }
      }

      // Get user document to update the accounts and balance
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }

      UserModel userModel = UserModel.fromDocument(userDoc);

      // Delete all accounts except the main one and set the balance of the main account to 0
      if (userModel.accounts.isNotEmpty) {
        userModel.accounts.removeWhere((account) => account.name != 'Main');
        if (userModel.accounts.isNotEmpty) {
          userModel.accounts[0].balance = 0;
        }
      }

      // Update user document
      batch.update(userDocRef, {
        'accounts':
            userModel.accounts.map((account) => account.toMap()).toList(),
      });

      // Commit batch
      await batch.commit();

      if (toDelete == "Account") {
        await userDocRef.delete();
        await user.delete();
        Navigator.of(context).pop(); // Close the progress indicator

        _signOut(context);
      } else {
        // Only data deletion
        Navigator.of(context).pop(); // Close the progress indicator
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Data Deleted",
                  style: TextStyle(color: Colors.red)),
              content: const Text(
                "Please restart the app to view changes.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final Uri _url = Uri.parse(
      'https://github.com/AyaanHimani/TrackUrSpends_AI-Flutter-Expense-Tracker-App-with-AI-Chatbot.git');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Support",
              style: TextStyle(
                  color: Color(0xFFEF6C06), fontWeight: FontWeight.bold)),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                const TextSpan(
                  text: "This will take you to the app's GitHub page.\n\n"
                      "You are welcome to raise your queries and write your opinions.\n\n"
                      "Click on the link below if the page does not redirect.\n\n",
                ),
                TextSpan(
                  text:
                      "https://github.com/AyaanHimani/TrackUrSpends_AI-Flutter-Expense-Tracker-App-with-AI-Chatbot.git",
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFFEF6C06))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl();
              },
              child: const Text("Go to GitHub",
                  style: TextStyle(color: Color(0xFFEF6C06))),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    // const double buttonWidth = 300.0;
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF9A8B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userModel.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.userModel.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Settings Section
                _buildSectionTitle('Account Settings'),
                _buildSettingsCard(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/privacy-policy'),
                ),
                _buildSettingsCard(
                  context,
                  icon: Icons.support,
                  title: 'Support',
                  onTap: () => _showSupportDialog(context),
                ),
                _buildSettingsCard(
                  context,
                  icon: Icons.exit_to_app,
                  title: 'Sign Out',
                  onTap: () => _confirmSignOut(context),
                  isDestructive: false,
                ),

                // Danger Zone Section
                const SizedBox(height: 20),
                _buildSectionTitle('Danger Zone', color: Colors.red),
                _buildSettingsCard(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete All Data',
                  onTap: () => _confirmDeleteData(context),
                  isDestructive: true,
                ),
                _buildSettingsCard(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  onTap: () => _confirmDeleteAccount(context),
                  isDestructive: true,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
