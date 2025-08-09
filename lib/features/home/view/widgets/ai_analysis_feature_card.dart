import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

/// Widget for displaying AI analysis features in a card format
/// This is a placeholder for future AI analysis functionality
class AIAnalysisFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isTablet;
  final bool isArabic;

  const AIAnalysisFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isTablet ? 28 : 24),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Title
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),

            SizedBox(height: isTablet ? 8 : 6),

            // Description
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 14 : 12,
                height: 1.4,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: isTablet ? 16 : 12),

            // Action button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                isArabic ? 'قريباً' : 'Coming Soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: isTablet ? 14 : 12,
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
