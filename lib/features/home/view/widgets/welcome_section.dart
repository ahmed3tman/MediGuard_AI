import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

class WelcomeSection extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const WelcomeSection({
    super.key,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'مرحباً بك في MediGuard AI' : 'Welcome to MediGuard AI',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: isArabic ? 'NeoSansArabic' : null,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            isArabic
                ? 'رفيقك الذكي لمراقبة وتحليل العلامات الحيوية لحظياً'
                : 'Your smart companion for real-time health monitoring and analysis',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isTablet ? 14 : 12,
              fontFamily: isArabic ? 'NeoSansArabic' : null,
            ),
          ),
        ],
      ),
    );
  }
}
