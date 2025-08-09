import 'package:flutter/material.dart';

class SelfCheckModel {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const SelfCheckModel({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
