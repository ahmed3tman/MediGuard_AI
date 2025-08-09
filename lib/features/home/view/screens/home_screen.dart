import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/theme/my_colors.dart';
import '../widgets/device_promotion_card.dart';
import '../widgets/health_tip_card.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  Text(
                    isArabic ? 'جاري تحميل البيانات...' : 'Loading data...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 16 : 14,
                      fontFamily: isArabic ? 'NeoSansArabic' : null,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is HomeLoaded) {
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
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? 'مرحباً بك في MediGuard AI'
                                : 'Welcome to MediGuard AI',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            isArabic
                                ? 'رفيقك الذكي لمراقبة وتحليل العلامات الحيوية لحظياً'
                                : 'Your smart companion for real-time health monitoring and analysis',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 14 : 12,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Device Promotion Card
                  SliverToBoxAdapter(
                    child: DevicePromotionCard(
                      devicePromotion: state.devicePromotion,
                      onTap: () {
                        _navigateToDeviceDetails(
                          context,
                          state.devicePromotion,
                        );
                      },
                    ),
                  ),

                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 10 : 8),
                  ),

                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 16 : 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                isArabic
                                    ? 'نفذ مهامك الصحية بسرعة وسهولة'
                                    : 'Perform your health tasks quickly and easily',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: isTablet ? 14 : 13,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Horizontal Quick Actions ScrollView
                        SizedBox(
                          height: isTablet ? 220 : 190,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 12,
                            ),
                            itemCount: quickActions.length,
                            itemBuilder: (context, index) {
                              final action = quickActions[index];
                              if (action.isPrimary) {
                                return _buildMedicalAnalysisCard(
                                  context,
                                  size: size,
                                  isTablet: isTablet,
                                  isArabic: isArabic,
                                  title: action.title,
                                  subtitle: action.subtitle,
                                  onTap: action.onTap,
                                );
                              } else {
                                return _buildQuickActionCard(
                                  context,
                                  size: size,
                                  icon: action.icon,
                                  title: action.title,
                                  subtitle: action.subtitle,
                                  color: action.color,
                                  onTap: action.onTap,
                                  isTablet: isTablet,
                                  isArabic: isArabic,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Spacing After Quick Actions
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 32 : 24),
                  ),

                  // Health Tips Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'نصائح صحية' : 'Health Tips',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                isArabic
                                    ? 'اكتشف معلومات صحية مفيدة'
                                    : 'Discover useful health information',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: isTablet ? 14 : 13,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _navigateToAllHealthTips(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryColor,
                              size: isTablet ? 20 : 18,
                            ),
                            label: Text(
                              isArabic ? 'عرض الكل' : 'View All',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 10 : 8),
                  ),

                  // Health Tips Horizontal List
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: isTablet ? 300 : 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          right: isTablet ? 24 : 16,
                          left: isTablet ? 4 : 0,
                        ),
                        itemCount: state.healthTips.length,
                        itemBuilder: (context, index) {
                          final healthTip = state.healthTips[index];
                          return HealthTipCard(
                            healthTip: healthTip,
                            onTap: () {
                              _navigateToHealthTipDetails(context, healthTip);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Final Bottom Spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 20 : 11),
                  ),

                  // --- Early Self-Check Section ---
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 30 : 24,
                            vertical: isTablet ? 12 : 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? 'اكشف على نفسك مبكرًا'
                                    : 'Early Self-Check',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                              SizedBox(height: isTablet ? 8 : 6),
                              Text(
                                isArabic
                                    ? 'ساعد نفسك في اكتشاف الأمراض الخطيرة مبكرًا مثل سرطان الثدي أو القولون أو الجلد. اتبع هذه الخطوات البسيطة بشكل دوري.'
                                    : 'Help yourself detect serious diseases early, like breast, colon, or skin cancer. Follow these simple steps regularly.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: isTablet ? 12 : 11,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 14 : 10),
                        // Example Cards - Horizontal ScrollView
                        SizedBox(
                          height: isTablet ? 240 : 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 4 : 2,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              final selfCheckData = [
                                {
                                  'icon': Icons.female,
                                  'color': Colors.pinkAccent,
                                  'title': isArabic
                                      ? 'فحص الثدي الذاتي'
                                      : 'Breast Self-Exam',
                                  'description': isArabic
                                      ? 'افحصي ثديك شهريًا أمام المرآة وابحثي عن أي تغييرات في الشكل أو وجود كتل. إذا لاحظتِ شيئًا غير معتاد، استشيري الطبيب فورًا.'
                                      : 'Check your breasts monthly in front of a mirror and look for any changes or lumps. If you notice anything unusual, consult your doctor promptly.',
                                },
                                {
                                  'icon': Icons.wc,
                                  'color': Colors.blueAccent,
                                  'title': isArabic
                                      ? 'فحص القولون المبكر'
                                      : 'Early Colon Check',
                                  'description': isArabic
                                      ? 'راقب وجود دم في البراز أو تغيرات في عادات الإخراج. إذا لاحظت أعراضًا غير معتادة، توجه للطبيب للفحص المبكر.'
                                      : 'Watch for blood in stool or changes in bowel habits. If you notice unusual symptoms, see your doctor for early screening.',
                                },
                                {
                                  'icon': Icons.brightness_5_outlined,
                                  'color': Colors.orangeAccent,
                                  'title': isArabic
                                      ? 'فحص الجلد الذاتي'
                                      : 'Skin Self-Exam',
                                  'description': isArabic
                                      ? 'افحص جسمك بحثًا عن شامات أو بقع جديدة أو متغيرة في اللون أو الشكل. أي تغير سريع يستدعي مراجعة الطبيب.'
                                      : 'Check your body for new or changing moles or spots in color or shape. Any rapid change should be checked by a doctor.',
                                },
                                {
                                  'icon': Icons.favorite_border,
                                  'color': Colors.redAccent,
                                  'title': isArabic
                                      ? 'فحص ضغط الدم'
                                      : 'Blood Pressure Check',
                                  'description': isArabic
                                      ? 'قس ضغط دمك بانتظام، خاصة إذا كان لديك تاريخ عائلي للمرض. الضغط المرتفع قد لا يسبب أعراض واضحة.'
                                      : 'Monitor your blood pressure regularly, especially if you have a family history. High blood pressure may not cause obvious symptoms.',
                                },
                                {
                                  'icon': Icons.visibility_outlined,
                                  'color': const Color.fromARGB(255, 23, 84, 53),
                                  'title': isArabic
                                      ? 'فحص النظر الذاتي'
                                      : 'Vision Self-Check',
                                  'description': isArabic
                                      ? 'اختبر نظرك دورياً بتغطية عين واحدة والنظر للأشياء البعيدة والقريبة. راجع طبيب العيون سنوياً.'
                                      : 'Test your vision regularly by covering one eye and looking at distant and near objects. See an eye doctor annually.',
                                },
                                {
                                  'icon': Icons.monitor_weight_outlined,
                                  'color': Colors.deepPurpleAccent,
                                  'title': isArabic
                                      ? 'مراقبة الوزن'
                                      : 'Weight Monitoring',
                                  'description': isArabic
                                      ? 'راقب وزنك شهرياً وحافظ على مؤشر كتلة جسم صحي. الوزن الزائد قد يؤدي لمشاكل صحية عديدة.'
                                      : 'Monitor your weight monthly and maintain a healthy BMI. Excess weight can lead to numerous health problems.',
                                },
                              ];

                              final item = selfCheckData[index];
                              return Container(
                                width: isTablet ? 320 : 280,
                                margin: EdgeInsets.only(
                                  right: isTablet ? 16 : 12,
                                  left: index == 0 ? (isTablet ? 8 : 4) : 0,
                                ),
                                child: _SelfCheckExampleCard(
                                  icon: item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  title: item['title'] as String,
                                  description: item['description'] as String,
                                  isTablet: isTablet,
                                  isArabic: isArabic,
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
                            onPressed: () {
                              _showSelfCheckReminder(context, isArabic);
                            },
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
                              shadowColor: const Color(
                                0xFF10B981,
                              ).withOpacity(0.4),
                            ),
                            icon: Icon(
                              Icons.schedule_outlined,
                              size: isTablet ? 24 : 20,
                            ),
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
                  ),

                  // Final Bottom Spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 32 : 24),
                  ),

                  // --- Health Awareness Section ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? 'التوعية الصحية'
                                    : 'Health Awareness',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                isArabic
                                    ? 'تعرف على نصائح ومعلومات طبية موثوقة'
                                    : 'Learn trusted medical tips and information',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: isTablet ? 14 : 13,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _navigateToAllHealthTips(context);
                            },
                            icon: Icon(
                              isArabic ? Icons.arrow_forward : Icons.arrow_back,
                              color: AppColors.primaryColor,
                              size: isTablet ? 20 : 18,
                            ),
                            label: Text(
                              isArabic ? 'المزيد' : 'More',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: isTablet ? 14 : 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 10 : 5),
                  ),

                  // --- Suggested New Section: Daily Health Challenge ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 12 : 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 20 : 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_walk_outlined,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 32 : 26,
                            ),
                            SizedBox(width: isTablet ? 18 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'تحدي اليوم الصحي'
                                        : 'Today\'s Health Challenge',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: isArabic
                                          ? 'NeoSansArabic'
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'امشِ 7000 خطوة اليوم لتعزيز نشاطك وصحتك!'
                                        : 'Walk 7,000 steps today to boost your activity and health!',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isTablet ? 13 : 12,
                                      fontFamily: isArabic
                                          ? 'NeoSansArabic'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isArabic
                                          ? 'رائع! استمر في الحركة 🚶‍♂️'
                                          : 'Awesome! Keep moving 🚶‍♂️',
                                      style: TextStyle(
                                        fontFamily: isArabic
                                            ? 'NeoSansArabic'
                                            : null,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 18 : 12,
                                  vertical: isTablet ? 12 : 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isArabic ? 'أنجزت' : 'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 13 : 12,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 12 : 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 20 : 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 32 : 26,
                            ),
                            SizedBox(width: isTablet ? 18 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'تحدي اليوم الصحي'
                                        : 'Today\'s Health Challenge',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: isArabic
                                          ? 'NeoSansArabic'
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'اشرب 8 أكواب ماء اليوم للحفاظ على صحتك!'
                                        : 'Drink 8 glasses of water today to stay healthy!',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isTablet ? 13 : 12,
                                      fontFamily: isArabic
                                          ? 'NeoSansArabic'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isArabic
                                          ? 'أحسنت! استمر في التحدي 💧'
                                          : 'Great! Keep up the challenge 💧',
                                      style: TextStyle(
                                        fontFamily: isArabic
                                            ? 'NeoSansArabic'
                                            : null,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 18 : 12,
                                  vertical: isTablet ? 12 : 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isArabic ? 'أنجزت' : 'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 13 : 12,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Final Bottom Spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 40 : 32),
                  ),
                ],
              ),
            );
          } else if (state is HomeError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.errorColor,
                      size: isTablet ? 80 : 64,
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                    Text(
                      isArabic
                          ? 'حدث خطأ في تحميل البيانات'
                          : 'Error loading data',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: isArabic ? 'NeoSansArabic' : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 16 : 14,
                        fontFamily: isArabic ? 'NeoSansArabic' : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<HomeCubit>().loadHomeData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 24,
                          vertical: isTablet ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.refresh, size: isTablet ? 24 : 20),
                      label: Text(
                        isArabic ? 'إعادة المحاولة' : 'Try Again',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<_QuickAction> _getQuickActions(BuildContext context, bool isArabic) {
    return [
      _QuickAction(
        title: isArabic
            ? 'افهم نتيجة التحليل الطبي'
            : 'Understand Medical Test Results',
        subtitle: isArabic
            ? 'صور ورقة التحليل واحصل على شرح مفصل'
            : 'Capture test paper and get detailed explanation',
        icon: Icons.document_scanner_outlined,
        color: const Color(0xFF6366F1),
        onTap: () => _showMedicalAnalysisInfo(context, isArabic),
        isPrimary: true,
      ),
      _QuickAction(
        title: isArabic ? 'اسأل ميديكال جارد AI' : 'Ask Medical Guard AI',
        subtitle: isArabic
            ? 'استشارة ذكية فورية'
            : 'Instant Smart Consultation',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF10B981),
        onTap: () => _navigateToMedicalAI(context, isArabic),
      ),
      _QuickAction(
        title: isArabic ? 'اقرأ الروشتة' : 'Read Prescription',
        subtitle: isArabic
            ? 'فهم الأدوية بالذكاء الاصطناعي'
            : 'AI Medicine Understanding',
        icon: Icons.local_pharmacy_outlined,
        color: const Color(0xFF8B5CF6),
        onTap: () => _showPrescriptionReaderInfo(context, isArabic),
      ),
      _QuickAction(
        title: isArabic ? 'اتصل بالإسعاف' : 'Call Emergency',
        subtitle: isArabic ? 'طوارئ 123' : 'Emergency 123',
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFEF4444),
        onTap: () => _showEmergencyCallInfo(context, isArabic),
      ),
    ];
  }

  void _navigateToDeviceDetails(context, devicePromotion) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // : Navigate to device details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'سيتم فتح تفاصيل ${devicePromotion.name.getByLocale(Localizations.localeOf(context).languageCode)}'
              : 'Opening ${devicePromotion.name.getByLocale(Localizations.localeOf(context).languageCode)} details',
          style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _navigateToHealthTipDetails(context, healthTip) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // : Navigate to health tip details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'سيتم فتح: ${healthTip.title.getByLocale(Localizations.localeOf(context).languageCode)}'
              : 'Opening: ${healthTip.title.getByLocale(Localizations.localeOf(context).languageCode)}',
          style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _navigateToAllHealthTips(context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // : Navigate to all health tips screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'سيتم فتح جميع النصائح الصحية' : 'Opening all health tips',
          style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  // Quick Action Card Builder
  Widget _buildQuickActionCard(
    BuildContext context, {
    required Size size,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isArabic,
  }) {
    return Container(
      width: isTablet ? 280 : 250,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            // boxShadow: [
            //   BoxShadow(
            //     color: color.withOpacity(0.15),
            //     blurRadius: 20,
            //     offset: const Offset(0, 6),
            //     spreadRadius: 0,
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(painter: AIPatternPainter(color)),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // NEW Badge at the top
                  Row(
                    children: [
                      // Icon on the left
                      Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color.withOpacity(0.15),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isArabic
                                ? Alignment.topLeft
                                : Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isArabic ? 'جديد' : 'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 9 : 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            isArabic ? 'ذكاء اصطناعي' : 'AI Assistant',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // Main content row with icon and text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text content on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: isTablet ? 6 : 4),

                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 11 : 10,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 18 : 16),

                  // Action Button
                  Container(
                    alignment: Alignment.center,
                    width:
                        (isTablet ? 280 : 250) - 4, // Reduce width by 4 pixels
                    height: isTablet ? 42 : 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.85)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: onTap,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                color: Colors.white,
                                size: isTablet ? 15 : 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isArabic ? 'جرب الآن' : 'Try Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 12 : 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Special Medical Analysis Card
  Widget _buildMedicalAnalysisCard(
    BuildContext context, {
    required Size size,
    required bool isTablet,
    required bool isArabic,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF6366F1); // Modern purple

    return Container(
      width: isTablet ? 280 : 250,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.12),
                primaryColor.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
            // boxShadow: [
            //   BoxShadow(
            //     color: primaryColor.withOpacity(0.15),
            //     blurRadius: 20,
            //     offset: const Offset(0, 6),
            //     spreadRadius: 0,
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(painter: AIPatternPainter(primaryColor)),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  // NEW Badge at the top
                  Row(
                    children: [
                      // Icon on the left
                      Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor.withOpacity(0.15),
                          //shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.document_scanner_outlined,
                          color: primaryColor,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isArabic
                                ? Alignment.topLeft
                                : Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isArabic ? 'جديد' : 'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 9 : 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            isArabic ? 'ذكاء اصطناعي' : 'AI Assistant',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                        ],
                      ),

                      // AI text
                    ],
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // Main content row with icon and text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text content on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: isTablet ? 6 : 4),

                            // Subtitle
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 11 : 10,
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 18 : 16),

                  // Action Button
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      width:
                          (isTablet ? 280 : 250) -
                          4, // Reduce width by 4 pixels
                      height: isTablet ? 36 : 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.85),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: onTap,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: isTablet ? 15 : 13,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? 'جرب الآن' : 'Try Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 12 : 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: isArabic
                                        ? 'NeoSansArabic'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation functions
  void _navigateToMedicalAI(BuildContext context, bool isArabic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? '🤖 سيتم فتح مساعد ميديكال جارد الذكي'
              : '🤖 Opening Medical Guard AI Assistant',
          style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMedicalAnalysisInfo(BuildContext context, bool isArabic) {
    const primaryColor = Color(0xFF6366F1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_outlined,
                  color: primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ).createShader(bounds),
                child: Text(
                  isArabic
                      ? 'تحليل النتائج الطبية بالذكاء الاصطناعي'
                      : 'AI Medical Results Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                isArabic
                    ? 'تقنية متطورة لفهم تحاليلك الطبية في ثوانٍ معدودة'
                    : 'Advanced technology to understand your medical tests in seconds',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Features
              _buildFeatureItem(
                icon: Icons.camera_enhance_outlined,
                title: isArabic ? 'التصوير الذكي' : 'Smart Camera',
                description: isArabic
                    ? 'صور ورقة التحليل بوضوح عالي للحصول على أفضل النتائج'
                    : 'Capture test papers in high definition for best results',
                color: const Color(0xFF10B981),
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(
                icon: Icons.psychology_alt_outlined,
                title: isArabic ? 'تحليل متقدم' : 'Advanced Analysis',
                description: isArabic
                    ? 'الذكاء الاصطناعي المتطور يحلل النتائج ويفسرها بدقة طبية عالية'
                    : 'Advanced AI analyzes and interprets results with high medical accuracy',
                color: primaryColor,
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(
                icon: Icons.insights_outlined,
                title: isArabic ? 'نتائج فورية' : 'Instant Results',
                description: isArabic
                    ? 'احصل على شرح شامل ونصائح طبية في ثوانٍ'
                    : 'Get comprehensive explanations and medical advice in seconds',
                color: const Color(0xFFF59E0B),
                isArabic: isArabic,
              ),
              const SizedBox(height: 32),

              // Action button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? '🚀 سيتم فتح الكاميرا لتحليل النتائج الطبية'
                              : '🚀 Opening camera for medical analysis',
                          style: TextStyle(
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 22),
                  label: Text(
                    isArabic ? 'ابدأ التحليل الآن' : 'Start Analysis Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: isArabic ? 'NeoSansArabic' : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrescriptionReaderInfo(BuildContext context, bool isArabic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? '💊 سيتم فتح قارئ الروشتات'
              : '💊 Opening prescription reader',
          style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEmergencyCallInfo(BuildContext context, bool isArabic) {
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
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: Color(0xFFEF4444),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic ? 'اتصال طوارئ' : 'Emergency Call',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل تريد الاتصال بالإسعاف؟\nرقم الطوارئ: 123'
              : 'Do you want to call emergency services?\nEmergency number: 123',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontFamily: isArabic ? 'NeoSansArabic' : null,
          ),
          textAlign: TextAlign.center,
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? '📞 جاري الاتصال بالإسعاف...'
                        : '📞 Calling emergency...',
                    style: TextStyle(
                      fontFamily: isArabic ? 'NeoSansArabic' : null,
                    ),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.phone, size: 20),
            label: Text(
              isArabic ? 'اتصل الآن' : 'Call Now',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isArabic,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Self Check Example Card Widget
  Widget _SelfCheckExampleCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isTablet,
    required bool isArabic,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority Badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 14 : 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: isTablet ? 32 : 28),
                    ),

                    SizedBox(width: isTablet ? 10 : 8),

                    // Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? 'مهم' : 'Important',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 11 : 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 8 : 6),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14 : 13,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isTablet ? 12 : 10),

                // Action Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showSelfCheckDetails(
                            title,
                            description,
                            color,
                            isArabic,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withOpacity(0.15),
                          foregroundColor: color,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 12 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.info_outline,
                          size: isTablet ? 18 : 16,
                        ),
                        label: Text(
                          isArabic ? 'تفاصيل أكثر' : 'Learn More',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic
                                  ? 'تم إضافة التذكير لـ $title'
                                  : 'Reminder added for $title',
                              style: TextStyle(
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                              ),
                            ),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: color,
                        size: isTablet ? 24 : 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: color.withOpacity(0.1),
                        padding: EdgeInsets.all(isTablet ? 12 : 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show Self Check Details Function
  void _showSelfCheckDetails(
    String title,
    String description,
    Color color,
    bool isArabic,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: isArabic ? 'NeoSansArabic' : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 20),
                      label: Text(
                        isArabic ? 'إغلاق' : 'Close',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic
                                  ? 'تم حفظ المعلومات في مفكرتك الصحية'
                                  : 'Information saved to your health notes',
                              style: TextStyle(
                                fontFamily: isArabic ? 'NeoSansArabic' : null,
                              ),
                            ),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bookmark_add, size: 20),
                      label: Text(
                        isArabic ? 'حفظ' : 'Save',
                        style: TextStyle(
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Self Check Reminder Function
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'تم تفعيل التذكير $title بنجاح!'
                    : '$title reminder activated successfully!',
                style: TextStyle(fontFamily: isArabic ? 'NeoSansArabic' : null),
              ),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });
}

// AI Pattern Painter for background effects
class AIPatternPainter extends CustomPainter {
  final Color color;

  AIPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle grid pattern
    for (int i = 0; i < 15; i++) {
      final y = (size.height / 15) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 0; i < 12; i++) {
      final x = (size.width / 12) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Add decorative dots
    final nodePaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x = (size.width / 6) * i + 15;
      final y = (size.height / 4) * (i % 4) + 10;
      canvas.drawCircle(Offset(x, y), 1.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
