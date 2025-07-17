import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

enum SnackBarPosition { top, bottom }

class FloatingSnackBar {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarType type = SnackBarType.info,
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (_isShowing) {
      hide();
    }

    _isShowing = true;

    // Get colors based on type
    final colors = _getColorsForType(type);
    final bgColor = backgroundColor ?? colors['background'];
    final txtColor = textColor ?? colors['text'];
    final iconData = icon ?? colors['icon'];
    final iconColor = colors['iconColor'];

    _overlayEntry = OverlayEntry(
      builder: (context) => _FloatingSnackBarWidget(
        message: message,
        icon: iconData,
        iconColor: iconColor,
        backgroundColor: bgColor,
        textColor: txtColor,
        position: position,
        onDismiss: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (_isShowing) {
        hide();
      }
    });
  }

  static void hide() {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static Map<String, dynamic> _getColorsForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return {
          'background': Colors.grey.withOpacity(0.4),
          'text': Colors.white,
          'icon': Icons.check_circle,
          'iconColor': Colors.green,
        };
      case SnackBarType.error:
        return {
          'background': Colors.grey.withOpacity(0.4),
          'text': Colors.white,
          'icon': Icons.error,
          'iconColor': Colors.red,
        };
      case SnackBarType.warning:
        return {
          'background': Colors.grey.withOpacity(0.4),
          'text': Colors.white,
          'icon': Icons.warning,
          'iconColor': Colors.orange,
        };
      case SnackBarType.info:
        return {
          'background': Colors.grey.withOpacity(0.4),
          'text': Colors.white,
          'icon': Icons.info,
          'iconColor': Colors.blue,
        };
    }
  }

  // Convenience methods
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      position: position,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      position: position,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      position: position,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      position: position,
    );
  }
}

class _FloatingSnackBarWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final SnackBarPosition position;
  final VoidCallback? onDismiss;

  const _FloatingSnackBarWidget({
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.position = SnackBarPosition.top,
    this.onDismiss,
  });

  @override
  State<_FloatingSnackBarWidget> createState() =>
      _FloatingSnackBarWidgetState();
}

class _FloatingSnackBarWidgetState extends State<_FloatingSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Different slide animations based on position
    _slideAnimation =
        Tween<Offset>(
          begin: widget.position == SnackBarPosition.top
              ? const Offset(0, -0.5) // Slide from top
              : const Offset(0, 0.5), // Slide from bottom
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves
                .easeOutBack, // Changed to easeOutBack for a slight bounce
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate position based on position parameter
    final double topPosition;
    final double bottomPosition;

    if (widget.position == SnackBarPosition.top) {
      // Position at top (below AppBar)
      final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
      topPosition = appBarHeight + 8;
      bottomPosition = double.infinity; // Not used
    } else {
      // Position at bottom (above bottom navigation or at bottom of screen)
      topPosition = double.infinity; // Not used
      bottomPosition = MediaQuery.of(context).padding.bottom + 16;
    }

    return Positioned(
      top: widget.position == SnackBarPosition.top ? topPosition : null,
      bottom: widget.position == SnackBarPosition.bottom
          ? bottomPosition
          : null,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: (widget.backgroundColor ?? Colors.grey).withOpacity(
                      0.5,
                    ), // Made more transparent
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color:
                                  widget.iconColor ??
                                  widget.textColor ??
                                  Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: widget.textColor ?? Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Icon(
                              Icons.close,
                              color: widget.textColor ?? Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
