import 'package:flutter/material.dart';
import 'package:spider_doctor/core/shared/theme/my_colors.dart';

/// Reusable gradient header used in multiple screens.
class GradientHeader extends StatelessWidget {
  final double height;
  final IconData icon;
  final String? title;
  final String? subtitle;

  const GradientHeader({
    Key? key,
    this.height = 120,
    required this.icon,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: title == null && subtitle == null
          ? Center(child: Icon(icon, size: 60, color: AppColors.primaryColor))
          : Row(
              children: [
                Icon(icon, size: 40, color: AppColors.primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NeoSansArabic',
                            color: AppColors.primaryColor,
                          ),
                        ),
                      if (subtitle != null) const SizedBox(height: 4),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'NeoSansArabic',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
