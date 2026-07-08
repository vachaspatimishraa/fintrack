import 'package:flutter/material.dart';

class BudgetInsight {
  final String message;
  final IconData icon;
  final Color color;
  final String type; // positive, negative, neutral

  BudgetInsight({
    required this.message,
    required this.icon,
    required this.color,
    required this.type,
  });
}
