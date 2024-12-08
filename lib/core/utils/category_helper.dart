import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Bills':
        return Icons.receipt;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Entertainment':
        return Icons.movie;
      case 'Salary':
        return Icons.attach_money;
      case 'Freelance':
        return Icons.work;
      case 'Investments':
        return Icons.trending_up;
      case 'Rent':
        return Icons.home;
      case 'Utilities':
        return Icons.electrical_services;
      case 'Healthcare':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      case 'Gifts':
        return Icons.card_giftcard;
      case 'Other':
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange.shade300;
      case 'Bills':
        return Colors.purple.shade300;
      case 'Transport':
        return Colors.teal.shade300;
      case 'Shopping':
        return Colors.green.shade300;
      case 'Entertainment':
        return Colors.cyan.shade300;
      case 'Salary':
        return Colors.green.shade400;
      case 'Freelance':
        return Colors.blue.shade300;
      case 'Investments':
        return Colors.indigo.shade300;
      case 'Rent':
        return Colors.brown.shade300;
      case 'Utilities':
        return Colors.deepPurple.shade300;
      case 'Healthcare':
        return Colors.red.shade300;
      case 'Education':
        return Colors.amber.shade300;
      case 'Gifts':
        return Colors.pink.shade300;
      case 'Other':
        return Colors.blueGrey.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  static List<String> getAllCategories() {
    return [
      'Food',
      'Bills',
      'Transport',
      'Shopping',
      'Entertainment',
      'Salary',
      'Freelance',
      'Investments',
      'Rent',
      'Utilities',
      'Healthcare',
      'Education',
      'Gifts',
      'Other'
    ];
  }
}
