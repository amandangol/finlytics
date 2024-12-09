import 'package:flutter/material.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }
}
