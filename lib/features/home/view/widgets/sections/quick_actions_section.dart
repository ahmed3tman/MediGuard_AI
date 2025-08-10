import 'dart:async';
import 'package:flutter/material.dart';
import '../section_header.dart';
import '../unified_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  final Size size;
  final bool isTablet;
  final bool isArabic;
  final List<dynamic> quickActions;

  const QuickActionsSection({
    super.key,
    required this.size,
    required this.isTablet,
    required this.isArabic,
    required this.quickActions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isTablet ? 10 : 8),

          // Section Header
          SectionHeader(
            title: isArabic ? 'إجراءات سريعة' : 'Quick Actions',
            subtitle: isArabic
                ? 'نفذ مهامك الصحية بسرعة وسهولة'
                : 'Perform your health tasks quickly and easily',
            isTablet: isTablet,
            isArabic: isArabic,
            showButton: false,
          ),

          // Horizontal Auto-Scrolling List
          SizedBox(
            height: isTablet ? 220 : 190,
            child: _AutoScrollQuickActionsList(
              size: size,
              isTablet: isTablet,
              isArabic: isArabic,
              quickActions: quickActions,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoScrollQuickActionsList extends StatefulWidget {
  final Size size;
  final bool isTablet;
  final bool isArabic;
  final List<dynamic> quickActions;

  const _AutoScrollQuickActionsList({
    required this.size,
    required this.isTablet,
    required this.isArabic,
    required this.quickActions,
  });

  @override
  State<_AutoScrollQuickActionsList> createState() =>
      _AutoScrollQuickActionsListState();
}

class _AutoScrollQuickActionsListState
    extends State<_AutoScrollQuickActionsList> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  int _currentIndex = 0; // currently centered index

  double get _cardWidth => widget.isTablet ? 280 : 250;
  double get _cardMargin =>
      widget.isTablet ? 8 : 6; // symmetric horizontal margin inside card
  double get _horizontalPadding =>
      widget.isTablet ? 16 : 12; // list outer padding

  @override
  void initState() {
    super.initState();
    if (widget.quickActions.isNotEmpty) {
      // Start auto-scroll after first frame to ensure controller has clients
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Center the first item initially
        if (_controller.hasClients) {
          final viewport = _controller.position.viewportDimension;
          if (viewport > 0) {
            final double firstCenter = _centerOffsetForIndex(0, viewport);
            _controller.jumpTo(firstCenter);
          }
        }
        _startAutoScroll();
      });
    }
  }

  void _startAutoScroll() {
    const tick = Duration(seconds: 2);
    const perStep = Duration(milliseconds: 500); // duration per one item step
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) {
      if (!_controller.hasClients) return;

      final int len = widget.quickActions.length;
      if (len <= 1) return; // nothing to auto-scroll

      final double viewport = _controller.position.viewportDimension;
      if (viewport <= 0) return;

      final int nextIndex = (_currentIndex + 1) % len;

      final double targetOffset = _centerOffsetForIndex(nextIndex, viewport);

      // Compute distance-based duration to keep constant speed, especially for wrap to first
      final double currentOffset = _controller.offset;
      final double distance = (targetOffset - currentOffset).abs();
      final double step = _cardWidth + (_cardMargin * 2);
      final int steps = (distance / step).ceil().clamp(1, len);
      final Duration anim = perStep * steps;

      _controller.animateTo(
        targetOffset,
        duration: anim,
        curve: Curves.easeInOut,
      );

      _currentIndex = nextIndex;
    });
  }

  double _centerOffsetForIndex(int i, double viewport) {
    final double step = _cardWidth + (_cardMargin * 2);
    final double itemLeft = _horizontalPadding + _cardMargin + i * step;
    final double itemCenter = itemLeft + _cardWidth / 2;
    double off = itemCenter - viewport / 2;
    final double min = 0;
    final double max = _controller.position.maxScrollExtent;
    if (off < min) off = min;
    if (off > max) off = max;
    return off;
  }

  @override
  void didUpdateWidget(covariant _AutoScrollQuickActionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quickActions.length != widget.quickActions.length) {
      _currentIndex = 0;
      if (_controller.hasClients && _controller.position.hasPixels) {
        final viewport = _controller.position.viewportDimension;
        if (viewport > 0) {
          final double firstCenter = _centerOffsetForIndex(0, viewport);
          _controller.jumpTo(firstCenter);
        } else {
          _controller.jumpTo(0);
        }
      }
      _timer?.cancel();
      if (widget.quickActions.length > 1) {
        _startAutoScroll();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quickActions.isEmpty) {
      return const SizedBox.shrink();
    }
    final int len = widget.quickActions.length;

    return ListView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      itemCount: len,
      itemBuilder: (context, index) {
        final action = widget.quickActions[index];
        return UnifiedActionCard(
          action: action,
          size: widget.size,
          isTablet: widget.isTablet,
          isArabic: widget.isArabic,
        );
      },
    );
  }
}
