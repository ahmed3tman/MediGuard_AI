// /// تحليل المؤشرات الحيوية والنصائح الطبية
// class VitalSignsAnalysis {
//   /// تحليل درجة الحرارة
//   static Map<String, dynamic> analyzeTemperature(double temperature) {
//     if (temperature < 36.0) {
//       return {
//         'status': 'low',
//         'severity': 'warning',
//         'arabic':
//             'درجة الحرارة منخفضة ($temperature°م). قد يشير هذا إلى انخفاض حرارة الجسم.',
//         'english':
//             'Low temperature ($temperature°C). This may indicate hypothermia.',
//         'advice_ar':
//             'يُنصح بالدفء وشرب المشروبات الساخنة ومراجعة الطبيب إذا استمر الانخفاض.',
//         'advice_en':
//             'Recommend warmth, hot beverages, and medical consultation if condition persists.',
//         'color': 'blue',
//       };
//     } else if (temperature >= 36.0 && temperature <= 37.5) {
//       return {
//         'status': 'normal',
//         'severity': 'normal',
//         'arabic': 'درجة الحرارة طبيعية ($temperature°م). الجسم في حالة جيدة.',
//         'english':
//             'Normal temperature ($temperature°C). Body is in good condition.',
//         'advice_ar': 'حافظ على النظافة الشخصية واشرب كمية كافية من الماء.',
//         'advice_en': 'Maintain personal hygiene and drink adequate water.',
//         'color': 'green',
//       };
//     } else if (temperature > 37.5 && temperature <= 38.5) {
//       return {
//         'status': 'elevated',
//         'severity': 'mild',
//         'arabic':
//             'درجة الحرارة مرتفعة قليلاً ($temperature°م). قد يكون هناك التهاب خفيف.',
//         'english':
//             'Slightly elevated temperature ($temperature°C). May indicate mild inflammation.',
//         'advice_ar':
//             'راقب الحالة، اشرب السوائل، واستخدم كمادات باردة. راجع الطبيب إذا ازدادت.',
//         'advice_en':
//             'Monitor condition, increase fluid intake, use cool compresses. Consult doctor if worsens.',
//         'color': 'orange',
//       };
//     } else if (temperature > 38.5 && temperature <= 40.0) {
//       return {
//         'status': 'high',
//         'severity': 'moderate',
//         'arabic':
//             'درجة الحرارة مرتفعة ($temperature°م). يوجد التهاب يحتاج عناية طبية.',
//         'english':
//             'High temperature ($temperature°C). Inflammation requiring medical attention.',
//         'advice_ar':
//             'ضروري مراجعة الطبيب فوراً، تناول خافض حرارة، واشرب سوائل كثيرة.',
//         'advice_en':
//             'Immediate medical consultation required, take fever reducer, increase fluid intake.',
//         'color': 'red',
//       };
//     } else {
//       return {
//         'status': 'very_high',
//         'severity': 'critical',
//         'arabic':
//             'درجة الحرارة مرتفعة جداً ($temperature°م). حالة طارئة تحتاج تدخل طبي فوري!',
//         'english':
//             'Very high temperature ($temperature°C). Emergency requiring immediate medical intervention!',
//         'advice_ar':
//             'اتصل بالطوارئ فوراً! استخدم كمادات باردة واشرب سوائل باردة.',
//         'advice_en':
//             'Call emergency immediately! Use cold compresses and cold fluids.',
//         'color': 'darkred',
//       };
//     }
//   }

//   /// تحليل معدل ضربات القلب
//   static Map<String, dynamic> analyzeHeartRate(int heartRate, int age) {
//     // معدل ضربات القلب الطبيعي يختلف حسب العمر
//     int minNormal = 60;
//     int maxNormal = 100;

//     if (age < 18) {
//       minNormal = 70;
//       maxNormal = 120;
//     } else if (age > 65) {
//       minNormal = 55;
//       maxNormal = 95;
//     }

//     if (heartRate < minNormal) {
//       return {
//         'status': 'low',
//         'severity': 'warning',
//         'arabic':
//             'معدل ضربات القلب منخفض ($heartRate نبضة/دقيقة). قد يشير إلى بطء القلب.',
//         'english': 'Low heart rate ($heartRate bpm). May indicate bradycardia.',
//         'advice_ar':
//             'راقب الأعراض مثل الدوخة أو الإغماء. راجع طبيب القلب إذا استمر.',
//         'advice_en':
//             'Monitor symptoms like dizziness or fainting. Consult cardiologist if persistent.',
//         'color': 'blue',
//       };
//     } else if (heartRate >= minNormal && heartRate <= maxNormal) {
//       return {
//         'status': 'normal',
//         'severity': 'normal',
//         'arabic':
//             'معدل ضربات القلب طبيعي ($heartRate نبضة/دقيقة). القلب يعمل بانتظام.',
//         'english':
//             'Normal heart rate ($heartRate bpm). Heart functioning regularly.',
//         'advice_ar': 'حافظ على التمارين المنتظمة والنظام الغذائي الصحي.',
//         'advice_en': 'Maintain regular exercise and healthy diet.',
//         'color': 'green',
//       };
//     } else if (heartRate > maxNormal && heartRate <= maxNormal + 20) {
//       return {
//         'status': 'elevated',
//         'severity': 'mild',
//         'arabic':
//             'معدل ضربات القلب مرتفع قليلاً ($heartRate نبضة/دقيقة). قد يكون بسبب التوتر أو النشاط.',
//         'english':
//             'Slightly elevated heart rate ($heartRate bpm). May be due to stress or activity.',
//         'advice_ar': 'تجنب الكافيين والتوتر، مارس تمارين الاسترخاء.',
//         'advice_en':
//             'Avoid caffeine and stress, practice relaxation exercises.',
//         'color': 'orange',
//       };
//     } else {
//       return {
//         'status': 'high',
//         'severity': 'critical',
//         'arabic':
//             'معدل ضربات القلب مرتفع جداً ($heartRate نبضة/دقيقة). يحتاج تقييم طبي فوري!',
//         'english':
//             'Very high heart rate ($heartRate bpm). Requires immediate medical evaluation!',
//         'advice_ar': 'راجع الطبيب فوراً، تجنب المجهود البدني حتى الفحص.',
//         'advice_en':
//             'Consult doctor immediately, avoid physical exertion until examination.',
//         'color': 'red',
//       };
//     }
//   }

