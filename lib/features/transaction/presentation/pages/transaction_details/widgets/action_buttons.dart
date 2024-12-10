import 'package:flutter/material.dart';

import '../../../../../../models.dart';

class _ActionButtons extends StatelessWidget {
  final TransactionModel transaction;

  const _ActionButtons({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
          onPressed: () => _navigateToEditTransactionPage(context),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppTheme.errorColor),
          onPressed: () => _deleteTransaction(context),
        ),
      ],
    );
  }

  void _navigateToEditTransactionPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditTransactionPage(transaction: transaction)));
  }
}
