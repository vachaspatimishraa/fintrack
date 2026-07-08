import 'package:flutter/material.dart';

class AppCategories {
  const AppCategories._();

  static const List<String> income = [
    'Salary',
    'Investment',
    'Freelance',
    'Gift',
    'Opening Balance',
    'Other',
  ];

  static const List<String> expense = [
    'Food & Drinks',
    'Shopping',
    'Housing',
    'Transportation',
    'Entertainment',
    'Utilities',
    'Health',
    'Education',
    'Travel',
    'Other',
  ];

  static IconData getIcon(String category) {
    switch (category) {
      // Income
      case 'Salary':
        return Icons.work_outline;
      case 'Investment':
        return Icons.trending_up;
      case 'Freelance':
        return Icons.laptop;
      case 'Gift':
        return Icons.card_giftcard;
      case 'Opening Balance':
        return Icons.account_balance_wallet_outlined;
      
      // Expense
      case 'Food & Drinks':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Housing':
        return Icons.home_outlined;
      case 'Transportation':
        return Icons.directions_car_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Utilities':
        return Icons.power_outlined;
      case 'Health':
        return Icons.medical_services;
      case 'Education':
        return Icons.school_outlined;
      case 'Travel':
        return Icons.flight_takeoff;
      default:
        return Icons.category_outlined;
    }
  }
}
