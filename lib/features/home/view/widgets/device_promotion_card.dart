import 'package:flutter/material.dart';
import '../../models/health_models.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../../buy_your_device/view/screens/buy_ur_device_screen.dart';

class DevicePromotionCard extends StatelessWidget {
  final DevicePromotion devicePromotion;
  final VoidCallback? onTap;

  const DevicePromotionCard({
    super.key,
    required this.devicePromotion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale.startsWith('ar');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 12,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF4facfe)],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: isTablet ? 28 : 24,
                        height: isTablet ? 28 : 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'جهاز MediGuard Pro'
                            : 'MediGuard Pro Device',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isArabic ? 'حصريًا' : 'Exclusive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: isArabic ? 'NeoSansArabic' : null,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 10 : 6),

                // Device Title
                Text(
                  devicePromotion.name.getByLocale(locale),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: isTablet ? 8 : 6),

                // Description
                Text(
                  devicePromotion.shortDescription.getByLocale(locale),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 13 : 11,
                    height: 1.3,
                    fontFamily: isArabic ? 'NeoSansArabic' : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isTablet ? 12 : 8),

                // Features Row
                Row(
                  children: [
                    _buildFeatureIcon(
                      Icons.monitor_heart,
                      isArabic ? 'مراقبة لحظية' : 'Real-time Monitoring',
                      isTablet,
                      isArabic,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildFeatureIcon(
                      Icons.wifi,
                      isArabic ? 'اتصال لاسلكي' : 'Wireless',
                      isTablet,
                      isArabic,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildFeatureIcon(
                      Icons.notifications_active,
                      isArabic ? 'تنبيهات ذكية' : 'Smart Alerts',
                      isTablet,
                      isArabic,
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 12 : 8),

                // Price and CTA Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'السعر' : 'Price',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isTablet ? 14 : 12,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          devicePromotion.price.getByLocale(locale),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                      ],
                    ),

                    // CTA Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BuyDeviceScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 20,
                              vertical: isTablet ? 16 : 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isArabic ? 'اطلب الآن' : 'Order Now',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: isArabic
                                        ? 'NeoSansArabic'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isArabic
                                      ? Icons.arrow_back
                                      : Icons.arrow_forward,
                                  color: AppColors.primaryColor,
                                  size: isTablet ? 20 : 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Warranty Info
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: isTablet ? 18 : 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          devicePromotion.warranty.getByLocale(locale),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 14 : 12,
                            fontFamily: isArabic ? 'NeoSansArabic' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(
    IconData icon,
    String label,
    bool isTablet,
    bool isArabic,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 8 : 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: isTablet ? 20 : 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isTablet ? 10 : 8,
            fontFamily: isArabic ? 'NeoSansArabic' : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
