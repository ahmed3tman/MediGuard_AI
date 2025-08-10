import 'package:flutter/material.dart';
import '../section_header.dart';
import '../daily_challenge_card.dart';
import '../../navigation/home_navigation_manager.dart';

class DailyChallengesSection extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const DailyChallengesSection({
    super.key,
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
            title: isArabic ? 'التوعية الصحية' : 'Health Awareness',
            subtitle: isArabic
                ? 'تعرف على نصائح ومعلومات طبية موثوقة'
                : 'Learn trusted medical tips and information',
            buttonText: isArabic ? 'المزيد' : 'More',
            onButtonPressed: () =>
                HomeNavigationManager.navigateToAllHealthTips(context),
            isTablet: isTablet,
            isArabic: isArabic,
          ),

          SizedBox(height: isTablet ? 10 : 5),

          // Daily Challenges
          DailyChallengeCard(
            icon: Icons.directions_walk_outlined,
            title: isArabic ? 'تحدي اليوم الصحي' : 'Today\'s Health Challenge',
            description: isArabic
                ? 'امشِ 7000 خطوة اليوم لتعزيز نشاطك وصحتك!'
                : 'Walk 7,000 steps today to boost your activity and health!',
            buttonText: isArabic ? 'أنجزت' : 'Done',
            successMessage: isArabic
                ? 'رائع! استمر في الحركة 🚶‍♂️'
                : 'Awesome! Keep moving 🚶‍♂️',
            isTablet: isTablet,
            isArabic: isArabic,
          ),

          DailyChallengeCard(
            icon: Icons.emoji_events_outlined,
            title: isArabic ? 'تحدي اليوم الصحي' : 'Today\'s Health Challenge',
            description: isArabic
                ? 'اشرب 8 أكواب ماء اليوم للحفاظ على صحتك!'
                : 'Drink 8 glasses of water today to stay healthy!',
            buttonText: isArabic ? 'أنجزت' : 'Done',
            successMessage: isArabic
                ? 'أحسنت! استمر في التحدي 💧'
                : 'Great! Keep up the challenge 💧',
            isTablet: isTablet,
            isArabic: isArabic,
          ),
        ],
      ),
    );
  }
}
