import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool isTablet;
  final bool isArabic;
  final bool showButton;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    required this.isTablet,
    required this.isArabic,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      child: showButton && buttonText != null && onButtonPressed != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildTitleColumn()),
                _buildActionButton(),
              ],
            )
          : _buildTitleColumn(),
    );
  }

  Widget _buildTitleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTablet ? 22 : 20,
            fontWeight: FontWeight.bold,
            fontFamily: isArabic ? 'NeoSansArabic' : null,
          ),
        ),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isTablet ? 14 : 13,
            fontFamily: isArabic ? 'NeoSansArabic' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (!showButton || buttonText == null || onButtonPressed == null) {
      return const SizedBox.shrink();
    }

    return TextButton.icon(
      onPressed: onButtonPressed,
      icon: Icon(
        isArabic ? Icons.arrow_forward : Icons.arrow_back,
        color: AppColors.primaryColor,
        size: isTablet ? 20 : 18,
      ),
      label: Text(
        buttonText!,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: isTablet ? 14 : 13,
          fontWeight: FontWeight.w600,
          fontFamily: isArabic ? 'NeoSansArabic' : null,
        ),
      ),
    );
  }
}
