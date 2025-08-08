import 'package:flutter/material.dart';
import '../../../core/shared/theme/my_colors.dart';
import '../models/health_models.dart';

class HomeDataRepository {
  // Device Promotions data
  static List<DevicePromotion> getDevicePromotions() {
    return [
      DevicePromotion(
        id: 'device_001',
        name: const LocalizedText(
          en: 'Patient Monitoring Device',
          ar: 'جهاز مراقبة المريض',
        ),
        shortDescription: const LocalizedText(
          en: 'Advanced patient monitoring device that tracks patient condition moment by moment.',
          ar: 'جهاز متطور يتابع حالة المريض لحظة بلحظة.',
        ),
        fullDescription: const LocalizedText(
          en: 'Advanced patient monitoring device with real-time tracking capabilities. Features comprehensive vital signs monitoring, intelligent alerts, and seamless connectivity for continuous patient care.',
          ar: 'جهاز مراقبة المريض المتطور مع إمكانيات التتبع اللحظي. يتميز بمراقبة شاملة للعلامات الحيوية وتنبيهات ذكية واتصال سلس للرعاية المستمرة للمريض.',
        ),
        imageAsset: 'assets/images/logo.png',
        features: const LocalizedText(
          en: 'Real-time monitoring|Multi-vital tracking|Smart alerts|Wireless connectivity|Cloud storage',
          ar: 'مراقبة لحظية|تتبع متعدد العلامات الحيوية|تنبيهات ذكية|اتصال لاسلكي|تخزين سحابي',
        ),
        price: const LocalizedText(en: '2999 LE', ar: '2999 جنية'),
        specifications: const LocalizedText(
          en: 'Sensors: Multi-vital|Connectivity: WiFi+Bluetooth|Battery: 48h|Weight: 650g',
          ar: 'أجهزة الاستشعار: متعددة العلامات الحيوية|الاتصال: WiFi+بلوتوث|البطارية: 48 ساعة|الوزن: 650 جرام',
        ),
        warranty: const LocalizedText(
          en: '2 years international warranty',
          ar: 'ضمان دولي لمدة سنتان',
        ),
        isAvailable: true,
      ),
      DevicePromotion(
        id: '1',
        name: LocalizedText(en: 'SmartWatch Pro', ar: 'ساعة ذكية برو'),
        shortDescription: LocalizedText(
          en: 'Advanced health monitoring with AI insights',
          ar: 'مراقبة صحية متقدمة مع رؤى الذكاء الاصطناعي',
        ),
        fullDescription: LocalizedText(
          en: 'Professional-grade smartwatch with comprehensive health monitoring features',
          ar: 'ساعة ذكية احترافية مع ميزات مراقبة صحية شاملة',
        ),
        imageAsset: 'assets/images/logo.png',
        features: LocalizedText(
          en: '• Heart rate monitoring\\n• Sleep tracking\\n• Exercise detection\\n• Emergency alerts',
          ar: '• مراقبة معدل ضربات القلب\\n• تتبع النوم\\n• اكتشاف التمارين\\n• تنبيهات الطوارئ',
        ),
        price: LocalizedText(en: '2999 LE', ar: '2999 جنية'),
        specifications: LocalizedText(
          en: 'Battery: 7 days\\nWater resistant: IP68\\nDisplay: AMOLED',
          ar: 'البطارية: 7 أيام\\nمقاوم للماء: IP68\\nالشاشة: أموليد',
        ),
        warranty: LocalizedText(
          en: '2 years international warranty',
          ar: 'ضمان دولي لمدة سنتين',
        ),
        isAvailable: true,
      ),
    ];
  }

