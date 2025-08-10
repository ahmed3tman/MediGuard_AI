import 'package:flutter/material.dart';
import '../../../../../core/shared/theme/my_colors.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';
import '../section_header.dart';
import '../self_check_card.dart';
import '../../../data/constants/self_check_data.dart';
import '../../dialogs/home_dialog_manager.dart';

class SelfCheckSection extends StatelessWidget {
  final bool isTablet;
  final bool isArabic;

  const SelfCheckSection({
    super.key,
    required this.isTablet,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
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
                  context,
                  isArabic ? 'أسبوعياً' : 'Weekly',
                  Icons.calendar_view_week,
                  const Color(0xFF10B981),
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildReminderOption(
                  context,
                  isArabic ? 'شهرياً' : 'Monthly',
                  Icons.calendar_month,
                  const Color(0xFF3B82F6),
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildReminderOption(
                  context,
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
    BuildContext context,
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
