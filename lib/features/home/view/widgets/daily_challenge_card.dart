import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class DailyChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final String successMessage;
  final bool isTablet;
  final bool isArabic;

  const DailyChallengeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.successMessage,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.18),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 14),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              color: const Color(0xFF10B981),
              size: isTablet ? 32 : 26,
            ),
            SizedBox(width: isTablet ? 18 : 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: isArabic ? 'NeoSansArabic' : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 13 : 12,
                      fontFamily: isArabic ? 'NeoSansArabic' : null,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),

            // Action button
            ElevatedButton(
              onPressed: () => _showSuccessMessage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 18 : 12,
                  vertical: isTablet ? 12 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 13 : 12,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    FloatingSnackBar.showSuccess(context, message: successMessage);
  }
}
