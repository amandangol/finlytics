import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/custom_appbar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  PrivacyPolicyPage({super.key});

  final Uri _githubUrl = Uri.parse('https://github.com/amandangol/finlytics');

  // Method to launch URL
  Future<void> _launchUrl() async {
    if (!await launchUrl(_githubUrl)) {
      throw Exception('Could not launch $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Privacy Policy"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finlytics',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Last Updated: December 10, 2024\n\n'
                'Welcome to Finlytics. This Privacy Policy outlines how we collect, use, protect, and share your personal information when you use our financial tracking and analytics application.\n\n'
                'Interpretation and Definitions\n\n'
                'Definitions:\n'
                '• Application: Finlytics mobile application\n'
                '• Personal Data: Information that can identify you\n'
                '• Usage Data: Automatically collected information about app usage\n\n'
                'Types of Data Collected\n\n'
                'Personal Data:\n'
                '• Email address\n'
                '• Profile information\n'
                '• Financial transaction details\n\n'
                'Usage Data:\n'
                '• Device information\n'
                '• IP address\n'
                '• App usage statistics\n'
                '• Performance logs\n\n'
                'How We Use Your Information\n\n'
                'We use your data to:\n'
                '• Provide and improve app services\n'
                '• Generate financial insights\n'
                '• Personalize user experience\n'
                '• Send important app notifications\n'
                '• Ensure app security\n\n'
                'Data Protection\n\n'
                '• We implement robust security measures\n'
                '• All sensitive data is encrypted\n'
                '• We do not sell personal information\n\n'
                'User Rights\n\n'
                '• Right to access your data\n'
                '• Right to delete your account\n'
                '• Option to opt-out of analytics\n\n'
                'Children\'s Privacy\n\n'
                'Finlytics is not intended for children under 13. We do not knowingly collect data from children.\n\n'
                'Changes to Privacy Policy\n\n'
                'We may update this policy periodically. Continued use of the app implies acceptance of updated terms.\n\n'
                'Contact Us\n\n'
                'For privacy-related questions, please contact us:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: _launchUrl,
                child: const Text(
                  'GitHub Repository',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Email: support@finlytics.com',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
