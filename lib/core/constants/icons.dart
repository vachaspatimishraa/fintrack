import 'package:flutter/material.dart';

class AppIcons {
  const AppIcons._();

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Salary':
        return Icons.work_outline;
      case 'Investment':
        return Icons.trending_up;
      case 'Freelance':
        return Icons.laptop;
      case 'Gift':
        return Icons.card_giftcard;
      case 'Food & Drinks':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Housing':
        return Icons.home_outlined;
      case 'Transportation':
        return Icons.directions_car_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Utilities':
        return Icons.power_outlined;
      case 'Health':
        return Icons.medical_services_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Travel':
        return Icons.flight_takeoff;
      default:
        return Icons.category_outlined;
    }
  }
}
