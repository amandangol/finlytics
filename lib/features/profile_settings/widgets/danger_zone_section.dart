import 'package:flutter/material.dart';

import 'settings_card.dart';

class DangerZoneSection extends StatelessWidget {
  final VoidCallback onDeleteAccountTap;

  const DangerZoneSection({
    super.key,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Danger Zone', color: Colors.red),
        SettingsCard(
          icon: Icons.delete_forever,
          title: 'Delete Account',
          onTap: onDeleteAccountTap,
          isDestructive: true,
        ),
      ],
    );
  }
}
