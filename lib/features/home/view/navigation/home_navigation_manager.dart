import 'package:flutter/material.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class HomeNavigationManager {
  static void navigateToDeviceDetails(BuildContext context, devicePromotion) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    FloatingSnackBar.showInfo(
      context,
      message: isArabic
          ? 'سيتم فتح تفاصيل ${devicePromotion.name.getByLocale(Localizations.localeOf(context).languageCode)}'
          : 'Opening ${devicePromotion.name.getByLocale(Localizations.localeOf(context).languageCode)} details',
    );
  }

  static void navigateToHealthTipDetails(BuildContext context, healthTip) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    FloatingSnackBar.showInfo(
      context,
      message: isArabic
          ? 'سيتم فتح: ${healthTip.title.getByLocale(Localizations.localeOf(context).languageCode)}'
          : 'Opening: ${healthTip.title.getByLocale(Localizations.localeOf(context).languageCode)}',
    );
  }

  static void navigateToAllHealthTips(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    FloatingSnackBar.showInfo(
      context,
      message: isArabic
          ? 'سيتم فتح جميع النصائح الصحية'
          : 'Opening all health tips',
    );
  }

  static void navigateToMedicalAI(BuildContext context, bool isArabic) {
    FloatingSnackBar.showSuccess(
      context,
      message: isArabic
          ? '🤖 سيتم فتح مساعد ميديكال جارد الذكي'
          : '🤖 Opening Medical Guard AI Assistant',
    );
  }

  static void showPrescriptionReaderInfo(BuildContext context, bool isArabic) {
    FloatingSnackBar.showInfo(
      context,
      message: isArabic
          ? '💊 سيتم فتح قارئ الروشتات'
          : '💊 Opening prescription reader',
    );
  }
}
