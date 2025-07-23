import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;
  final double toolbarHeight;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.leading,
    this.elevation = 0,
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
        style: TextStyle(
          fontSize: 18,
          color: foregroundColor ?? Colors.white,
          fontFamily: 'NeoSansArabic',
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.blue[600],
      foregroundColor: foregroundColor ?? Colors.white,
      centerTitle: centerTitle,
      leading: leading,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}

class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  const AppBarAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      splashRadius: 24,
    );
  }
}
