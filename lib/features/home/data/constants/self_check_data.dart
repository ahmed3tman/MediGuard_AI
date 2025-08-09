import 'package:flutter/material.dart';
import '../../models/self_check_model.dart';

class SelfCheckData {
  static List<SelfCheckModel> getSelfCheckData(bool isArabic) {
    return [
      SelfCheckModel(
        icon: Icons.female,
        color: Colors.pinkAccent,
        title: isArabic ? 'فحص الثدي الذاتي' : 'Breast Self-Exam',
        description: isArabic
            ? 'افحصي ثديك شهريًا أمام المرآة وابحثي عن أي تغييرات في الشكل أو وجود كتل. إذا لاحظتِ شيئًا غير معتاد، استشيري الطبيب فورًا.'
            : 'Check your breasts monthly in front of a mirror and look for any changes or lumps. If you notice anything unusual, consult your doctor promptly.',
      ),
      SelfCheckModel(
        icon: Icons.wc,
        color: Colors.blueAccent,
        title: isArabic ? 'فحص القولون المبكر' : 'Early Colon Check',
        description: isArabic
            ? 'راقب وجود دم في البراز أو تغيرات في عادات الإخراج. إذا لاحظت أعراضًا غير معتادة، توجه للطبيب للفحص المبكر.'
            : 'Watch for blood in stool or changes in bowel habits. If you notice unusual symptoms, see your doctor for early screening.',
      ),
      SelfCheckModel(
        icon: Icons.brightness_5_outlined,
        color: Colors.orangeAccent,
        title: isArabic ? 'فحص الجلد الذاتي' : 'Skin Self-Exam',
        description: isArabic
            ? 'افحص جسمك بحثًا عن شامات أو بقع جديدة أو متغيرة في اللون أو الشكل. أي تغير سريع يستدعي مراجعة الطبيب.'
            : 'Check your body for new or changing moles or spots in color or shape. Any rapid change should be checked by a doctor.',
      ),
      SelfCheckModel(
        icon: Icons.favorite_border,
        color: Colors.redAccent,
        title: isArabic ? 'فحص ضغط الدم' : 'Blood Pressure Check',
        description: isArabic
            ? 'قس ضغط دمك بانتظام، خاصة إذا كان لديك تاريخ عائلي للمرض. الضغط المرتفع قد لا يسبب أعراض واضحة.'
            : 'Monitor your blood pressure regularly, especially if you have a family history. High blood pressure may not cause obvious symptoms.',
      ),
      SelfCheckModel(
        icon: Icons.visibility_outlined,
        color: const Color.fromARGB(255, 23, 84, 53),
        title: isArabic ? 'فحص النظر الذاتي' : 'Vision Self-Check',
        description: isArabic
            ? 'اختبر نظرك دورياً بتغطية عين واحدة والنظر للأشياء البعيدة والقريبة. راجع طبيب العيون سنوياً.'
            : 'Test your vision regularly by covering one eye and looking at distant and near objects. See an eye doctor annually.',
      ),
      SelfCheckModel(
        icon: Icons.monitor_weight_outlined,
        color: Colors.deepPurpleAccent,
        title: isArabic ? 'مراقبة الوزن' : 'Weight Monitoring',
        description: isArabic
            ? 'راقب وزنك شهرياً وحافظ على مؤشر كتلة جسم صحي. الوزن الزائد قد يؤدي لمشاكل صحية عديدة.'
            : 'Monitor your weight monthly and maintain a healthy BMI. Excess weight can lead to numerous health problems.',
      ),
    ];
  }
}
