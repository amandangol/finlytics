import 'package:flutter/material.dart';

import 'settings_card.dart';

class AccountSettingsSection extends StatelessWidget {
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsofServicesTap;
  final VoidCallback onSignOutTap;
  final VoidCallback onCurrencyExchangeTap;
  final VoidCallback onAboutTap;

  const AccountSettingsSection({
    super.key,
    required this.onPrivacyTap,
    required this.onSignOutTap,
    required this.onCurrencyExchangeTap,
    required this.onTermsofServicesTap,
    required this.onAboutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Account Settings'),
        SettingsCard(
          icon: Icons.currency_exchange,
          title: 'Currency Exchange',
          onTap: onCurrencyExchangeTap,
        ),
        SettingsCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: onPrivacyTap,
        ),
        SettingsCard(
          icon: Icons.document_scanner_outlined,
          title: 'Terms of Services',
          onTap: onTermsofServicesTap,
        ),
        SettingsCard(
          icon: Icons.info_outline,
          title: 'About',
          onTap: onAboutTap,
        ),
        SettingsCard(
          icon: Icons.exit_to_app,
          title: 'Sign Out',
          onTap: onSignOutTap,
          isDestructive: false,
        ),
      ],
    );
  }
}
