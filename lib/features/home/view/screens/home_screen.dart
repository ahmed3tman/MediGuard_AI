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
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                          SizedBox(height: isTablet ? 8 : 6),
                          Text(
                            isArabic
                                ? 'رفيقك الذكي لمراقبة وتحليل العلامات الحيوية لحظياً'
                                : 'Your smart companion for real-time health monitoring and analysis',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16 : 14,
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
                                    ? 'معلومات قيمة لحياة صحية أفضل'
                                    : 'Valuable information for a healthier life',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: isTablet ? 14 : 12,
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
                    child: SizedBox(height: isTablet ? 20 : 16),
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

                  // Bottom Spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: isTablet ? 32 : 24),
                  ),

                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: isArabic ? 'NeoSansArabic' : null,
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  icon: Icons.monitor_heart,
                                  title: isArabic ? 'فحص القلب' : 'Heart Check',
                                  subtitle: isArabic
                                      ? 'مراقبة فورية'
                                      : 'Instant monitoring',
                                  color: AppColors.heartRateColor,
                                  onTap: () {
                                    // Navigate to heart monitoring
                                  },
                                  isTablet: isTablet,
                                  isArabic: isArabic,
                                ),
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  icon: Icons.emergency,
                                  title: isArabic ? 'طوارئ' : 'Emergency',
                                  subtitle: isArabic
                                      ? 'اتصال سريع'
                                      : 'Quick call',
                                  color: AppColors.errorColor,
                                  onTap: () {
                                    // Emergency action
                                  },
                                  isTablet: isTablet,
                                  isArabic: isArabic,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isArabic,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: isTablet ? 32 : 28),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 12 : 11,
                fontFamily: isArabic ? 'NeoSansArabic' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDeviceDetails(context, devicePromotion) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // TODO: Navigate to device details screen
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
    // TODO: Navigate to health tip details screen
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
    // TODO: Navigate to all health tips screen
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
}
