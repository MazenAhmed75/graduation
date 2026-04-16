import 'package:flutter/material.dart';
import '../theme.dart';

class BudgetItemModel {
  final String id;
  String title;
  String subtitle;
  double allocated;
  double spent;
  String insight;
  IconData insightIcon;
  Color insightColor;
  Color progressColor;
  IconData iconData;
  Color iconBg;
  Color iconColor;
  Color spentColor;

  BudgetItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.allocated,
    required this.spent,
    required this.insight,
    required this.insightIcon,
    required this.insightColor,
    required this.progressColor,
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    this.spentColor = AppTheme.primary,
  });
}
