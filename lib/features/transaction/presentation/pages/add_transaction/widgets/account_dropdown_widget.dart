import 'package:expense_tracker/models.dart';
import 'package:flutter/material.dart';

class AccountDropdownWidget extends StatelessWidget {
  final List<Account> accounts;
  final String value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;

  const AccountDropdownWidget({
    super.key,
    required this.accounts,
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: decoration,
      items: accounts
          .map((account) => DropdownMenuItem<String>(
                value: account.name,
                child: Text(account.name),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select an account' : null,
    );
  }
}
