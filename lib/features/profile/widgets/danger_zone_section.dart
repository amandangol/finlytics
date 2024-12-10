import 'package:expense_tracker/features/profile/widgets/settings_card.dart';
import 'package:flutter/material.dart';

class DangerZoneSection extends StatelessWidget {
  final VoidCallback onDeleteDataTap;
  final VoidCallback onDeleteAccountTap;

  const DangerZoneSection({super.key, 
    required this.onDeleteDataTap,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Danger Zone', color: Colors.red),
        SettingsCard(
          icon: Icons.delete_outline,
          title: 'Delete All Data',
          onTap: onDeleteDataTap,
          isDestructive: true,
        ),
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
