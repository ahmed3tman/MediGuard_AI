import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isTablet;
  final bool isArabic;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: isTablet ? 80 : 64,
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              isArabic ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 16 : 14,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.refresh, size: isTablet ? 24 : 20),
              label: Text(
                isArabic ? 'إعادة المحاولة' : 'Try Again',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
