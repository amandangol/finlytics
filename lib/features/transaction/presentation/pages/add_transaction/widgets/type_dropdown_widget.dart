import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

// Type Dropdown Widget
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
      dropdownColor: AppTheme.cardColor, 
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTextColor,
          ),
      borderRadius: BorderRadius.circular(12),
      items: ['Expense', 'Income'].map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Row(
            children: [
              Icon(
                type == 'Expense' ? Icons.arrow_upward : Icons.arrow_downward,
                color: type == 'Expense' ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 10),
              Text(type),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a transaction type';
        }
        return null;
      },
    );
  }
}
