import 'package:flutter/material.dart';

class DetailsInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  const DetailsInputWidget({
    super.key,
    required this.controller,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration,
      maxLines: 2,
      validator: (value) {
        if (value != null && value.length > 200) {
          return 'Details should be less than 200 characters';
        }
        return null;
      },
    );
  }
}
