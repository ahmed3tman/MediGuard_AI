import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../models/quick_action_model.dart';
import '../painters/ai_pattern_painter.dart';

class UnifiedActionCard extends StatelessWidget {
  final QuickActionModel action;
  final Size size;
  final bool isTablet;
  final bool isArabic;

  const UnifiedActionCard({
    super.key,
    required this.action,
    required this.size,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = action.isPrimary
        ? const Color(0xFF6366F1)
        : action.color;

    return Container(
      width: isTablet ? 280 : 250,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
      child: GestureDetector(
        onTap: action.isEnabled ? action.onTap : null,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor.withOpacity(action.isEnabled ? 0.12 : 0.06),
                effectiveColor.withOpacity(action.isEnabled ? 0.06 : 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: effectiveColor.withOpacity(action.isEnabled ? 0.2 : 0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              if (action.isEnabled)
                Positioned.fill(
                  child: CustomPaint(painter: AIPatternPainter(effectiveColor)),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header row
                  _buildHeaderRow(effectiveColor),
                  SizedBox(height: isTablet ? 10 : 8),

                  // Content section
                  _buildContentSection(),
                  SizedBox(height: isTablet ? 18 : 16),

                  // Action button
                  _buildActionButton(effectiveColor),
                ],
              ),

              // Disabled overlay
              if (!action.isEnabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? 'قريباً' : 'Coming Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(Color effectiveColor) {
    return Row(
      children: [
        // Icon on the left
        Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: effectiveColor.withOpacity(action.isEnabled ? 0.15 : 0.08),
          ),
          child: Icon(
            action.isPrimary ? Icons.document_scanner_outlined : action.icon,
            color: effectiveColor.withOpacity(action.isEnabled ? 1.0 : 0.6),
            size: isTablet ? 28 : 24,
          ),
        ),
        SizedBox(width: isTablet ? 12 : 10),

        // Badges column
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // NEW badge (only if new)
              if (action.isNew)
                Align(
                  alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: action.isEnabled ? effectiveColor : Colors.grey,
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

              if (action.isNew) SizedBox(height: isTablet ? 6 : 4),

              // AI Assistant text (only if has AI)
              if (action.hasAI)
                Text(
                  isArabic ? 'ذكاء اصطناعي' : 'AI Assistant',
                  style: TextStyle(
                    color: action.isEnabled
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withOpacity(0.6),
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                ),
            ],
          ),
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
                  color: action.isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textPrimary.withOpacity(0.6),
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
                  color: action.isEnabled
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withOpacity(0.6),
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

  Widget _buildActionButton(Color effectiveColor) {
    return Container(
      alignment: Alignment.center,
      width: (isTablet ? 280 : 250) - 4,
      height:  (isTablet ? 46 : 42),
      decoration: BoxDecoration(
        gradient: action.isEnabled
            ? LinearGradient(
                colors: [effectiveColor, effectiveColor.withOpacity(0.85)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[300]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: action.isEnabled
            ? [
                BoxShadow(
                  color: effectiveColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: action.isEnabled ? action.onTap : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  action.buttonIcon ??
                      (action.isPrimary
                          ? Icons.camera_alt_outlined
                          : Icons.touch_app_outlined),
                  color: action.isEnabled ? Colors.white : Colors.grey[600],
                  size: isTablet ? 15 : 13,
                ),
                const SizedBox(width: 6),
                Text(
                  action.buttonText ?? (isArabic ? 'جرب الآن' : 'Try Now'),
                  style: TextStyle(
                    color: action.isEnabled ? Colors.white : Colors.grey[600],
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
