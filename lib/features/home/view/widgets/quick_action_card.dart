import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../models/quick_action_model.dart';
import '../painters/ai_pattern_painter.dart';

class QuickActionCard extends StatelessWidget {
  final QuickActionModel action;
  final Size size;
  final bool isTablet;
  final bool isArabic;

  const QuickActionCard({
    super.key,
    required this.action,
    required this.size,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 280 : 250,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
      child: GestureDetector(
        onTap: action.onTap,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                action.color.withOpacity(0.12),
                action.color.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: action.color.withOpacity(0.2), width: 1),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(painter: AIPatternPainter(action.color)),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header row with icon and badges
                  _buildHeaderRow(),
                  SizedBox(height: isTablet ? 10 : 8),

                  // Content section
                  _buildContentSection(),
                  SizedBox(height: isTablet ? 18 : 16),

                  // Action button
                  _buildActionButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // Icon on the left
        Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: action.color.withOpacity(0.15),
          ),
          child: Icon(
            action.icon,
            color: action.color,
            size: isTablet ? 28 : 24,
          ),
        ),
        SizedBox(width: isTablet ? 12 : 10),

        // Badges column
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW badge
            Align(
              alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: action.color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isArabic ? 'جديد' : 'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 9 : 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            // AI Assistant text
            Text(
              isArabic ? 'ذكاء اصطناعي' : 'AI Assistant',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.w500,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                action.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 6 : 4),

              // Subtitle
              Text(
                action.subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 11 : 10,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      alignment: Alignment.center,
      width: (isTablet ? 280 : 250) - 4,
      height: isTablet ? 42 : 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [action.color, action.color.withOpacity(0.85)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: action.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: action.onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white,
                  size: isTablet ? 15 : 13,
                ),
                const SizedBox(width: 6),
                Text(
                  isArabic ? 'جرب الآن' : 'Try Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
