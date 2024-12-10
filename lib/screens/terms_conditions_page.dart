import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/common/custom_appbar.dart';

class TermsOfServicePage extends StatelessWidget {
  TermsOfServicePage({super.key});

  // GitHub repository link - update as needed
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
      appBar: const CustomAppBar(title: "Terms of Service"),
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
                'Acceptance of Terms\n\n'
                'By downloading, installing, or using the Finlytics mobile application (the "App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.\n\n'
                'Description of Service\n\n'
                'Finlytics is a mobile application designed to help users track, analyze, and manage their financial information. The App provides tools for financial insights, transaction tracking, and personal financial management.\n\n'
                'User Eligibility\n\n'
                '• Must be at least 13 years old to use this App\n'
                '• Must provide accurate, current, and complete information during registration\n'
                '• Responsible for maintaining account confidentiality\n\n'
                'User Account\n\n'
                '• Can create an account using an email address\n'
                '• Will receive essential app-related communications via email\n'
                '• May delete account at any time through App settings\n\n'
                'User Conduct and Responsibilities\n\n'
                'When using Finlytics, you agree to:\n'
                '• Use the App for lawful purposes only\n'
                '• Not attempt to breach the App\'s security\n'
                '• Not share account credentials\n'
                '• Not use the App to store fraudulent or illegal financial information\n'
                '• Respect the privacy and data of other users\n\n'
                'Data Usage and Protection\n\n'
                '• All user data is encrypted and protected\n'
                '• We do not sell personal financial information to third parties\n'
                '• Users can export or delete their financial data at any time\n\n'
                'Financial Data Disclaimer\n\n'
                '• Finlytics provides financial insights and tracking tools\n'
                '• The App does not constitute financial advice\n'
                '• Users should consult professional financial advisors\n'
                '• We are not responsible for financial decisions based on App insights\n\n'
                'Intellectual Property\n\n'
                '• All content and functionality are owned by Finlytics\n'
                '• Protected by copyright and intellectual property laws\n'
                '• Users may not reproduce or distribute App content without consent\n\n'
                'Limitation of Liability\n\n'
                '• App provided "as is" without warranties\n'
                '• Not liable for any direct or indirect damages\n'
                '• Total liability limited to amount paid for App\n\n'
                'Modifications to Terms\n\n'
                '• We reserve the right to modify these Terms\n'
                '• Continued use implies acceptance of new Terms\n'
                '• Material changes will be communicated via email or in-app notification\n\n'
                'Governing Law\n\n'
                'These Terms are governed by the laws of our primary jurisdiction, without regard to conflict of law principles.\n\n'
                'Contact Information\n\n'
                'For any questions about these Terms, please contact:',
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
              const SizedBox(height: 20.0),
              Text(
                'By using Finlytics, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
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