//   /// تحليل ضغط الدم
//   static Map<String, dynamic> analyzeBloodPressure(
//     int systolic,
//     int diastolic,
//   ) {
//     if (systolic < 90 || diastolic < 60) {
//       return {
//         'status': 'low',
//         'severity': 'warning',
//         'arabic': 'ضغط الدم منخفض ($systolic/$diastolic). قد يسبب دوخة وإغماء.',
//         'english':
//             'Low blood pressure ($systolic/$diastolic). May cause dizziness and fainting.',
//         'advice_ar': 'اشرب سوائل مالحة، تجنب الوقوف السريع، راجع الطبيب.',
//         'advice_en':
//             'Drink salty fluids, avoid sudden standing, consult doctor.',
//         'color': 'blue',
//       };
//     } else if (systolic <= 120 && diastolic <= 80) {
//       return {
//         'status': 'normal',
//         'severity': 'normal',
//         'arabic':
//             'ضغط الدم طبيعي ($systolic/$diastolic). الدورة الدموية تعمل بشكل جيد.',
//         'english':
//             'Normal blood pressure ($systolic/$diastolic). Circulation working well.',
//         'advice_ar': 'حافظ على النظام الغذائي الصحي وممارسة الرياضة.',
//         'advice_en': 'Maintain healthy diet and exercise routine.',
//         'color': 'green',
//       };
//     } else if (systolic <= 139 || diastolic <= 89) {
//       return {
//         'status': 'prehypertension',
//         'severity': 'mild',
//         'arabic':
//             'ضغط الدم مرتفع قليلاً ($systolic/$diastolic). مرحلة ما قبل ارتفاع الضغط.',
//         'english':
//             'Slightly elevated blood pressure ($systolic/$diastolic). Prehypertension stage.',
//         'advice_ar': 'قلل الملح والكافيين، مارس الرياضة، راقب الضغط يومياً.',
//         'advice_en':
//             'Reduce salt and caffeine, exercise regularly, monitor pressure daily.',
//         'color': 'orange',
//       };
//     } else {
//       return {
//         'status': 'high',
//         'severity': 'critical',
//         'arabic': 'ضغط الدم مرتفع ($systolic/$diastolic). يحتاج علاج طبي فوري!',
//         'english':
//             'High blood pressure ($systolic/$diastolic). Requires immediate medical treatment!',
//         'advice_ar': 'راجع الطبيب فوراً، تجنب الأنشطة المجهدة.',
//         'advice_en': 'Consult doctor immediately, avoid strenuous activities.',
//         'color': 'red',
//       };
//     }
//   }

//   /// تحليل نسبة الأكسجين في الدم
//   static Map<String, dynamic> analyzeOxygenSaturation(double spo2) {
//     if (spo2 < 90) {
//       return {
//         'status': 'critical',
//         'severity': 'critical',
//         'arabic': 'نسبة الأكسجين منخفضة جداً ($spo2%). حالة طارئة!',
//         'english': 'Very low oxygen saturation ($spo2%). Emergency situation!',
//         'advice_ar':
//             'اتصل بالإسعاف فوراً! اجلس في وضع مستقيم واحصل على هواء نقي.',
//         'advice_en':
//             'Call ambulance immediately! Sit upright and get fresh air.',
//         'color': 'darkred',
//       };
//     } else if (spo2 >= 90 && spo2 < 95) {
//       return {
//         'status': 'low',
//         'severity': 'warning',
//         'arabic': 'نسبة الأكسجين منخفضة ($spo2%). يحتاج متابعة طبية.',
//         'english':
//             'Low oxygen saturation ($spo2%). Requires medical follow-up.',
//         'advice_ar': 'راجع الطبيب، تجنب المجهود، احصل على راحة كاملة.',
//         'advice_en': 'Consult doctor, avoid exertion, get complete rest.',
//         'color': 'red',
//       };
//     } else if (spo2 >= 95 && spo2 <= 100) {
//       return {
//         'status': 'normal',
//         'severity': 'normal',
//         'arabic': 'نسبة الأكسجين طبيعية ($spo2%). الجهاز التنفسي يعمل بكفاءة.',
//         'english':
//             'Normal oxygen saturation ($spo2%). Respiratory system functioning efficiently.',
//         'advice_ar': 'حافظ على التنفس العميق والنشاط البدني المنتظم.',
//         'advice_en': 'Maintain deep breathing and regular physical activity.',
//         'color': 'green',
//       };
//     } else {
//       return {
//         'status': 'error',
//         'severity': 'error',
//         'arabic': 'قراءة غير صحيحة ($spo2%). تحقق من الجهاز.',
//         'english': 'Invalid reading ($spo2%). Check device.',
//         'advice_ar': 'تأكد من وضع الجهاز بشكل صحيح وأعد القياس.',
//         'advice_en': 'Ensure device is positioned correctly and remeasure.',
//         'color': 'gray',
//       };
//     }
//   }
// }
