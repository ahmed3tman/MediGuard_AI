import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class HomeDialogManager {
  static void showMedicalAnalysisInfo(BuildContext context, bool isArabic) {
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
                    FloatingSnackBar.showInfo(
                      context,
                      message: isArabic
                          ? '🚀 سيتم فتح الكاميرا لتحليل النتائج الطبية'
                          : '🚀 Opening camera for medical analysis',
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

  static void showEmergencyCallDialog(BuildContext context, bool isArabic) {
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
              FloatingSnackBar.showError(
                context,
                message: isArabic
                    ? '📞 جاري الاتصال بالإسعاف...'
                    : '📞 Calling emergency...',
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

  static void showSelfCheckDetails(
    BuildContext context,
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
                        FloatingSnackBar.showSuccess(
                          context,
                          message: isArabic
                              ? 'تم حفظ المعلومات في مفكرتك الصحية'
                              : 'Information saved to your health notes',
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

  static Widget _buildFeatureItem({
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
}
