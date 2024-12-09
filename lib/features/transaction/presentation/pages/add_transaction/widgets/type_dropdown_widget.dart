import 'package:flutter/material.dart';

class TypeDropdownWidget extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;

  const TypeDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: decoration,
      items: ['Expense', 'Income']
          .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) =>
          val == null ? 'Please select a transaction type' : null,
    );
  }
}
