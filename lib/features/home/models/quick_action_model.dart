import 'package:flutter/material.dart';

class QuickActionModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isEnabled;
  final bool hasAI;
  final bool isNew;
  final String? buttonText;
  final IconData? buttonIcon;

  const QuickActionModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
    this.isEnabled = true,
    this.hasAI = false,
    this.isNew = false,
    this.buttonText,
    this.buttonIcon,
  });
}
