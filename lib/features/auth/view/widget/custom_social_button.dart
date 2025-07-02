import 'package:flutter/material.dart';

class CustomSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;
  final double? iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
    this.textColor,
    this.borderColor,
    this.iconSize = 24,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? Colors.grey[700]!;
    final Color effectiveTextColor = textColor ?? Colors.grey[700]!;
    final Color effectiveBorderColor = borderColor ?? Colors.grey[300]!;
    final EdgeInsetsGeometry effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 16);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize, color: effectiveIconColor),
      label: Text(
        label,
        style: TextStyle(
          color: effectiveTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: effectivePadding,
        side: BorderSide(color: effectiveBorderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: effectiveTextColor,
      ),
    );
  }
}
