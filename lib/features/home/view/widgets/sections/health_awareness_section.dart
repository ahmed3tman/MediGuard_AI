import 'package:flutter/material.dart';

class HealthAwarenessSection extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const HealthAwarenessSection({
    super.key,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: isTablet ? 20 : 16));
  }
}
