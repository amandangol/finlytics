import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../models/transaction_model.dart';

class TransactionDetailSection extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSection({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details:',
              style: AppTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              transaction.details ?? "No details provided",
              style: AppTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
