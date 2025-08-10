import 'package:flutter/material.dart';
import '../section_header.dart';
import '../health_tip_card.dart';
import '../../navigation/home_navigation_manager.dart';

class HealthTipsSection extends StatelessWidget {
  final List<dynamic> healthTips;
  final bool isTablet;
  final bool isArabic;

  const HealthTipsSection({
    super.key,
    required this.healthTips,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: isTablet ? 32 : 24),

          // Section Header
          SectionHeader(
            title: isArabic ? 'نصائح صحية' : 'Health Tips',
            subtitle: isArabic
                ? 'اكتشف معلومات صحية مفيدة'
                : 'Discover useful health information',
            buttonText: isArabic ? 'عرض الكل' : 'View All',
            onButtonPressed: () =>
                HomeNavigationManager.navigateToAllHealthTips(context),
            isTablet: isTablet,
            isArabic: isArabic,
          ),

          SizedBox(height: isTablet ? 10 : 8),

          // Horizontal List
          SizedBox(
            height: isTablet ? 300 : 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                right: isTablet ? 24 : 16,
                left: isTablet ? 16 : 8,
              ),
              itemCount: healthTips.length,
              itemBuilder: (context, index) {
                final healthTip = healthTips[index];
                return HealthTipCard(
                  healthTip: healthTip,
                  onTap: () => HomeNavigationManager.navigateToHealthTipDetails(
                    context,
                    healthTip,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
