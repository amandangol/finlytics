import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/currency_provider.dart';
import '../../../../models/account_model.dart';

class AccountsDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function(String, double) onAddAccount;
  final Function(String, double) onUpdateBalance;
  final Function(Account) onSelectAccount;
  final VoidCallback onSelectTotalBalance;

  const AccountsDialog({
    super.key,
    required this.accounts,
    required this.onAddAccount,
    required this.onUpdateBalance,
    required this.onSelectAccount,
    required this.onSelectTotalBalance,
  });

  @override
  _AccountsDialogState createState() => _AccountsDialogState();
}

class _AccountsDialogState extends State<AccountsDialog> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  bool _showAddAccountFields = false;
  String _errorMessage = "";

  void _saveAccount() {
    setState(() {
      _errorMessage = "";
      final accountName = _accountNameController.text.trim();
      final balanceText = _balanceController.text.trim();

      if (accountName.isEmpty) {
        _errorMessage = 'Account name cannot be empty';
      } else if (accountName.length > 50) {
        _errorMessage = 'Account name too long';
      } else if (balanceText.isEmpty) {
        _errorMessage = 'Balance cannot be empty';
      } else if (widget.accounts.length == 5) {
        _errorMessage = 'Cannot add more than 5 accounts';
      } else {
        final balance = double.tryParse(balanceText);
        if (balance == null) {
          _errorMessage = 'Invalid balance amount';
        } else {
          final accountExists = widget.accounts.any((account) =>
              account.name.toLowerCase() == accountName.toLowerCase());
          if (accountExists) {
            _errorMessage = 'Account with the same name already exists!';
          } else {
            widget.onAddAccount(accountName, balance);
            _accountNameController.clear();
            _balanceController.clear();
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  Widget _buildErrorMessage() {
    return _errorMessage.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.errorColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: AppTheme.errorColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.dividerColor),
          ),
          isDense: true,
        ),
        style: AppTheme.textTheme.bodyLarge,
        keyboardType: keyboardType,
      ),
    );
  }

  void _showUpdateBalanceDialog(String accountName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Update Balance for $accountName',
          style: AppTheme.textTheme.displayMedium,
        ),
        content: _buildTextField(
          controller: _balanceController,
          labelText: 'New Balance',
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newBalance =
                  double.tryParse(_balanceController.text.trim());
              if (newBalance != null) {
                widget.onUpdateBalance(accountName, newBalance);
                _balanceController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(
        'Accounts',
        style: AppTheme.textTheme.displayMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Total Balance', style: AppTheme.textTheme.bodyLarge),
              trailing: const Icon(Icons.account_balance_wallet),
              onTap: widget.onSelectTotalBalance,
            ),
            ...widget.accounts.map((account) {
              return ListTile(
                title: Text(
                  account.name,
                  style: AppTheme.textTheme.bodyLarge,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyProvider.formatCurrency(account.balance),
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _balanceController.text = account.balance.toString();
                        _showUpdateBalanceDialog(account.name);
                      },
                    ),
                  ],
                ),
                onTap: () => widget.onSelectAccount(account),
              );
            }),
            const Divider(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showAddAccountFields
                  ? Column(
                      children: [
                        _buildTextField(
                          controller: _accountNameController,
                          labelText: 'Account Name',
                        ),
                        _buildTextField(
                          controller: _balanceController,
                          labelText: 'Initial Balance',
                          keyboardType: TextInputType.number,
                        ),
                        _buildErrorMessage(),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: Icon(
            _showAddAccountFields ? Icons.remove : Icons.add,
          ),
          label: Text(
            _showAddAccountFields ? 'Cancel' : 'Add Account',
          ),
          onPressed: () {
            setState(() {
              _showAddAccountFields = !_showAddAccountFields;
            });
          },
        ),
        if (_showAddAccountFields)
          TextButton(
            onPressed: _saveAccount,
            child: const Text('Save Account'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
