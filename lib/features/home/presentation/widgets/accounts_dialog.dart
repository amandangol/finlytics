import 'package:flutter/material.dart';

import '../../../../models.dart';

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

      if (_accountNameController.text.isEmpty) {
        _errorMessage = 'Account name cannot be empty';
      } else if (_accountNameController.text.length > 50) {
        _errorMessage = 'Account name too long';
      } else if (_balanceController.text.isEmpty) {
        _errorMessage = 'Balance cannot be empty';
      } else if (widget.accounts.length == 5) {
        _errorMessage = 'Cannot add more than 5 accounts';
      } else {
        double? balance = double.tryParse(_balanceController.text);
        if (balance == null) {
          _errorMessage = 'Invalid balance amount';
        } else {
          bool accountExists = widget.accounts.any((account) =>
              account.name.toLowerCase() ==
              _accountNameController.text.toLowerCase().trim());
          if (accountExists) {
            _errorMessage = 'Account with the same name already exists!';
          } else {
            widget.onAddAccount(_accountNameController.text, balance);
            _accountNameController.clear();
            _balanceController.clear();
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accounts'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListBody(
              children: [
                ListTile(
                  title: const Text('Total Balance',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.account_balance_wallet),
                  onTap: widget.onSelectTotalBalance,
                ),
                ...widget.accounts.map(
                  (account) => ListTile(
                    title: Text(account.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${account.balance.toString()}',
                            style: const TextStyle(
                                color: Color(0xFFEF6C06), fontSize: 12.0)),
                        IconButton(
                          padding:
                              const EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _balanceController.text =
                                account.balance.toString();
                            _showUpdateBalanceDialog(account.name);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      widget.onSelectAccount(account);
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            _showAddAccountFields
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _accountNameController,
                        decoration: const InputDecoration(
                          labelText: 'Account Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Balance',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          icon: Icon(
            _showAddAccountFields ? Icons.remove : Icons.add,
            color: const Color(0xFFEF6C06),
          ),
          label: Text(
            _showAddAccountFields ? 'Cancel' : 'Add Account',
            style: const TextStyle(color: Color(0xFFEF6C06)),
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
            child: const Text('Save Account',
                style: TextStyle(color: Color(0xFFEF6C06))),
          ),
        TextButton(
          child:
              const Text('Close', style: TextStyle(color: Color(0xFFEF6C06))),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showUpdateBalanceDialog(String accountName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Balance for $accountName account'),
        content: TextField(
          controller: _balanceController,
          decoration: const InputDecoration(
            labelText: 'New Balance',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text('Update',
                style: TextStyle(color: Color(0xFFEF6C06))),
            onPressed: () {
              double? newBalance = double.tryParse(_balanceController.text);
              if (newBalance != null) {
                widget.onUpdateBalance(accountName, newBalance);
                _balanceController.clear();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
          ),
          TextButton(
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFEF6C06))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
