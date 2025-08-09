import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../models/self_check_model.dart';

class SelfCheckCard extends StatelessWidget {
  final SelfCheckModel selfCheck;
  final bool isTablet;
  final bool isArabic;
  final VoidCallback onDetailsPressed;
  final VoidCallback onReminderPressed;

  const SelfCheckCard({
    super.key,
    required this.selfCheck,
    required this.isTablet,
    required this.isArabic,
    required this.onDetailsPressed,
    required this.onReminderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selfCheck.color.withOpacity(0.12),
            selfCheck.color.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selfCheck.color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and badge
                _buildHeaderRow(),
                SizedBox(height: isTablet ? 8 : 6),

                // Description
                _buildDescription(),
                SizedBox(height: isTablet ? 6 : 4),

                // Action buttons
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 14 : 12),
          decoration: BoxDecoration(
            color: selfCheck.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: selfCheck.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            selfCheck.icon,
            color: selfCheck.color,
            size: isTablet ? 32 : 28,
          ),
        ),
        SizedBox(width: isTablet ? 10 : 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selfCheck.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isArabic ? 'مهم' : 'Important',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 11 : 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
            // Title
            Text(
              selfCheck.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      selfCheck.description,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: isTablet ? 13 : 12,
        fontFamily: isArabic ? 'NeoSansArabic' : null,
        height: 1.5,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDetailsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: selfCheck.color.withOpacity(0.15),
              foregroundColor: selfCheck.color,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.info_outline, size: isTablet ? 18 : 16),
            label: Text(
              isArabic ? 'تفاصيل أكثر' : 'Learn More',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w600,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 10 : 8),
        IconButton(
          onPressed: onReminderPressed,
          icon: Icon(
            Icons.notifications_outlined,
            color: selfCheck.color,
            size: isTablet ? 24 : 20,
          ),
          style: IconButton.styleFrom(
            backgroundColor: selfCheck.color.withOpacity(0.1),
            padding: EdgeInsets.all(isTablet ? 12 : 10),
          ),
        ),
      ],
    );
  }
}
