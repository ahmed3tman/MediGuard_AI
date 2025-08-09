import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

class LoadingStateWidget extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const LoadingStateWidget({
    super.key,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            isArabic ? 'جاري تحميل البيانات...' : 'Loading data...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isTablet ? 16 : 14,
              fontFamily: isArabic ? 'NeoSansArabic' : null,
            ),
          ),
        ],
      ),
    );
  }
}
