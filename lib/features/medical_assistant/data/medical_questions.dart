// /// الأسئلة المقترحة تلقائياً للمساعد الطبي
// class MedicalQuestions {
//   /// الأسئلة الأساسية المقترحة
//   static List<Map<String, String>> getBasicQuestions() {
//     return [
//       {
//         'question_ar': 'ما هي حالة المريض الحالية؟',
//         'question_en': 'What is the current patient condition?',
//         'type': 'patient_status',
//       },
//       {
//         'question_ar': 'ما الأطعمة والمشروبات المناسبة للمريض؟',
//         'question_en': 'What foods and drinks are suitable for the patient?',
//         'type': 'nutrition_advice',
//       },
//       {
//         'question_ar': 'ما النصائح الطبية للحالة الحالية؟',
//         'question_en': 'What medical advice for the current condition?',
//         'type': 'medical_advice',
//       },
//       {
//         'question_ar': 'ما علامات التحسن أو التدهور التي يجب مراقبتها؟',
//         'question_en':
//             'What signs of improvement or deterioration should be monitored?',
//         'type': 'monitoring_signs',
//       },
//       {
//         'question_ar': 'متى يجب طلب المساعدة الطبية الفورية؟',
//         'question_en': 'When should immediate medical help be sought?',
//         'type': 'emergency_signs',
//       },
//     ];
//   }

//   /// أسئلة متخصصة حسب الحالة
//   static List<Map<String, String>> getSpecializedQuestions(
//     List<String> conditions,
//   ) {
//     List<Map<String, String>> questions = [];

//     if (conditions.contains('fever')) {
//       questions.addAll([
//         {
//           'question_ar': 'كيف يمكن خفض درجة الحرارة بشكل طبيعي؟',
//           'question_en': 'How to reduce temperature naturally?',
//           'type': 'fever_management',
//         },
//         {
//           'question_ar': 'ما الأدوية المناسبة لخفض الحرارة؟',
//           'question_en': 'What medications are suitable for reducing fever?',
//           'type': 'fever_medication',
//         },
//       ]);
//     }

//     if (conditions.contains('hypertension')) {
//       questions.addAll([
//         {
//           'question_ar': 'كيف يمكن خفض ضغط الدم فوراً؟',
//           'question_en': 'How to reduce blood pressure immediately?',
//           'type': 'bp_emergency',
//         },
//         {
//           'question_ar': 'ما التمارين المناسبة لمرضى الضغط؟',
//           'question_en':
//               'What exercises are suitable for hypertension patients?',
//           'type': 'bp_exercise',
//         },
//       ]);
//     }

//     if (conditions.contains('tachycardia')) {
//       questions.addAll([
//         {
//           'question_ar': 'كيف يمكن تهدئة معدل ضربات القلب؟',
//           'question_en': 'How to calm the heart rate?',
//           'type': 'heart_rate_calm',
//         },
//         {
//           'question_ar': 'ما تمارين التنفس المناسبة؟',
//           'question_en': 'What breathing exercises are appropriate?',
//           'type': 'breathing_exercises',
//         },
//       ]);
//     }

//     if (conditions.contains('hypoxia')) {
//       questions.addAll([
//         {
//           'question_ar': 'كيف يمكن تحسين مستوى الأكسجين؟',
//           'question_en': 'How to improve oxygen levels?',
//           'type': 'oxygen_improvement',
//         },
//         {
//           'question_ar': 'ما وضعيات التنفس المناسبة؟',
//           'question_en': 'What are the proper breathing positions?',
//           'type': 'breathing_positions',
//         },
//       ]);
//     }

//     return questions;
//   }

//   /// أسئلة المتابعة حسب الوقت
//   static List<Map<String, String>> getFollowUpQuestions() {
//     return [
//       {
//         'question_ar': 'هل تحسنت الأعراض منذ آخر فحص؟',
//         'question_en': 'Have symptoms improved since last check?',
//         'type': 'improvement_check',
//       },
//       {
//         'question_ar': 'هل ظهرت أعراض جديدة؟',
//         'question_en': 'Have new symptoms appeared?',
//         'type': 'new_symptoms',
//       },
//       {
//         'question_ar': 'كيف كان النوم والشهية؟',
//         'question_en': 'How have sleep and appetite been?',
//         'type': 'general_wellness',
//       },
//       {
//         'question_ar': 'هل تم اتباع النصائح الطبية المقترحة؟',
//         'question_en': 'Have the recommended medical advice been followed?',
//         'type': 'compliance_check',
//       },
//     ];
//   }

//   /// أسئلة الطوارئ
//   static List<Map<String, String>> getEmergencyQuestions() {
//     return [
//       {
//         'question_ar': 'متى يجب الذهاب للمستشفى فوراً؟',
//         'question_en': 'When should you go to the hospital immediately?',
//         'type': 'hospital_emergency',
//       },
//       {
//         'question_ar': 'ما علامات الخطر التي تستدعي الإسعاف؟',
//         'question_en': 'What danger signs require calling an ambulance?',
//         'type': 'ambulance_signs',
//       },
//       {
//         'question_ar': 'كيف يتم التعامل مع الحالة حتى وصول المساعدة؟',
//         'question_en': 'How to manage the condition until help arrives?',
//         'type': 'first_aid',
//       },
//     ];
//   }

//   /// اختيار الأسئلة المناسبة حسب السياق
//   static List<Map<String, String>> getContextualQuestions(
//     Map<String, dynamic> patientData,
//     List<String> previousQuestions,
//   ) {
//     List<Map<String, String>> relevantQuestions = [];

//     // إضافة الأسئلة الأساسية
//     if (previousQuestions.isEmpty) {
//       relevantQuestions.addAll(getBasicQuestions().take(2));
//     }

//     // تحديد الحالات الطبية الحالية
//     List<String> conditions = [];
//     if (patientData['temperature'] != null) {
//       double temp = patientData['temperature'];
//       if (temp > 37.5) conditions.add('fever');
//     }

//     if (patientData['systolic'] != null && patientData['diastolic'] != null) {
//       int sys = patientData['systolic'];
//       if (sys > 140) conditions.add('hypertension');
//     }

//     if (patientData['heartRate'] != null) {
//       int hr = patientData['heartRate'];
//       if (hr > 100) conditions.add('tachycardia');
//     }

//     if (patientData['oxygenSaturation'] != null) {
//       double spo2 = patientData['oxygenSaturation'];
//       if (spo2 < 95) conditions.add('hypoxia');
//     }

//     // إضافة الأسئلة المتخصصة
//     relevantQuestions.addAll(getSpecializedQuestions(conditions));

//     // إضافة أسئلة المتابعة إذا كان هناك تاريخ للمحادثة
//     if (previousQuestions.isNotEmpty) {
//       relevantQuestions.addAll(getFollowUpQuestions().take(1));
//     }

//     // إضافة أسئلة الطوارئ إذا كانت الحالة حرجة
//     bool isCritical = conditions.any(
//       (c) => ['fever', 'hypertension', 'hypoxia'].contains(c),
//     );
//     if (isCritical) {
//       relevantQuestions.addAll(getEmergencyQuestions().take(1));
//     }

//     return relevantQuestions.take(5).toList();
//   }
// }
