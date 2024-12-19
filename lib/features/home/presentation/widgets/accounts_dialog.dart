import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/currency_provider.dart';
import '../../../../models/account_model.dart';
import 'custom_text_field.dart';

class AccountsDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function(String, double) onAddAccount;
  final Function(String, double) onUpdateBalance;
  final Function(Account) onSelectAccount;
  final Function(String) onRenameAccount;
  final Function(String) onDeleteAccount;
  final VoidCallback onSelectTotalBalance;
  final Account? selectedAccount;

  const AccountsDialog({
    super.key,
    required this.accounts,
    required this.onAddAccount,
    required this.onUpdateBalance,
    required this.onSelectAccount,
    required this.onRenameAccount,
    required this.onDeleteAccount,
    required this.onSelectTotalBalance,
    this.selectedAccount,
  });

  @override
  _AccountsDialogState createState() => _AccountsDialogState();
}

class _AccountsDialogState extends State<AccountsDialog> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  bool _showAddAccountFields = false;
  String _errorMessage = "";
  final _formKey = GlobalKey<FormState>();
  final _renameFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      final accountName = _accountNameController.text.trim();
      final balance = double.parse(_balanceController.text.trim());

      final accountExists = widget.accounts.any(
          (account) => account.name.toLowerCase() == accountName.toLowerCase());

      if (accountExists) {
        setState(() {
          _errorMessage = 'Account with the same name already exists!';
        });
        return;
      }

      if (widget.accounts.length >= 5) {
        setState(() {
          _errorMessage = 'Cannot add more than 5 accounts';
        });
        return;
      }

      widget.onAddAccount(accountName, balance);
      _accountNameController.clear();
      _balanceController.clear();
      setState(() {
        _showAddAccountFields = false;
        _errorMessage = "";
      });
    }
  }

  void _showRenameAccountDialog(Account account) {
    _renameController.text = account.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Rename Account',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _renameFormKey,
          child: CustomTextField(
            controller: _renameController,
            labelText: 'New Account Name',
            prefixIcon: Icons.drive_file_rename_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Account name cannot be empty';
              }
              if (value.length > 50) {
                return 'Account name too long';
              }
              final nameExists = widget.accounts.any((a) =>
                  a.name.toLowerCase() == value.trim().toLowerCase() &&
                  a.name.toLowerCase() != account.name.toLowerCase());
              if (nameExists) {
                return 'Account name already exists';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_renameFormKey.currentState?.validate() ?? false) {
                widget.onRenameAccount(_renameController.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 10),
            Text(
              'Delete Account',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the account "${account.name}"? This action cannot be undone.',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              widget.onDeleteAccount(account.name);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpdateBalanceDialog(Account account) {
    _balanceController.text = account.balance.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Update Balance',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update balance for ${account.name}',
              style: AppTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: GlobalKey<FormState>(),
              child: CustomTextField(
                controller: _balanceController,
                labelText: 'New Balance',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid balance amount';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newBalance =
                  double.tryParse(_balanceController.text.trim());
              if (newBalance != null) {
                widget.onUpdateBalance(account.name, newBalance);
                _balanceController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppTheme.cardColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accounts Management',
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
            onPressed: () {
              _showAccountManagementHelp();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: widget.selectedAccount == null
                      ? const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryDarkColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey[700]!, Colors.grey[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: widget.onSelectTotalBalance,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyProvider.formatCurrency(
                                  widget.accounts.fold(
                                    0.0,
                                    (sum, account) => sum + account.balance,
                                  ),
                                ),
                                style: AppTheme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Accounts List
              ...widget.accounts.map((account) {
                bool isSelected = account == widget.selectedAccount;
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryDarkColor
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => widget.onSelectAccount(account),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color:
                                              isSelected ? Colors.white : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyProvider
                                            .formatCurrency(account.balance),
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit_balance':
                                        _showUpdateBalanceDialog(account);
                                        break;
                                      case 'rename':
                                        _showRenameAccountDialog(account);
                                        break;
                                      case 'delete':
                                        _showDeleteAccountConfirmation(account);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit_balance',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Update Balance',
                                            style:
                                                AppTheme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.drive_file_rename_outline,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rename Account',
                                            style:
                                                AppTheme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: AppTheme.errorColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete Account',
                                            style: AppTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppTheme.errorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )));
              }),

              const SizedBox(height: 16),

              // Add Account Section with Improved Design
              if (_showAddAccountFields)
                Column(
                  children: [
                    CustomTextField(
                      controller: _accountNameController,
                      labelText: 'Account Name',
                      prefixIcon: Icons.account_circle,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account name cannot be empty';
                        }
                        if (value.length > 50) {
                          return 'Account name too long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _balanceController,
                      labelText: 'Initial Balance',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Balance cannot be empty';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid balance amount';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Dynamic Action Buttons
        TextButton.icon(
          icon: Icon(
            _showAddAccountFields ? Icons.close : Icons.add,
            color: AppTheme.primaryColor,
          ),
          label: Text(
            _showAddAccountFields ? 'Cancel' : 'Add Account',
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
          onPressed: () {
            setState(() {
              _showAddAccountFields = !_showAddAccountFields;
              _errorMessage = "";
            });
          },
        ),
        if (_showAddAccountFields)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
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

  void _showAccountManagementHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Account Management Help',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                'Add Account',
                'Click "Add Account" to create a new account. You can have up to 5 accounts.',
                Icons.add_circle_outline,
              ),
              _buildHelpSection(
                'Update Balance',
                'Use the three-dot menu to update an account\'s balance at any time.',
                Icons.edit,
              ),
              _buildHelpSection(
                'Rename Account',
                'Easily rename your accounts through the three-dot menu. Ensure unique account names.',
                Icons.drive_file_rename_outline,
              ),
              _buildHelpSection(
                'Delete Account',
                'Remove accounts you no longer need. Deleted accounts cannot be recovered.',
                Icons.delete_forever,
              ),
              _buildHelpSection(
                'Total Balance',
                'The top tile shows the combined balance of all your accounts. Tap to view more details.',
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build help sections
  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
