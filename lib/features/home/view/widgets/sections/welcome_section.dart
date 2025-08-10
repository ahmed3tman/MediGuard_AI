import 'package:flutter/material.dart';
import '../welcome_section.dart';

class WelcomeSectionWrapper extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const WelcomeSectionWrapper({
    super.key,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: WelcomeSection(isTablet: isTablet, isArabic: isArabic),
    );
  }
}
