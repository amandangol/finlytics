import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../models/transaction_model.dart';

class TransactionSummaryCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionSummaryCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: transaction.type == 'Income'
          ? AppTheme.successColor
          : AppTheme.errorColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.type,
              style: AppTheme.textTheme.headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy').format(transaction.date.toDate()),
              style:
                  AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: AppTheme.textTheme.headlineMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
