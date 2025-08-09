import 'package:flutter/material.dart';
import '../../models/quick_action_model.dart';

class QuickActionsData {
  static List<QuickActionModel> getQuickActions(
    BuildContext context,
    bool isArabic, {
    required VoidCallback onMedicalAnalysisPressed,
    required VoidCallback onMedicalAIPressed,
    required VoidCallback onPrescriptionPressed,
    required VoidCallback onEmergencyPressed,
  }) {
    return [
      QuickActionModel(
        title: isArabic
            ? 'افهم نتيجة التحليل الطبي'
            : 'Understand Medical Test Results',
        subtitle: isArabic
            ? 'صور ورقة التحليل واحصل على شرح مفصل'
            : 'Capture test paper and get detailed explanation',
        icon: Icons.document_scanner_outlined,
        color: const Color(0xFF6366F1),
        onTap: onMedicalAnalysisPressed,
        isPrimary: true,
        isEnabled: true,
        hasAI: true,
        isNew: true,
        buttonText: isArabic ? 'جرب الآن' : 'Try Now',
        buttonIcon: Icons.camera_alt_outlined,
      ),
      QuickActionModel(
        title: isArabic ? 'اسأل MediGuard AI' : 'Ask MediGuard AI',
        subtitle: isArabic
            ? 'استشارة ذكية فورية'
            : 'Instant Smart Consultation',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF10B981),
        onTap: onMedicalAIPressed,
        isEnabled: true, // معطل لأنه ليس جديد
        hasAI: true,
        isNew: false,
        buttonText: isArabic ? 'تحدث معه' : 'Chat Now',
        buttonIcon: Icons.chat_outlined,
      ),
      QuickActionModel(
        title: isArabic ? 'اقرأ الروشتة' : 'Read Prescription',
        subtitle: isArabic
            ? 'فهم الأدوية بالذكاء الاصطناعي'
            : 'AI Medicine Understanding',
        icon: Icons.local_pharmacy_outlined,
        color: const Color(0xFF8B5CF6),
        onTap: onPrescriptionPressed,
        isEnabled: true,
        hasAI: true,
        isNew: true,
        buttonText: isArabic ? 'اقرأ الآن' : 'Read Now',
        buttonIcon: Icons.camera_alt_outlined,
      ),
      QuickActionModel(
        title: isArabic ? 'اتصل بالإسعاف' : 'Call Emergency',
        subtitle: isArabic ? 'طوارئ 123' : 'Emergency 123',
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFEF4444),
        onTap: onEmergencyPressed,
        isEnabled: true,
        hasAI: false, // لا يحتوي على ذكاء اصطناعي
        isNew: false,
        buttonText: isArabic ? 'اتصال فوري' : 'Call Now',
        buttonIcon: Icons.phone_outlined,
      ),
    ];
  }
}
