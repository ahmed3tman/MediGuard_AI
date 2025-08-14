class MedicalNutritionGuide {
  /// Build nutrition recommendations based on patient data and known conditions
  static String recommend(Map<String, dynamic> patientData, bool isArabic) {
    final double temperature =
        (patientData['temperature'] as num?)?.toDouble() ?? 0.0;
    final Map<String, dynamic> bp =
        (patientData['bloodPressure'] as Map<String, dynamic>?) ?? const {};
    final int systolic = (bp['systolic'] as num?)?.toInt() ?? 0;
    final int diastolic = (bp['diastolic'] as num?)?.toInt() ?? 0;
    final double spo2 = (patientData['spo2'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> chronic =
        (patientData['chronicDiseases'] as List?) ?? const [];
    final String? notes = patientData['notes'] as String?;

    final List<String> doList = [];
    final List<String> avoidList = [];

    // General healthy diet
    if (isArabic) {
      doList.addAll([
        'خضروات وفواكه طازجة متنوعة',
        'حبوب كاملة (شوفان، برغل، خبز أسمر)',
        'بروتينات خفيفة (سمك، دجاج منزوع الجلد، بقوليات)',
        'دهون صحية (زيت الزيتون، مكسرات غير مملحة)',
        'ماء كافٍ على مدار اليوم',
      ]);
      avoidList.addAll([
        'الأطعمة المصنعة وعالية الملح',
        'السكريات المضافة والمشروبات الغازية',
        'الدهون المتحولة والمقلية بكثرة',
      ]);
    } else {
      doList.addAll([
        'Varied fresh vegetables and fruits',
        'Whole grains (oats, bulgur, whole wheat bread)',
        'Lean proteins (fish, skinless chicken, legumes)',
        'Healthy fats (olive oil, unsalted nuts)',
        'Adequate water intake throughout the day',
      ]);
      avoidList.addAll([
        'Processed and high-salt foods',
        'Added sugars and soft drinks',
        'Trans fats and heavily fried foods',
      ]);
    }

    // Fever/temperature
    if (temperature > 37.5) {
      if (isArabic) {
        doList.addAll([
          'شوربات خفيفة ومشروبات دافئة',
          'سوائل متكررة لتعويض الفقد',
          'وجبات صغيرة سهلة الهضم',
        ]);
        avoidList.addAll(['أطعمة دهنية وثقيلة', 'أطعمة شديدة التوابل']);
      } else {
        doList.addAll([
          'Light soups and warm beverages',
          'Frequent fluids to compensate losses',
          'Small, easily digestible meals',
        ]);
        avoidList.addAll(['Heavy fatty meals', 'Very spicy foods']);
      }
    }

    // Oxygen low
    if (spo2 > 0.0 && spo2 < 95) {
      if (isArabic) {
        doList.addAll([
          'ترطيب جيد وسوائل دافئة',
          'أطعمة مضادة للالتهاب (سمك دهني، خضروات ورقية)',
        ]);
        avoidList.addAll(['التدخين والملوثات', 'وجبات كبيرة ثقيلة']);
      } else {
        doList.addAll([
          'Good hydration and warm fluids',
          'Anti-inflammatory foods (fatty fish, leafy greens)',
        ]);
        avoidList.addAll(['Smoking and pollutants', 'Large heavy meals']);
      }
    }

    // Blood pressure
    if ((systolic > 0 || diastolic > 0) && (systolic > 140 || diastolic > 90)) {
      // Hypertensive pattern (DASH-like)
      if (isArabic) {
        doList.addAll([
          'خضروات وفواكه غنية بالبوتاسيوم',
          'ألبان قليلة الدسم',
          'تقليل الملح واستبداله بتوابل طبيعية',
        ]);
        avoidList.addAll([
          'الأطعمة المالحة والمعلبة',
          'اللحوم المصنعة والوجبات السريعة',
        ]);
      } else {
        doList.addAll([
          'Potassium-rich fruits and vegetables',
          'Low-fat dairy',
          'Reduce salt; use natural herbs/spices',
        ]);
        avoidList.addAll([
          'Salty/processed foods',
          'Processed meats and fast food',
        ]);
      }
    }

    final List<String> chronicLc = chronic
        .whereType<String>()
        .map((e) => e.trim().toLowerCase())
        .toList();
    final bool hasDiabetes = chronicLc.any(
      (c) => c.contains('سكري') || c.contains('diab'),
    );
    final bool hasHypertension = chronicLc.any(
      (c) => c.contains('ضغط') || c.contains('hypert'),
    );
    final bool hasHeart = chronicLc.any(
      (c) => c.contains('قلب') || c.contains('card') || c.contains('heart'),
    );
    final bool hasKidney = chronicLc.any(
      (c) => c.contains('كل') || c.contains('renal') || c.contains('kidney'),
    );
    final bool hasLiver = chronicLc.any(
      (c) => c.contains('كبد') || c.contains('hep') || c.contains('liver'),
    );
    final bool hasAsthma = chronicLc.any(
      (c) => c.contains('ربو') || c.contains('asthma'),
    );

    if (hasDiabetes) {
      if (isArabic) {
        doList.addAll([
          'أطعمة منخفضة المؤشر الجلايسيمي',
          'ألياف عالية (بقوليات، شوفان)',
        ]);
        avoidList.addAll([
          'السكريات البسيطة والحلويات',
          'الدقيق الأبيض والمخبوزات',
        ]);
      } else {
        doList.addAll([
          'Low glycemic index foods',
          'High-fiber (legumes, oats)',
        ]);
        avoidList.addAll([
          'Simple sugars and sweets',
          'White flour and pastries',
        ]);
      }
    }
    if (hasHypertension) {
      if (isArabic) {
        doList.add('تقليل الملح لأقصى حد');
        avoidList.add('الأطعمة عالية الصوديوم');
      } else {
        doList.add('Minimize salt intake');
        avoidList.add('High-sodium foods');
      }
    }
    if (hasHeart) {
      if (isArabic) {
        doList.addAll(['أوميغا-3 (سمك السلمون/السردين)', 'زيوت نباتية صحية']);
        avoidList.addAll(['دهون مشبعة/مهدرجة', 'وجبات مقلية']);
      } else {
        doList.addAll(['Omega-3 (salmon/sardines)', 'Healthy plant oils']);
        avoidList.addAll(['Saturated/trans fats', 'Fried meals']);
      }
    }
    if (hasKidney) {
      if (isArabic) {
        doList.addAll(['بروتين معتدل حسب توجيه الطبيب', 'الصوديوم المنخفض']);
        avoidList.addAll(['أطعمة مصنعة', 'مكملات عشبية غير موثوقة']);
      } else {
        doList.addAll(['Moderate protein per physician advice', 'Low sodium']);
        avoidList.addAll(['Processed foods', 'Unverified herbal supplements']);
      }
    }
    if (hasLiver) {
      if (isArabic) {
        doList.addAll(['وجبات خفيفة متوازنة', 'تجنب الدهون الثقيلة']);
        avoidList.addAll(['المقليات والدهون الثقيلة']);
      } else {
        doList.addAll(['Light balanced meals', 'Avoid heavy fats']);
        avoidList.addAll(['Fried and heavy-fat foods']);
      }
    }
    if (hasAsthma) {
      if (isArabic) {
        doList.addAll(['أطعمة مضادة للالتهاب', 'ترطيب جيد']);
        avoidList.addAll(['المهيجات مثل الكبريتات في بعض الأطعمة/المشروبات']);
      } else {
        doList.addAll(['Anti-inflammatory foods', 'Good hydration']);
        avoidList.addAll(['Irritants like sulfites in some foods/drinks']);
      }
    }

    // Notes-based hints
    if (notes != null && notes.trim().isNotEmpty) {
      if (isArabic) {
        doList.add('مراعاة الملاحظات السريرية الخاصة بالحالة');
      } else {
        doList.add('Respect any clinical notes specific to the case');
      }
    }

    final title = isArabic
        ? '🍽️ توصيات غذائية:\n\n'
        : '🍽️ Nutrition recommendations:\n\n';
    final recs = doList.isEmpty
        ? ''
        : (isArabic ? '✅ الموصى به:\n' : '✅ Recommended:\n') +
              doList.map((e) => '• $e').join('\n') +
              '\n\n';
    final avoids = avoidList.isEmpty
        ? ''
        : (isArabic ? '🚫 يُنصح بتقليل:\n' : '🚫 To limit/avoid:\n') +
              avoidList.map((e) => '• $e').join('\n');

    return title + recs + avoids;
  }
}
// /// قاعدة بيانات الأطعمة والمشروبات المناسبة حسب الحالة الطبية
// class MedicalNutritionGuide {
//   /// توصيات الأطعمة حسب درجة الحرارة
//   static Map<String, dynamic> getTemperatureNutrition(String status) {
//     switch (status) {
//       case 'low':
//         return {
//           'arabic': {
//             'title': 'أطعمة ومشروبات لرفع درجة الحرارة',
//             'foods': [
//               'شوربة الدجاج الساخنة',
//               'الزنجبيل والعسل',
//               'الشاي الأخضر بالليمون',
//               'الموز والمكسرات',
//               'البطاطا المسلوقة',
//               'الشوفان بالحليب الدافئ',
//             ],
//             'drinks': [
//               'الماء الدافئ بالليمون',
//               'الشاي الأحمر بالسكر',
//               'مشروب الزنجبيل',
//               'الحليب الدافئ بالعسل',
//               'عصير البرتقال الطازج',
//             ],
//             'avoid': [
//               'المشروبات الباردة',
//               'الآيس كريم',
//               'المشروبات الغازية الباردة',
//             ],
//           },
//           'english': {
//             'title': 'Foods and drinks to raise body temperature',
//             'foods': [
//               'Hot chicken soup',
//               'Ginger and honey',
//               'Green tea with lemon',
//               'Bananas and nuts',
//               'Boiled potatoes',
//               'Warm oatmeal with milk',
//             ],
//             'drinks': [
//               'Warm water with lemon',
//               'Black tea with sugar',
//               'Ginger drink',
//               'Warm milk with honey',
//               'Fresh orange juice',
//             ],
//             'avoid': ['Cold beverages', 'Ice cream', 'Cold carbonated drinks'],
//           },
//         };

//       case 'high':
//       case 'very_high':
//         return {
//           'arabic': {
//             'title': 'أطعمة ومشروبات لخفض درجة الحرارة',
//             'foods': [
//               'البطيخ والشمام',
//               'الخيار والطماطم',
//               'الموز والتفاح',
//               'الزبادي الطبيعي',
//               'الأرز الأبيض المسلوق',
//               'حساء الخضار البارد',
//             ],
//             'drinks': [
//               'الماء البارد بكثرة',
//               'ماء جوز الهند',
//               'عصير الليمون المثلج',
//               'شاي النعناع البارد',
//               'العصائر الطبيعية الباردة',
//             ],
//             'avoid': [
//               'الأطعمة الحارة والتوابل',
//               'المشروبات الساخنة',
//               'الأطعمة الدهنية',
//               'الكافيين',
//             ],
//           },
//           'english': {
//             'title': 'Foods and drinks to reduce body temperature',
//             'foods': [
//               'Watermelon and cantaloupe',
//               'Cucumber and tomatoes',
//               'Bananas and apples',
//               'Natural yogurt',
//               'Plain boiled rice',
//               'Cold vegetable soup',
//             ],
//             'drinks': [
//               'Plenty of cold water',
//               'Coconut water',
//               'Iced lemon juice',
//               'Cold mint tea',
//               'Cold natural juices',
//             ],
//             'avoid': [
//               'Spicy foods and spices',
//               'Hot beverages',
//               'Fatty foods',
//               'Caffeine',
//             ],
//           },
//         };

//       default:
//         return {
//           'arabic': {
//             'title': 'نظام غذائي متوازن للحفاظ على الصحة',
//             'foods': [
//               'الخضروات الورقية الخضراء',
//               'الفواكه الطازجة',
//               'البروتينات الخالية من الدهون',
//               'الحبوب الكاملة',
//               'المكسرات والبذور',
//               'الأسماك الغنية بالأوميغا 3',
//             ],
//             'drinks': [
//               'الماء (8-10 أكواب يومياً)',
//               'الشاي الأخضر',
//               'عصائر الفواكه الطبيعية',
//               'الحليب قليل الدسم',
//             ],
//             'avoid': [
//               'الأطعمة المصنعة',
//               'السكر المفرط',
//               'الملح الزائد',
//               'المشروبات الغازية',
//             ],
//           },
//           'english': {
//             'title': 'Balanced diet for maintaining health',
//             'foods': [
//               'Green leafy vegetables',
//               'Fresh fruits',
//               'Lean proteins',
//               'Whole grains',
//               'Nuts and seeds',
//               'Omega-3 rich fish',
//             ],
//             'drinks': [
//               'Water (8-10 glasses daily)',
//               'Green tea',
//               'Natural fruit juices',
//               'Low-fat milk',
//             ],
//             'avoid': [
//               'Processed foods',
//               'Excessive sugar',
//               'Excess salt',
//               'Carbonated drinks',
//             ],
//           },
//         };
//     }
//   }

//   /// توصيات الأطعمة حسب ضغط الدم
//   static Map<String, dynamic> getBloodPressureNutrition(String status) {
//     switch (status) {
//       case 'low':
//         return {
//           'arabic': {
//             'title': 'أطعمة لرفع ضغط الدم المنخفض',
//             'foods': [
//               'الملح بكمية معتدلة',
//               'الخبز الأسمر',
//               'اللحوم الحمراء',
//               'الجبن المملح',
//               'المخللات',
//               'المكسرات المملحة',
//             ],
//             'drinks': [
//               'القهوة (كوب واحد)',
//               'الشاي الأحمر',
//               'عصير الطماطم',
//               'المشروبات الرياضية',
//             ],
//           },
//           'english': {
//             'title': 'Foods to raise low blood pressure',
//             'foods': [
//               'Salt in moderation',
//               'Brown bread',
//               'Red meat',
//               'Salty cheese',
//               'Pickles',
//               'Salted nuts',
//             ],
//             'drinks': [
//               'Coffee (one cup)',
//               'Black tea',
//               'Tomato juice',
//               'Sports drinks',
//             ],
//           },
//         };

//       case 'high':
//       case 'prehypertension':
//         return {
//           'arabic': {
//             'title': 'أطعمة لخفض ضغط الدم المرتفع',
//             'foods': [
//               'الموز (غني بالبوتاسيوم)',
//               'الخضروات الورقية',
//               'الشوفان',
//               'التوت والفراولة',
//               'الأسماك الدهنية',
//               'الثوم والبصل',
//             ],
//             'drinks': [
//               'عصير الرمان',
//               'عصير الشمندر',
//               'الماء بكثرة',
//               'شاي الكركديه',
//               'الحليب منزوع الدسم',
//             ],
//             'avoid': [
//               'الملح الزائد',
//               'الأطعمة المصنعة',
//               'اللحوم المصنعة',
//               'المشروبات الغازية',
//             ],
//           },
//           'english': {
//             'title': 'Foods to lower high blood pressure',
//             'foods': [
//               'Bananas (rich in potassium)',
//               'Leafy vegetables',
//               'Oats',
//               'Berries and strawberries',
//               'Fatty fish',
//               'Garlic and onions',
//             ],
//             'drinks': [
//               'Pomegranate juice',
//               'Beetroot juice',
//               'Plenty of water',
//               'Hibiscus tea',
//               'Skim milk',
//             ],
//             'avoid': [
//               'Excess salt',
//               'Processed foods',
//               'Processed meats',
//               'Carbonated drinks',
//             ],
//           },
//         };

//       default:
//         return getTemperatureNutrition('normal');
//     }
//   }

//   /// توصيات الأطعمة حسب معدل ضربات القلب
//   static Map<String, dynamic> getHeartRateNutrition(String status) {
//     switch (status) {
//       case 'low':
//         return {
//           'arabic': {
//             'title': 'أطعمة لتنشيط الدورة الدموية',
//             'foods': [
//               'الشوكولاتة الداكنة',
//               'الزنجبيل',
//               'الفلفل الأحمر',
//               'المكسرات',
//               'الأفوكادو',
//               'السبانخ',
//             ],
//             'drinks': [
//               'الشاي الأخضر',
//               'القهوة (باعتدال)',
//               'عصير البرتقال',
//               'الماء بالليمون',
//             ],
//           },
//           'english': {
//             'title': 'Foods to stimulate circulation',
//             'foods': [
//               'Dark chocolate',
//               'Ginger',
//               'Red pepper',
//               'Nuts',
//               'Avocado',
//               'Spinach',
//             ],
//             'drinks': [
//               'Green tea',
//               'Coffee (in moderation)',
//               'Orange juice',
//               'Lemon water',
//             ],
//           },
//         };

//       case 'high':
//         return {
//           'arabic': {
//             'title': 'أطعمة لتهدئة معدل ضربات القلب',
//             'foods': [
//               'الموز',
//               'الشوفان',
//               'السلمون',
//               'اللوز',
//               'الخضروات الخضراء',
//               'التوت الأزرق',
//             ],
//             'drinks': [
//               'شاي البابونج',
//               'الماء البارد',
//               'عصير الكرز',
//               'الحليب منزوع الدسم',
//             ],
//             'avoid': [
//               'الكافيين',
//               'المشروبات الطاقة',
//               'الكحول',
//               'الأطعمة الحارة',
//             ],
//           },
//           'english': {
//             'title': 'Foods to calm heart rate',
//             'foods': [
//               'Bananas',
//               'Oats',
//               'Salmon',
//               'Almonds',
//               'Green vegetables',
//               'Blueberries',
//             ],
//             'drinks': [
//               'Chamomile tea',
//               'Cold water',
//               'Cherry juice',
//               'Skim milk',
//             ],
//             'avoid': ['Caffeine', 'Energy drinks', 'Alcohol', 'Spicy foods'],
//           },
//         };

//       default:
//         return getTemperatureNutrition('normal');
//     }
//   }
// }
