import 'package:flutter/material.dart';
import '../../../../../../core/utils/category_helper.dart';

class CategoryDropdownWidget extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;

  const CategoryDropdownWidget({
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
      items: CategoryHelper.getAllCategories()
          .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      CategoryHelper.getCategoryIcon(category),
                      color: CategoryHelper.getCategoryColor(category),
                    ),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select a category' : null,
    );
  }
}