  // Health Tips data
  static List<HealthTip> getHealthTips() {
    return [
      HealthTip(
        id: 'tip_001',
        title: const LocalizedText(
          en: 'Daily Blood Pressure Monitoring',
          ar: 'مراقبة ضغط الدم اليومية',
        ),
        shortDescription: const LocalizedText(
          en: 'Learn the importance of daily blood pressure monitoring and how to do it correctly at home.',
          ar: 'تعلم أهمية مراقبة ضغط الدم يومياً وكيفية القيام بذلك بشكل صحيح في المنزل.',
        ),
        fullContent: const LocalizedText(
          en: '''High blood pressure is called the "silent killer" because it often has no obvious symptoms. Daily blood pressure monitoring at home can save your life.

## Why is daily monitoring important?

**Early Detection**: Helps detect changes before they become dangerous
**Treatment Follow-up**: Ensures the effectiveness of medications used
**Reducing Complications**: Prevents strokes and heart attacks

## How to measure correctly:

1. **Timing**: Measure blood pressure at the same time daily
2. **Position**: Sit upright with back support
3. **Rest**: Rest for 5 minutes before measuring
4. **Arm**: Always use the same arm
5. **Recording**: Keep a daily log of readings

Remember: Regular monitoring + healthy lifestyle = longer and healthier life.''',
          ar: '''يُعتبر ضغط الدم المرتفع "القاتل الصامت" لأنه غالباً ما يكون بدون أعراض واضحة. مراقبة ضغط الدم يومياً في المنزل يمكن أن تنقذ حياتك.

## لماذا المراقبة اليومية مهمة؟

**الكشف المبكر**: يساعد في اكتشاف التغيرات قبل أن تصبح خطيرة
**متابعة العلاج**: يضمن فعالية الأدوية المستخدمة
**تقليل المضاعفات**: يمنع السكتات الدماغية والأزمات القلبية

## كيفية القياس الصحيح:

1. **التوقيت**: قس ضغط الدم في نفس الوقت يومياً
2. **الوضعية**: اجلس مستقيماً مع دعم الظهر
3. **الراحة**: استرح 5 دقائق قبل القياس
4. **الذراع**: استخدم نفس الذراع دائماً
5. **التسجيل**: احتفظ بسجل يومي للقراءات

تذكر: المراقبة المنتظمة + النمط الحياتي الصحي = حياة أطول وأكثر صحة.''',
        ),
        imageAsset:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        category: const LocalizedText(
          en: 'Cardiology',
          ar: 'القلب والأوعية الدموية',
        ),
        categoryColor: AppColors.primaryColor,
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        author: const LocalizedText(
          en: 'Dr. Ahmed Mohamed',
          ar: 'د. أحمد محمد',
        ),
        readingTimeMinutes: 5,
        tags: const LocalizedText(
          en: 'Blood Pressure|Prevention|Home Monitoring',
          ar: 'ضغط الدم|الوقاية|المراقبة المنزلية',
        ),
      ),
      HealthTip(
        id: 'tip_002',
        title: const LocalizedText(
          en: 'Early Warning Signs of Heart Attack',
          ar: 'علامات الإنذار المبكر للنوبة القلبية',
        ),
        shortDescription: const LocalizedText(
          en: 'Learn the early warning signs of heart attack and how to act quickly to save lives.',
          ar: 'تعرف على العلامات التحذيرية المبكرة للنوبة القلبية وكيفية التصرف السريع لإنقاذ الحياة.',
        ),
        fullContent: const LocalizedText(
          en: '''A heart attack is a medical emergency that requires immediate intervention. Knowing the early signs can save your life or the life of someone you love.

## Classic Signs:

### Chest Pain:
- Feeling of pressure or squeezing in the chest
- Pain spreading to arms, back, neck, jaw, or stomach
- May feel like heartburn or indigestion
- Can last more than a few minutes

### Other Warning Signs:
- Shortness of breath
- Cold sweats
- Nausea or vomiting
- Dizziness or lightheadedness
- Unusual fatigue

⚠️ **Remember**: Time is muscle! The faster you act, the more heart muscle can be saved.

Don't ignore the warning signs. When in doubt, seek medical attention immediately.''',
          ar: '''النوبة القلبية حالة طبية طارئة تتطلب تدخلاً فورياً. معرفة العلامات المبكرة يمكن أن تنقذ حياتك أو حياة من تحب.

## العلامات الكلاسيكية:

### ألم الصدر:
- شعور بالضغط أو العصر في الصدر
- ألم ينتشر إلى الذراعين أو الظهر أو الرقبة أو الفك أو المعدة
- قد يشبه حرقة المعدة أو عسر الهضم
- يمكن أن يستمر أكثر من بضع دقائق

### علامات إنذار أخرى:
- ضيق في التنفس
- تعرق بارد
- غثيان أو قيء
- دوخة أو دوار
- تعب غير عادي

⚠️ **تذكر**: الوقت عضلة! كلما تصرفت بسرعة، كلما أمكن إنقاذ المزيد من عضلة القلب.

لا تتجاهل علامات الإنذار. عند الشك، اطلب العناية الطبية فوراً.''',
        ),
        imageAsset:
            'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400',
        category: const LocalizedText(
          en: 'Emergency Medicine',
          ar: 'طوارئ طبية',
        ),
        categoryColor: Colors.red,
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        author: const LocalizedText(
          en: 'Dr. Fatima Ahmed',
          ar: 'د. فاطمة أحمد',
        ),
        readingTimeMinutes: 6,
        tags: const LocalizedText(
          en: 'Heart Attack|Emergency|First Aid',
          ar: 'نوبة قلبية|طوارئ|إسعافات أولية',
        ),
      ),
      HealthTip(
        id: 'tip_003',
        title: const LocalizedText(
          en: 'Understanding ECG Reading Made Simple',
          ar: 'كيفية قراءة تخطيط القلب (ECG) بطريقة مبسطة',
        ),
        shortDescription: const LocalizedText(
          en: 'A simplified guide to understanding ECG results and recognizing normal and abnormal patterns.',
          ar: 'دليل مبسط لفهم نتائج تخطيط القلب والتعرف على الأنماط الطبيعية وغير الطبيعية.',
        ),
        fullContent: const LocalizedText(
          en: '''An ECG (Electrocardiogram) is a simple, painless test that records the electrical activity of your heart. Understanding the basics helps you monitor your heart health.

## What is an ECG?

An ECG records the electrical signals that trigger your heartbeat. These signals travel through your heart in a specific pattern that can reveal important information about your heart's health.

⚠️ **Important**: Always consult healthcare professionals for ECG interpretation. Home devices are for monitoring, not diagnosis.

Remember: ECG is just one tool in heart health assessment.''',
          ar: '''تخطيط القلب (ECG) هو فحص بسيط وغير مؤلم يسجل النشاط الكهربائي للقلب. فهم الأساسيات يساعدك في مراقبة صحة قلبك.

## ما هو تخطيط القلب؟

تخطيط القلب يسجل الإشارات الكهربائية التي تؤدي إلى نبضات القلب. هذه الإشارات تنتقل عبر القلب في نمط محدد يمكن أن يكشف معلومات مهمة عن صحة قلبك.

⚠️ **مهم**: استشر دائماً المهنيين الصحيين لتفسير تخطيط القلب. الأجهزة المنزلية للمراقبة وليس للتشخيص.

تذكر: تخطيط القلب مجرد أداة واحدة في تقييم صحة القلب.''',
        ),
        imageAsset:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        category: const LocalizedText(
          en: 'Medical Diagnosis',
          ar: 'التشخيص الطبي',
        ),
        categoryColor: Colors.blue,
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        author: const LocalizedText(en: 'Dr. Mohamed Ali', ar: 'د. محمد علي'),
        readingTimeMinutes: 8,
        tags: const LocalizedText(
          en: 'ECG|Diagnosis|Monitoring',
          ar: 'تخطيط القلب|التشخيص|المراقبة',
        ),
      ),
    ];
  }
}
