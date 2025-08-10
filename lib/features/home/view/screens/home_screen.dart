import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/theme/my_colors.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/sections/welcome_section.dart';
import '../widgets/sections/device_promotion_section.dart';
import '../widgets/sections/quick_actions_section.dart';
import '../widgets/sections/health_tips_section.dart';
import '../widgets/sections/self_check_section.dart';
import '../widgets/sections/daily_challenges_section.dart';
import '../widgets/sections/health_awareness_section.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import '../../data/constants/quick_actions_data.dart';
import '../dialogs/home_dialog_manager.dart';
import '../navigation/home_navigation_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale.startsWith('ar');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return LoadingStateWidget(isTablet: isTablet, isArabic: isArabic);
          } else if (state is HomeLoaded) {
            return _buildLoadedContent(
              context,
              state,
              size,
              isTablet,
              isArabic,
            );
          } else if (state is HomeError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
              isTablet: isTablet,
              isArabic: isArabic,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    HomeLoaded state,
    Size size,
    bool isTablet,
    bool isArabic,
  ) {
    final quickActions = _getQuickActions(context, isArabic);

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
      color: AppColors.primaryColor,
      backgroundColor: AppColors.surfaceColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Welcome Section
          WelcomeSectionWrapper(isTablet: isTablet, isArabic: isArabic),

          // Device Promotion Card
          DevicePromotionSection(devicePromotion: state.devicePromotion),

          // Quick Actions Section
          QuickActionsSection(
            size: size,
            isTablet: isTablet,
            isArabic: isArabic,
            quickActions: quickActions,
          ),

          // Health Tips Section
          HealthTipsSection(
            healthTips: state.healthTips,
            isTablet: isTablet,
            isArabic: isArabic,
          ),

          // Self-Check Section
          SelfCheckSection(isTablet: isTablet, isArabic: isArabic),

          // Daily Challenges Section
          DailyChallengesSection(isTablet: isTablet, isArabic: isArabic),

          // Health Awareness Section
          HealthAwarenessSection(isTablet: isTablet, isArabic: isArabic),

          // Final Bottom Spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 40 : 32)),
        ],
      ),
    );
  }

  List<dynamic> _getQuickActions(BuildContext context, bool isArabic) {
    return QuickActionsData.getQuickActions(
      context,
      isArabic,
      onMedicalAnalysisPressed: () =>
          HomeDialogManager.showMedicalAnalysisInfo(context, isArabic),
      onMedicalAIPressed: () =>
          HomeNavigationManager.navigateToMedicalAI(context, isArabic),
      onPrescriptionPressed: () =>
          HomeNavigationManager.showPrescriptionReaderInfo(context, isArabic),
      onEmergencyPressed: () =>
          HomeDialogManager.showEmergencyCallDialog(context, isArabic),
    );
  }
}
