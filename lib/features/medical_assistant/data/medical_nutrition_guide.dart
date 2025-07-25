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
