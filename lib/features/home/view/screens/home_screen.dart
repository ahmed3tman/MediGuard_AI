import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/theme/my_colors.dart';
import '../../../../core/shared/widgets/floating_snackbar.dart';
import '../widgets/device_promotion_card.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/welcome_section.dart';
import '../widgets/section_header.dart';
import '../widgets/unified_action_card.dart';
import '../widgets/self_check_card.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import '../../data/constants/quick_actions_data.dart';
import '../../data/constants/self_check_data.dart';
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
          SliverToBoxAdapter(
            child: WelcomeSection(isTablet: isTablet, isArabic: isArabic),
          ),

          // Device Promotion Card
          SliverToBoxAdapter(
            child: DevicePromotionCard(
              devicePromotion: state.devicePromotion,
              onTap: () => HomeNavigationManager.navigateToDeviceDetails(
                context,
                state.devicePromotion,
              ),
            ),
          ),

          // Quick Actions Section
          _buildQuickActionsSection(size, isTablet, isArabic, quickActions),

          // Health Tips Section
          _buildHealthTipsSection(context, state, isTablet, isArabic),

          // Self-Check Section
          _buildSelfCheckSection(context, isTablet, isArabic),

          // Daily Challenges Section
          _buildDailyChallengesSection(isTablet, isArabic),

          // Health Awareness Section
          _buildHealthAwarenessSection(context, isTablet, isArabic),

          // Final Bottom Spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 40 : 32)),
        ],
      ),
    );
  }

  //======================================================================================================
  //======================================================================================================
  //======================================================================================================

  Widget _buildQuickActionsSection(
    Size size,
    bool isTablet,
    bool isArabic,
    List<dynamic> quickActions,
  ) {
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

          // Horizontal ScrollView
          SizedBox(
            height: isTablet ? 220 : 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return UnifiedActionCard(
                  action: action,
                  size: size,
                  isTablet: isTablet,
                  isArabic: isArabic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipsSection(
    BuildContext context,
    HomeLoaded state,
    bool isTablet,
    bool isArabic,
  ) {
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
              itemCount: state.healthTips.length,
              itemBuilder: (context, index) {
                final healthTip = state.healthTips[index];
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

  Widget _buildSelfCheckSection(
    BuildContext context,
    bool isTablet,
    bool isArabic,
  ) {
    final selfCheckData = SelfCheckData.getSelfCheckData(isArabic);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: isTablet ? 20 : 11),

          // Section Header
          SectionHeader(
            title: isArabic ? 'اكشف على نفسك مبكرًا' : 'Early Self-Check',
            subtitle: isArabic
                ? 'ساعد نفسك في اكتشاف الأمراض الخطيرة مبكرًا مثل سرطان الثدي أو القولون أو الجلد. اتبع هذه الخطوات البسيطة بشكل دوري.'
                : 'Help yourself detect serious diseases early, like breast, colon, or skin cancer. Follow these simple steps regularly.',
            isTablet: isTablet,
            isArabic: isArabic,
            showButton: false,
          ),

          SizedBox(height: isTablet ? 14 : 10),

          // Horizontal ScrollView
          SizedBox(
            height: isTablet ? 240 : 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10),
              itemCount: selfCheckData.length,
              itemBuilder: (context, index) {
                final selfCheck = selfCheckData[index];
                return Container(
                  width: isTablet ? 320 : 280,
                  margin: EdgeInsets.only(
                    right: isTablet ? 16 : 12,
                    left: index == 0 ? (isTablet ? 8 : 4) : 0,
                  ),
                  child: SelfCheckCard(
                    selfCheck: selfCheck,
                    isTablet: isTablet,
                    isArabic: isArabic,
                    onDetailsPressed: () =>
                        HomeDialogManager.showSelfCheckDetails(
                          context,
                          selfCheck.title,
                          selfCheck.description,
                          selfCheck.color,
                          isArabic,
                        ),
                    onReminderPressed: () => _showReminderAddedMessage(
                      context,
                      selfCheck.title,
                      selfCheck.color,
                      isArabic,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Call-to-Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () => _showSelfCheckReminder(context, isArabic),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF10B981).withOpacity(0.4),
              ),
              icon: Icon(Icons.schedule_outlined, size: isTablet ? 24 : 20),
              label: Text(
                isArabic
                    ? 'تفعيل تذكير الفحص الدوري'
                    : 'Set Periodic Check Reminder',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengesSection(bool isTablet, bool isArabic) {
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

  Widget _buildHealthAwarenessSection(
    BuildContext context,
    bool isTablet,
    bool isArabic,
  ) {
    return SliverToBoxAdapter(child: SizedBox(height: isTablet ? 20 : 16));
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

  void _showReminderAddedMessage(
    BuildContext context,
    String title,
    Color color,
    bool isArabic,
  ) {
    FloatingSnackBar.showSuccess(
      context,
      message: isArabic
          ? 'تم إضافة التذكير لـ $title'
          : 'Reminder added for $title',
    );
  }

  void _showSelfCheckReminder(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_outlined,
                color: Color(0xFF10B981),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic ? 'تذكير الفحص الدوري' : 'Periodic Check Reminder',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'اختر تكرار التذكير للفحوصات الذاتية المنتظمة:'
                  : 'Choose reminder frequency for regular self-checks:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildReminderOption(
                  isArabic ? 'أسبوعياً' : 'Weekly',
                  Icons.calendar_view_week,
                  const Color(0xFF10B981),
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildReminderOption(
                  isArabic ? 'شهرياً' : 'Monthly',
                  Icons.calendar_month,
                  const Color(0xFF3B82F6),
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildReminderOption(
                  isArabic ? 'كل 3 أشهر' : 'Every 3 Months',
                  Icons.event_repeat,
                  const Color(0xFF8B5CF6),
                  isArabic,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderOption(
    String title,
    IconData icon,
    Color color,
    bool isArabic,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          FloatingSnackBar.showSuccess(
            context,
            message: isArabic
                ? 'تم تفعيل التذكير $title بنجاح!'
                : '$title reminder activated successfully!',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: isArabic ? 'NeoSansArabic' : null,
          ),
        ),
      ),
    );
  }
}
