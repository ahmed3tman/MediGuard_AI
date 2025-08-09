import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';

class HomeNavigationManager {
  static void navigateToDeviceDetails(BuildContext context, devicePromotion) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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

  static void navigateToHealthTipDetails(BuildContext context, healthTip) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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

  static void navigateToAllHealthTips(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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

  static void navigateToMedicalAI(BuildContext context, bool isArabic) {
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

  static void showPrescriptionReaderInfo(BuildContext context, bool isArabic) {
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
}
