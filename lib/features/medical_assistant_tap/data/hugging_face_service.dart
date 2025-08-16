import 'medical_nutrition_guide.dart';

/// خدمة المساعد الطبي المحلي المحسنة
class MedicalAssistantService {
  /// إرسال رسالة والحصول على رد ذكي مع تحليل البيانات الفعلية
  static Future<String> sendMessage(
    String message, {
    Map<String, dynamic>? patientData,
  }) async {
    // محاكاة تأخير للمعالجة
    await Future.delayed(const Duration(milliseconds: 500));

    return _generateSmartResponse(message, patientData);
  }

  /// توليد رد ذكي للمساعد الطبي مع تحليل البيانات
  static String _generateSmartResponse(
    String message,
    Map<String, dynamic>? patientData,
  ) {
    final messageLower = message.toLowerCase();

    // التحقق من اللغة العربية
    final isArabic = message.contains(RegExp(r'[\u0600-\u06FF]'));

    // تحليل البيانات الفعلية للمريض
    if (patientData != null) {
      return _analyzePatientData(message, patientData, isArabic);
    }

    // أسئلة المساعدة العامة
    if (_isHelpQuestion(messageLower)) {
      return isArabic ? 'كيف يمكنني مساعدتك؟' : 'How can I help you?';
    }

    // وصف حالة المريض
    if (_isPatientStatusQuestion(messageLower)) {
      return isArabic
          ? 'لا توجد بيانات متاحة للمريض حالياً. يرجى التأكد من اتصال الأجهزة.'
          : 'No patient data available currently. Please check device connections.';
    }

    // أسئلة التغذية بدون بيانات مريض: التزام بعدم تقديم توصيات بدون قراءة
    if (_isNutritionQuestion(messageLower)) {
      return _deviceNotConnectedMsg(isArabic);
    }

    // رد افتراضي
    return isArabic
        ? 'عذراً، لم أتمكن من فهم طلبك. يرجى توضيح السؤال.'
        : 'Sorry, I couldn\'t understand your request. Please clarify your question.';
  }

  /// تحليل البيانات الفعلية للمريض
  static String _analyzePatientData(
    String message,
    Map<String, dynamic> patientData,
    bool isArabic,
  ) {
    // Extract extended patient profile when available
    final String patientName =
        (patientData['patientName'] as String?)?.trim() ?? '';
    final int? age = patientData['age'] is int
        ? patientData['age'] as int
        : (patientData['age'] is double
              ? (patientData['age'] as double).round()
              : null);
    final String rawGender = (patientData['gender'] as String?)?.trim() ?? '';
    final String? genderNorm = _normalizeGender(rawGender);
    final String? bloodType = patientData['bloodType'] as String?;
    final List<dynamic> chronic =
        (patientData['chronicDiseases'] as List?) ?? const [];
    final String? notes = patientData['notes'] as String?;
    // Basic vitals parsing with tolerant keys
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    // Temperature
    final double temperature = _toDouble(
      patientData['temperature'] ??
          patientData['temp'] ??
          patientData['Temperature'],
    );

    // Heart rate
    final double heartRate = _toDouble(
      patientData['heartRate'] ??
          patientData['heart_rate'] ??
          patientData['hr'] ??
          patientData['pulse'] ??
          patientData['bpm'],
    );

    // Respiratory rate
    final double respiratoryRate = _toDouble(
      patientData['respiratoryRate'] ??
          patientData['resp_rate'] ??
          patientData['respiratory'] ??
          patientData['breathingRate'] ??
          patientData['rr'],
    );

    // Blood pressure (support nested structures and string like "120/80")
    int systolic = 0;
    int diastolic = 0;
    final dynamic bp = patientData['bloodPressure'] ?? patientData['bp'];
    if (bp is Map) {
      systolic = _toInt(bp['systolic']);
      diastolic = _toInt(bp['diastolic']);
    } else {
      systolic = _toInt(
        patientData['systolic'] ?? patientData['sbp'] ?? patientData['sys'],
      );
      diastolic = _toInt(
        patientData['diastolic'] ?? patientData['dbp'] ?? patientData['dia'],
      );
      final String? bpStr = (patientData['bp'] ?? patientData['bloodPressure'])
          ?.toString();
      if ((systolic == 0 || diastolic == 0) &&
          bpStr != null &&
          bpStr.contains('/')) {
        final parts = bpStr.split('/');
        if (parts.length >= 2) {
          systolic = int.tryParse(parts[0].trim()) ?? systolic;
          diastolic = int.tryParse(parts[1].trim()) ?? diastolic;
        }
      }
    }

    // SpO2
    final double spo2 = _toDouble(
      patientData['spo2'] ??
          patientData['SpO2'] ??
          patientData['oxygen'] ??
          patientData['oxygenSaturation'],
    );

    // ECG (status text or coded)
    final String ecgRaw =
        (patientData['ecg'] ??
                patientData['ECG'] ??
                patientData['ecgStatus'] ??
                patientData['ecg_status'] ??
                patientData['ecg_result'] ??
                patientData['ecgResult'] ??
                '')
            .toString();
    final String ecgStatus = _parseEcgStatus(ecgRaw);

    // Connection flags (fallback to presence of sensible values)
    final bool tempConnected =
        (patientData['tempConnected'] as bool?) ?? (temperature > 0);
    final bool hrConnected =
        (patientData['hrConnected'] as bool?) ?? (heartRate > 0);
    final bool respiratoryConnected =
        (patientData['respiratoryConnected'] as bool?) ?? (respiratoryRate > 0);
    final bool bpConnected =
        (patientData['bpConnected'] as bool?) ??
        (systolic > 0 && diastolic > 0);
    final bool spo2Connected =
        (patientData['spo2Connected'] as bool?) ?? (spo2 > 0);
    final bool ecgConnected =
        (patientData['ecgConnected'] as bool?) ?? ecgRaw.toString().isNotEmpty;

    // If no signals are connected at all, return a concise not-connected notice
    final bool anyConnected =
        tempConnected ||
        hrConnected ||
        respiratoryConnected ||
        bpConnected ||
        spo2Connected ||
        ecgConnected;
    if (!anyConnected) {
      return _deviceNotConnectedMsg(isArabic);
    }

    // Build context notes block
    final contextConsiderations = _buildContextConsiderations(
      age: age,
      gender: rawGender,
      chronic: chronic,
      notes: notes,
      isArabic: isArabic,
    );

    // Route by question intent
    final messageLower = message.toLowerCase();

    if (_isTemperatureQuestion(messageLower)) {
      return _analyzeTemperature(temperature, tempConnected, isArabic);
    }
    if (_isHeartRateQuestion(messageLower)) {
      return _analyzeHeartRate(heartRate, hrConnected, isArabic);
    }
    if (_isRespiratoryRateQuestion(messageLower)) {
      return _analyzeRespiratoryRate(
        respiratoryRate,
        respiratoryConnected,
        isArabic,
      );
    }
    if (_isBloodPressureQuestion(messageLower)) {
      return _analyzeBloodPressure(systolic, diastolic, bpConnected, isArabic);
    }
    if (_isOxygenQuestion(messageLower)) {
      return _analyzeOxygen(spo2, spo2Connected, isArabic);
    }
    if (_isVitalSignsStatusQuestion(messageLower)) {
      return _generateVitalSignsStatus(
        temperature,
        heartRate,
        systolic,
        diastolic,
        spo2,
        tempConnected,
        hrConnected,
        bpConnected,
        spo2Connected,
        isArabic,
      );
    }
    if (_isConcernsQuestion(messageLower)) {
      return _generateConcernsAnalysis(
        temperature,
        heartRate,
        systolic,
        diastolic,
        spo2,
        tempConnected,
        hrConnected,
        bpConnected,
        spo2Connected,
        isArabic,
      );
    }
    // Nutrition questions should be handled before broader medical advice
    if (_isNutritionQuestion(messageLower)) {
      // Nutrition advice based on patient data; respects top-level connection guard
      return MedicalNutritionGuide.recommend(patientData, isArabic);
    }
    if (_isMedicalAdviceQuestion(messageLower)) {
      return _generateMedicalRecommendations(
        temperature,
        heartRate,
        systolic,
        diastolic,
        spo2,
        tempConnected,
        hrConnected,
        bpConnected,
        spo2Connected,
        isArabic,
      );
    }

    // Default/general analysis: match user language (Arabic vs English)
    String evaluation;
    if (isArabic) {
      evaluation = _evaluatePatientStatusReportArabic(
        name: patientName,
        age: age,
        genderNorm: genderNorm,
        bloodType: bloodType,
        chronic: chronic,
        notes: notes,
        temperature: temperature,
        heartRate: heartRate,
        respiratoryRate: respiratoryRate,
        systolic: systolic,
        diastolic: diastolic,
        spo2: spo2,
        ecgStatus: ecgStatus,
        tempConnected: tempConnected,
        hrConnected: hrConnected,
        respiratoryConnected: respiratoryConnected,
        bpConnected: bpConnected,
        spo2Connected: spo2Connected,
        ecgConnected: ecgConnected,
      );
    } else {
      evaluation = _evaluatePatientStatusReportEnglish(
        name: patientName,
        age: age,
        bloodType: bloodType,
        chronic: chronic,
        notes: notes,
        temperature: temperature,
        heartRate: heartRate,
        respiratoryRate: respiratoryRate,
        systolic: systolic,
        diastolic: diastolic,
        spo2: spo2,
        ecgStatus: ecgStatus,
        tempConnected: tempConnected,
        hrConnected: hrConnected,
        respiratoryConnected: respiratoryConnected,
        bpConnected: bpConnected,
        spo2Connected: spo2Connected,
        ecgConnected: ecgConnected,
      );
    }

    return evaluation + contextConsiderations;
  }

  /// Unified message when no devices/signals are connected
  static String _deviceNotConnectedMsg(bool isArabic) {
    return isArabic
        ? 'الجهاز غير متصل حالياً. لن يتم تقديم أي توصيات حتى تظهر قراءة واحدة على الأقل.'
        : 'Device is not connected. No recommendations will be provided until at least one reading is available.';
  }

  /// Normalizes gender strings from various languages to 'male'/'female' when confident; otherwise returns null.
  static String? _normalizeGender(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return null;
    const maleSet = {'male', 'm', 'man', 'ذكر', 'ولد', 'رجل'};
    const femaleSet = {
      'female',
      'f',
      'woman',
      'girl',
      'أنثى',
      'انثى',
      'بنت',
      'امرأة',
      'سيدة',
    };
    if (femaleSet.contains(v)) return 'female';
    if (maleSet.contains(v)) return 'male';
    return null; // unknown or custom value
  }

  /// يبني اعتبارات سياقية تعتمد على بيانات المريض (العمر، النوع، الأمراض المزمنة، الملاحظات)
  static String _buildContextConsiderations({
    int? age,
    required String gender,
    required List<dynamic> chronic,
    String? notes,
    required bool isArabic,
  }) {
    final List<String> points = [];

    // Age-related risk
    if (age != null && age > 0) {
      if (age >= 65) {
        points.add(
          isArabic
              ? 'العمر ≥ 65: يُنصح بالحذر الزائد والمتابعة اللصيقة لأي تغيرات.'
              : 'Age ≥ 65: Use extra caution and closely monitor any changes.',
        );
      } else if (age <= 5) {
        points.add(
          isArabic
              ? 'عمر صغير: استشر الطبيب مبكراً عند وجود حرارة أو أعراض تنفسية.'
              : 'Young age: Seek early medical advice for fever or respiratory symptoms.',
        );
      }
    }

    final String g = gender.trim().toLowerCase();
    if (g == 'pregnant' || g == 'حامل') {
      points.add(
        isArabic
            ? 'حمل: راعِ إرشادات السلامة الدوائية واستشيري طبيب النساء.'
            : 'Pregnancy: Follow medication safety guidelines and consult OB/GYN.',
      );
    }

    // Normalize chronic conditions to lowercase for matching
    final List<String> chronicLc = chronic
        .whereType<String>()
        .map((e) => e.trim().toLowerCase())
        .toList();

    bool hasDiabetes = chronicLc.any(
      (c) => c.contains('سكري') || c.contains('diab') || c.contains('diabetes'),
    );
    bool hasHypertension = chronicLc.any(
      (c) =>
          c.contains('ضغط') ||
          c.contains('hypert') ||
          c.contains('blood pressure'),
    );
    bool hasHeart = chronicLc.any(
      (c) => c.contains('قلب') || c.contains('card') || c.contains('heart'),
    );
    bool hasAsthma = chronicLc.any(
      (c) => c.contains('ربو') || c.contains('asthma') || c.contains('asma'),
    );
    bool hasKidney = chronicLc.any(
      (c) => c.contains('كل') || c.contains('renal') || c.contains('kidney'),
    );
    bool hasLiver = chronicLc.any(
      (c) => c.contains('كبد') || c.contains('hep') || c.contains('liver'),
    );

    if (hasDiabetes) {
      points.add(
        isArabic
            ? 'داء السكري: راقب السكر عند وجود عدوى/حمى وقلل مخاطر الجفاف.'
            : 'Diabetes: Monitor glucose during infection/fever and prevent dehydration.',
      );
    }
    if (hasHypertension) {
      points.add(
        isArabic
            ? 'ارتفاع ضغط الدم: التزم بقياس الضغط بانتظام واتباع العلاج الموصوف.'
            : 'Hypertension: Check BP regularly and adhere to prescribed therapy.',
      );
    }
    if (hasHeart) {
      points.add(
        isArabic
            ? 'أمراض القلب: أي تسارع شديد في النبض أو ألم صدري يستلزم تقييماً عاجلاً.'
            : 'Cardiac disease: Severe tachycardia or chest pain warrants urgent evaluation.',
      );
    }
    if (hasAsthma) {
      points.add(
        isArabic
            ? 'الربو: انخفاض SpO2 أو ضيق التنفس يحتاج لخطة إنقاذ ومتابعة فورية.'
            : 'Asthma: Low SpO2 or dyspnea requires rescue plan and prompt follow-up.',
      );
    }
    if (hasKidney) {
      points.add(
        isArabic
            ? 'قصور كلوي: راقب السوائل والأدوية التي قد تؤثر على الكلى.'
            : 'Renal disease: Monitor fluids and medications with renal considerations.',
      );
    }
    if (hasLiver) {
      points.add(
        isArabic
            ? 'أمراض الكبد: انتبه لجرعات الأدوية واستشر الطبيب قبل المسكنات.'
            : 'Liver disease: Be cautious with medication dosing; consult before analgesics.',
      );
    }

    if (notes != null && notes.trim().isNotEmpty) {
      points.add(
        isArabic
            ? 'ملاحظة إكلينيكية: ${notes.trim()}'
            : 'Clinical note: ${notes.trim()}',
      );
    }

    if (points.isEmpty) return '';

    final title = isArabic
        ? '\n\n🧠 اعتبارات شخصية:\n'
        : '\n\n🧠 Personal considerations:\n';
    return title + points.map((p) => '• $p').join('\n');
  }

  // ===== Helpers for human-like phrasing =====
  static String _stateWordArabic(String? genderNorm) {
    // 'حالته' for male/unknown, 'حالتها' for female
    if (genderNorm == 'female') return 'حالتها';
    return 'حالته';
  }

  static String _ageWordArabic(String? genderNorm) {
    // 'عمره' for male/unknown, 'عمرها' for female
    if (genderNorm == 'female') return 'عمرها';
    return 'عمره';
  }

  static String _consultVerbArabic(String? genderNorm, {bool urgent = false}) {
    // 'يستشير' (male/unknown) vs 'تستشير' (female)
    final base = (genderNorm == 'female') ? 'تستشير' : 'يستشير';
    return base;
  }

  static String _enPossessivePronoun(String? genderNorm) {
    if (genderNorm == 'female') return 'her';
    if (genderNorm == 'male') return 'his';
    return 'their';
  }

  static String _toArabicDigits(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final idx = western.indexOf(ch);
      buffer.write(idx >= 0 ? eastern[idx] : ch);
    }
    return buffer.toString();
  }

  // ===== ECG parsing and Arabic report per provided rules =====
  static String _parseEcgStatus(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return '';
    if (v.contains('normal') || v.contains('طبيعي')) return 'normal';
    if (v.contains('arr') || v.contains('اضطراب')) return 'arrhythmia';
    if (v.contains('abn') ||
        v.contains('غير طبيعي') ||
        v.contains('غير طبيعيه')) {
      return 'abnormal';
    }
    return 'abnormal';
  }

  static String _ecgLabelAr(String status) {
    switch (status) {
      case 'normal':
        return 'طبيعي';
      case 'arrhythmia':
        return 'اضطراب';
      case 'abnormal':
      default:
        return 'غير طبيعي';
    }
  }

  static String _ecgLabelEn(String status) {
    switch (status) {
      case 'normal':
        return 'Normal';
      case 'arrhythmia':
        return 'Arrhythmia';
      case 'abnormal':
      default:
        return 'Abnormal';
    }
  }

  static String _evaluatePatientStatusReportArabic({
    required String name,
    int? age,
    String? genderNorm,
    String? bloodType,
    required List<dynamic> chronic,
    String? notes,
    required double temperature,
    required double heartRate,
    required double respiratoryRate,
    required int systolic,
    required int diastolic,
    required double spo2,
    required String ecgStatus,
    required bool tempConnected,
    required bool hrConnected,
    required bool respiratoryConnected,
    required bool bpConnected,
    required bool spo2Connected,
    required bool ecgConnected,
  }) {
    final String notesText = (notes ?? '').toLowerCase();
    final bool hasSevereSymptoms = RegExp(
      r'ضيق تنفس|ألم صدر|الم صدر|ازرقاق|زرق|إغماء|اغماء|فقدان وعي|تشوش|دوخة شديدة|تعرق بارد|chest pain|shortness of breath|syncope|cyanosis',
    ).hasMatch(notesText);
    final bool hasMildSymptoms = RegExp(
      r'تعب|ارهاق|إرهاق|صداع|سعال خفيف|دوخة|dizzy|fatigue|headache|cough',
    ).hasMatch(notesText);
    final bool postExercise = RegExp(
      r'بعد الرياضة|رياضة|تمرين|exercise|workout',
    ).hasMatch(notesText);

    final bool hasChronic = chronic.whereType<String>().isNotEmpty;

    int tempSev = 0;
    if (tempConnected && temperature > 0) {
      if (temperature < 35.0)
        tempSev = 3;
      else if (temperature <= 37.5)
        tempSev = 0;
      else if (temperature <= 38.5)
        tempSev = 1;
      else
        tempSev = 2;
    }

    int hrSev = 0;
    if (hrConnected && heartRate > 0) {
      if (heartRate < 50) {
        hrSev =
            (hasSevereSymptoms ||
                ecgStatus == 'abnormal' ||
                ecgStatus == 'arrhythmia')
            ? 3
            : 2;
      } else if (heartRate <= 100) {
        hrSev = 0;
      } else if (heartRate <= 120) {
        hrSev = 2;
      } else {
        hrSev = 3;
      }
    }

    int rrSev = 0;
    if (respiratoryConnected && respiratoryRate > 0) {
      if (respiratoryRate < 12)
        rrSev = 3;
      else if (respiratoryRate <= 20)
        rrSev = 0;
      else if (respiratoryRate <= 28)
        rrSev = 2;
      else
        rrSev = 3;
    }

    int spo2Sev = 0;
    if (spo2Connected && spo2 > 0) {
      if (spo2 < 90)
        spo2Sev = 3;
      else if (spo2 <= 94)
        spo2Sev = 2;
      else
        spo2Sev = 0;
    }

    int bpSev = 0;
    if (bpConnected && (systolic > 0 || diastolic > 0)) {
      if (systolic < 90 || diastolic < 60) {
        bpSev = hasSevereSymptoms ? 3 : 2;
      } else if (systolic <= 120 && diastolic <= 80) {
        bpSev = 0;
      } else if (systolic <= 140 && diastolic <= 90) {
        bpSev = 1;
      } else {
        bpSev = (systolic >= 160 || diastolic >= 100) ? 3 : 2;
      }
    }

    // Compute overall severity
    final severities = [tempSev, hrSev, rrSev, spo2Sev, bpSev];
    int maxSev = severities.fold(0, (p, c) => c > p ? c : p);
    final abnormalCount = severities.where((s) => s >= 2).length;
    if (abnormalCount >= 2 && maxSev < 3) maxSev += 1;
    if ((ecgStatus == 'abnormal' || ecgStatus == 'arrhythmia') && maxSev > 0)
      maxSev = (maxSev + 1).clamp(0, 3);
    if (hasChronic && maxSev > 0) maxSev = (maxSev + 1).clamp(0, 3);
    if (hasSevereSymptoms) maxSev = (maxSev + 1).clamp(0, 3);
    if (maxSev == 0 && (hasMildSymptoms || postExercise)) maxSev = 1;

    final String severityLabel = () {
      switch (maxSev) {
        case 3:
          return 'خطيرة جداً';
        case 2:
          return 'متوسطة';
        case 1:
          return 'بسيطة';
        default:
          return 'مستقرة';
      }
    }();

    final bool female = genderNorm == 'female';
    final String personWord = female ? 'المريضة' : 'المريض';
    final String stateWord = female ? 'حالتها' : 'حالته';
    final String namePrefix = name.isNotEmpty
        ? '$personWord $name'
        : personWord;

    // Problems: labeled readings for clarity
    final List<String> problems = [];
    if (tempSev >= 1) {
      problems.add('الحرارة: ${temperature.toStringAsFixed(1)}°م');
    }
    if (hrSev >= 1) {
      problems.add('النبض: ${heartRate.toStringAsFixed(0)}/د');
    }
    if (rrSev >= 1) {
      problems.add('التنفس: ${respiratoryRate.toStringAsFixed(0)}/د');
    }
    if (bpSev >= 1) {
      problems.add('الضغط: $systolic/$diastolic');
    }
    if (spo2Sev >= 1) {
      problems.add('الأكسجين: ${spo2.toStringAsFixed(0)}%');
    }
    if (ecgConnected && ecgStatus != 'normal') {
      problems.add('تخطيط القلب: ${_ecgLabelAr(ecgStatus)}');
    }

    final String problemsBlock = problems.isEmpty
        ? '• لا توجد مشاكل واضحة في العلامات الحيوية.'
        : problems.map((e) => '• $e').join('\n');

    String guidance;
    if (maxSev == 3) {
      guidance =
          'اذهب إلى المستشفى فوراً أو اتصل بالطوارئ، خاصة مع أي ضيق تنفس أو ألم صدر.';
    } else if (maxSev == 2) {
      guidance =
          'يُفضل زيارة الطبيب قريباً جداً ومراقبة الأعراض عن قرب خلال الساعات القادمة.';
    } else if (maxSev == 1) {
      guidance =
          'الراحة وشرب السوائل والمتابعة خلال 24–48 ساعة. زر الطبيب إذا ساءت الأعراض.';
    } else {
      guidance =
          'لا توجد مشكلة حالياً. المتابعة الدورية والمحافظة على نمط حياة صحي.';
    }

    return ('$namePrefix $stateWord $severityLabel.\n\n'
        'العلامات التي فيها مشكلة:\n$problemsBlock\n\n'
        'التوجيه:\n• $guidance');
  }

  static String _evaluatePatientStatusReportEnglish({
    required String name,
    int? age,
    String? bloodType,
    required List<dynamic> chronic,
    String? notes,
    required double temperature,
    required double heartRate,
    required double respiratoryRate,
    required int systolic,
    required int diastolic,
    required double spo2,
    required String ecgStatus,
    required bool tempConnected,
    required bool hrConnected,
    required bool respiratoryConnected,
    required bool bpConnected,
    required bool spo2Connected,
    required bool ecgConnected,
  }) {
    final String notesText = (notes ?? '').toLowerCase();
    final bool hasSevereSymptoms = RegExp(
      r'chest pain|shortness of breath|syncope|cyanosis|faint|loss of consciousness|confusion|severe dizziness|cold sweat|ألم صدر|ضيق تنفس|إغماء|ازرقاق',
    ).hasMatch(notesText);
    final bool hasMildSymptoms = RegExp(
      r'fatigue|dizzy|headache|mild cough|tired|ارهاق|تعب|دوخة|صداع|سعال خفيف',
    ).hasMatch(notesText);
    final bool postExercise = RegExp(
      r'exercise|workout|رياضة|تمرين',
    ).hasMatch(notesText);

    final bool hasChronic = chronic.whereType<String>().isNotEmpty;

    int tempSev = 0;
    if (tempConnected && temperature > 0) {
      if (temperature < 35.0)
        tempSev = 3;
      else if (temperature <= 37.5)
        tempSev = 0;
      else if (temperature <= 38.5)
        tempSev = 1;
      else
        tempSev = 2;
    }

    int hrSev = 0;
    if (hrConnected && heartRate > 0) {
      if (heartRate < 50) {
        hrSev =
            (hasSevereSymptoms ||
                ecgStatus == 'abnormal' ||
                ecgStatus == 'arrhythmia')
            ? 3
            : 2;
      } else if (heartRate <= 100) {
        hrSev = 0;
      } else if (heartRate <= 120) {
        hrSev = 2;
      } else {
        hrSev = 3;
      }
    }

    int rrSev = 0;
    if (respiratoryConnected && respiratoryRate > 0) {
      if (respiratoryRate < 12)
        rrSev = 3;
      else if (respiratoryRate <= 20)
        rrSev = 0;
      else if (respiratoryRate <= 28)
        rrSev = 2;
      else
        rrSev = 3;
    }

    int spo2Sev = 0;
    if (spo2Connected && spo2 > 0) {
      if (spo2 < 90)
        spo2Sev = 3;
      else if (spo2 <= 94)
        spo2Sev = 2;
      else
        spo2Sev = 0;
    }

    int bpSev = 0;
    if (bpConnected && (systolic > 0 || diastolic > 0)) {
      if (systolic < 90 || diastolic < 60) {
        bpSev = hasSevereSymptoms ? 3 : 2;
      } else if (systolic <= 120 && diastolic <= 80) {
        bpSev = 0;
      } else if (systolic <= 140 && diastolic <= 90) {
        bpSev = 1;
      } else {
        bpSev = (systolic >= 160 || diastolic >= 100) ? 3 : 2;
      }
    }

    // Compute overall severity
    final severities = [tempSev, hrSev, rrSev, spo2Sev, bpSev];
    int maxSev = severities.fold(0, (p, c) => c > p ? c : p);
    final abnormalCount = severities.where((s) => s >= 2).length;
    if (abnormalCount >= 2 && maxSev < 3) maxSev += 1;
    if ((ecgStatus == 'abnormal' || ecgStatus == 'arrhythmia') && maxSev > 0)
      maxSev = (maxSev + 1).clamp(0, 3);
    if (hasChronic && maxSev > 0) maxSev = (maxSev + 1).clamp(0, 3);
    if (hasSevereSymptoms) maxSev = (maxSev + 1).clamp(0, 3);
    if (maxSev == 0 && (hasMildSymptoms || postExercise)) maxSev = 1;

    final String severityLabel = () {
      switch (maxSev) {
        case 3:
          return 'very critical';
        case 2:
          return 'moderate';
        case 1:
          return 'mild';
        default:
          return 'stable';
      }
    }();

    final String personWord = 'Patient';
    final String namePrefix = name.isNotEmpty
        ? '$personWord $name'
        : 'The patient';

    // Problems: labeled readings for clarity
    final List<String> problems = [];
    if (tempSev >= 1) {
      problems.add('Temperature: ${temperature.toStringAsFixed(1)}°C');
    }
    if (hrSev >= 1) {
      problems.add('Heart rate: ${heartRate.toStringAsFixed(0)}/min');
    }
    if (rrSev >= 1) {
      problems.add(
        'Respiratory rate: ${respiratoryRate.toStringAsFixed(0)}/min',
      );
    }
    if (bpSev >= 1) {
      problems.add('Blood pressure: $systolic/$diastolic');
    }
    if (spo2Sev >= 1) {
      problems.add('SpO₂: ${spo2.toStringAsFixed(0)}%');
    }
    if (ecgConnected && ecgStatus != 'normal') {
      problems.add('ECG: ${_ecgLabelEn(ecgStatus)}');
    }

    final String problemsBlock = problems.isEmpty
        ? '• No obvious problems in vital signs.'
        : problems.map((e) => '• $e').join('\\n');

    String guidance;
    if (maxSev == 3) {
      guidance =
          'Go to the hospital immediately or call emergency, especially with any shortness of breath or chest pain.';
    } else if (maxSev == 2) {
      guidance =
          'Strongly recommended to visit a doctor very soon and monitor symptoms closely over the next hours.';
    } else if (maxSev == 1) {
      guidance =
          'Rest, drink fluids, and follow up within 24–48 hours. See a doctor if symptoms worsen.';
    } else {
      guidance =
          'No issues detected currently. Maintain periodic monitoring and a healthy lifestyle.';
    }

    final String stateWordEn = 'condition is';
    return ('$namePrefix $stateWordEn $severityLabel.\\n\\n'
        'Indicators with problems:\n$problemsBlock\\n\\n'
        'Guidance:\n• $guidance');
  }

  /// تحليل درجة الحرارة
  static String _analyzeTemperature(
    double temperature,
    bool connected,
    bool isArabic,
  ) {
    if (!connected || temperature == 0.0) {
      return isArabic
          ? 'جهاز قياس درجة الحرارة غير متصل حالياً. يرجى التحقق من الاتصال.'
          : 'Temperature sensor is not connected. Please check the connection.';
    }

    // فحص القراءات غير المنطقية
    if (temperature < 20.0 || temperature > 50.0) {
      return isArabic
          ? 'قراءة درجة الحرارة غير منطقية (${temperature.toStringAsFixed(1)}°م). تأكد من:\n• وضع الجهاز بشكل صحيح\n• عدم تعرضه للحرارة الخارجية\n• نظافة المستشعر\n• معايرة الجهاز'
          : 'Unrealistic temperature reading (${temperature.toStringAsFixed(1)}°C). Check:\n• Proper device placement\n• No external heat exposure\n• Clean sensor\n• Device calibration';
    }

    if (temperature < 36.0) {
      return isArabic
          ? 'درجة الحرارة منخفضة (${temperature.toStringAsFixed(1)}°م). قد يشير هذا إلى انخفاض في حرارة الجسم. يُنصح بالدفء ومراجعة الطبيب.'
          : 'Temperature is low (${temperature.toStringAsFixed(1)}°C). This may indicate hypothermia. Warmth and medical consultation recommended.';
    } else if (temperature >= 36.0 && temperature <= 37.5) {
      return isArabic
          ? 'درجة الحرارة طبيعية (${temperature.toStringAsFixed(1)}°م). الحالة مستقرة.'
          : 'Temperature is normal (${temperature.toStringAsFixed(1)}°C). Condition is stable.';
    } else if (temperature > 37.5 && temperature <= 38.5) {
      return isArabic
          ? 'درجة الحرارة مرتفعة قليلاً (${temperature.toStringAsFixed(1)}°م). يُنصح بالراحة ومراقبة الحالة.'
          : 'Temperature is slightly elevated (${temperature.toStringAsFixed(1)}°C). Rest and monitoring recommended.';
    } else {
      return isArabic
          ? 'درجة الحرارة مرتفعة (${temperature.toStringAsFixed(1)}°م). يجب استشارة الطبيب فوراً واستخدام خافض الحرارة.'
          : 'Temperature is high (${temperature.toStringAsFixed(1)}°C). Immediate medical consultation and fever reducer needed.';
    }
  }

  /// تحليل معدل النبض
  static String _analyzeHeartRate(
    double heartRate,
    bool connected,
    bool isArabic,
  ) {
    if (!connected || heartRate == 0.0) {
      return isArabic
          ? 'جهاز قياس معدل النبض غير متصل حالياً. يرجى التحقق من الاتصال.'
          : 'Heart rate monitor is not connected. Please check the connection.';
    }

    // فحص القراءات غير المنطقية
    if (heartRate < 30 || heartRate > 220) {
      return isArabic
          ? 'قراءة معدل النبض غير منطقية (${heartRate.toStringAsFixed(0)} ن/د). تأكد من:\n• وضع المستشعر على الإصبع بشكل صحيح\n• عدم حركة اليد أثناء القياس\n• نظافة المستشعر\n• عدم وجود طلاء أظافر'
          : 'Unrealistic heart rate reading (${heartRate.toStringAsFixed(0)} BPM). Check:\n• Proper sensor placement on finger\n• No hand movement during measurement\n• Clean sensor\n• No nail polish';
    }

    if (heartRate < 60) {
      return isArabic
          ? 'معدل النبض منخفض (${heartRate.toStringAsFixed(0)} ن/د). قد يشير إلى بطء في ضربات القلب. يُنصح بمراجعة طبيب القلب.'
          : 'Heart rate is low (${heartRate.toStringAsFixed(0)} BPM). May indicate bradycardia. Cardiology consultation recommended.';
    } else if (heartRate >= 60 && heartRate <= 100) {
      return isArabic
          ? 'معدل النبض طبيعي (${heartRate.toStringAsFixed(0)} ن/د). القلب يعمل بشكل منتظم.'
          : 'Heart rate is normal (${heartRate.toStringAsFixed(0)} BPM). Heart is functioning regularly.';
    } else if (heartRate > 100 && heartRate <= 120) {
      return isArabic
          ? 'معدل النبض مرتفع قليلاً (${heartRate.toStringAsFixed(0)} ن/د). قد يكون بسبب التوتر أو النشاط. يُنصح بالراحة.'
          : 'Heart rate is slightly elevated (${heartRate.toStringAsFixed(0)} BPM). May be due to stress or activity. Rest recommended.';
    } else {
      return isArabic
          ? 'معدل النبض مرتفع جداً (${heartRate.toStringAsFixed(0)} ن/د). يجب استشارة الطبيب فوراً.'
          : 'Heart rate is very high (${heartRate.toStringAsFixed(0)} BPM). Immediate medical consultation required.';
    }
  }

  /// تحليل معدل التنفس
  static String _analyzeRespiratoryRate(
    double respiratoryRate,
    bool connected,
    bool isArabic,
  ) {
    if (!connected || respiratoryRate == 0.0) {
      return isArabic
          ? 'جهاز قياس معدل التنفس غير متصل حالياً. يرجى التحقق من الاتصال.'
          : 'Respiratory rate sensor is not connected. Please check the connection.';
    }

    // فحص القراءات غير المنطقية
    if (respiratoryRate < 5.0 || respiratoryRate > 40.0) {
      return isArabic
          ? 'قراءة معدل التنفس غير منطقية (${respiratoryRate.toStringAsFixed(0)} ت/د). تأكد من:\n• وضع الجهاز بشكل صحيح\n• عدم وجود حركة زائدة\n• نظافة المستشعر\n• معايرة الجهاز'
          : 'Unrealistic respiratory rate reading (${respiratoryRate.toStringAsFixed(0)} BPM). Check:\n• Proper device placement\n• No excessive movement\n• Clean sensor\n• Device calibration';
    }

    if (respiratoryRate < 12) {
      return isArabic
          ? 'معدل التنفس منخفض (${respiratoryRate.toStringAsFixed(0)} ت/د). قد يشير إلى بطء في التنفس. يُنصح بمراجعة الطبيب.'
          : 'Respiratory rate is low (${respiratoryRate.toStringAsFixed(0)} BPM). May indicate bradypnea. Medical consultation recommended.';
    } else if (respiratoryRate >= 12 && respiratoryRate <= 20) {
      return isArabic
          ? 'معدل التنفس طبيعي (${respiratoryRate.toStringAsFixed(0)} ت/د). التنفس منتظم.'
          : 'Respiratory rate is normal (${respiratoryRate.toStringAsFixed(0)} BPM). Breathing is regular.';
    } else if (respiratoryRate > 20 && respiratoryRate <= 25) {
      return isArabic
          ? 'معدل التنفس مرتفع قليلاً (${respiratoryRate.toStringAsFixed(0)} ت/د). قد يكون بسبب التوتر أو النشاط. يُنصح بالراحة.'
          : 'Respiratory rate is slightly elevated (${respiratoryRate.toStringAsFixed(0)} BPM). May be due to stress or activity. Rest recommended.';
    } else {
      return isArabic
          ? 'معدل التنفس مرتفع جداً (${respiratoryRate.toStringAsFixed(0)} ت/د). يجب استشارة الطبيب فوراً.'
          : 'Respiratory rate is very high (${respiratoryRate.toStringAsFixed(0)} BPM). Immediate medical consultation required.';
    }
  }

  /// تحليل ضغط الدم
  static String _analyzeBloodPressure(
    int systolic,
    int diastolic,
    bool connected,
    bool isArabic,
  ) {
    if (!connected || (systolic == 0 && diastolic == 0)) {
      return isArabic
          ? 'جهاز قياس ضغط الدم غير متصل حالياً. يرجى التحقق من الاتصال.'
          : 'Blood pressure monitor is not connected. Please check the connection.';
    }

    // فحص القراءات غير المنطقية
    if (systolic < 50 ||
        systolic > 250 ||
        diastolic < 30 ||
        diastolic > 150 ||
        diastolic >= systolic) {
      return isArabic
          ? 'قراءة ضغط الدم غير منطقية ($systolic/$diastolic مم زئبق). تأكد من:\n• ربط الجهاز على اليد بشكل مناسب\n• عدم الحركة أثناء القياس\n• استخدام الحجم المناسب للكفة\n• الجلوس بوضعية مريحة'
          : 'Unrealistic blood pressure reading ($systolic/$diastolic mmHg). Check:\n• Proper cuff placement on arm\n• No movement during measurement\n• Correct cuff size\n• Comfortable sitting position';
    }

    if (systolic < 90 || diastolic < 60) {
      return isArabic
          ? 'ضغط الدم منخفض ($systolic/$diastolic مم زئبق). قد يسبب دوخة. يُنصح بشرب السوائل ومراجعة الطبيب.'
          : 'Blood pressure is low ($systolic/$diastolic mmHg). May cause dizziness. Fluid intake and medical consultation recommended.';
    } else if (systolic <= 120 && diastolic <= 80) {
      return isArabic
          ? 'ضغط الدم طبيعي ($systolic/$diastolic مم زئبق). الحالة مستقرة.'
          : 'Blood pressure is normal ($systolic/$diastolic mmHg). Condition is stable.';
    } else if (systolic <= 140 && diastolic <= 90) {
      return isArabic
          ? 'ضغط الدم مرتفع قليلاً ($systolic/$diastolic مم زئبق). يُنصح بتقليل الملح والراحة.'
          : 'Blood pressure is slightly elevated ($systolic/$diastolic mmHg). Reduce salt intake and rest recommended.';
    } else {
      return isArabic
          ? 'ضغط الدم مرتفع ($systolic/$diastolic مم زئبق). يجب استشارة الطبيب واتباع العلاج.'
          : 'Blood pressure is high ($systolic/$diastolic mmHg). Medical consultation and treatment required.';
    }
  }

  /// تحليل نسبة الأكسجين
  static String _analyzeOxygen(double spo2, bool connected, bool isArabic) {
    // التحقق من حالة الاتصال
    if (!connected) {
      return isArabic
          ? '⚠️ مقياس نسبة الأكسجين في الدم (SpO2) غير متاح حالياً.\n\n🔧 إرشادات الفحص:\n• تأكد من تشغيل الجهاز وشحن البطارية\n• تحقق من الاتصال اللاسلكي أو السلكي\n• ضع المستشعر على الإصبع الأوسط أو السبابة\n• امسح أي غبار أو رطوبة من المستشعر'
          : '⚠️ Blood oxygen saturation (SpO2) monitor currently unavailable.\n\n🔧 Examination Guidelines:\n• Ensure device is powered and battery charged\n• Check wireless or wired connection\n• Place sensor on middle or index finger\n• Clean any dust or moisture from sensor';
    }

    // التحقق من عدم وجود قراءة
    if (spo2 == 0.0) {
      return isArabic
          ? '📱 مقياس الأكسجين لا يُظهر قراءة حالياً.\n\n🩺 توجيهات طبية:\n• تأكد من وضع الإصبع بالكامل داخل المستشعر\n• انتظر 10-15 ثانية حتى استقرار القراءة\n• تجنب الحركة أثناء القياس\n• جرب إصبعاً آخر إذا كان الإصبع بارداً'
          : '📱 Oxygen meter showing no reading currently.\n\n🩺 Medical Instructions:\n• Ensure finger is fully inserted in sensor\n• Wait 10-15 seconds for reading stabilization\n• Avoid movement during measurement\n• Try another finger if current finger is cold';
    }

    // فحص القراءات غير الفسيولوجية (خارج النطاق الطبيعي للجسم البشري)
    if (spo2 < 70 || spo2 > 100) {
      return isArabic
          ? '⚡ قراءة غير فسيولوجية لنسبة الأكسجين: ${spo2.toStringAsFixed(0)}%\n\n🔬 تشخيص تقني متقدم:\n• نطاق القياس الطبيعي: 70-100%\n• تحقق من معايرة الجهاز\n• تأكد من نظافة العدسة الضوئية\n• تجنب الضوء المباشر على المستشعر\n• أزل طلاء الأظافر أو الأظافر الاصطناعية\n\n📋 بروتوكول إعادة القياس:\n1. اغسل اليدين وجففهما\n2. دلك الإصبع لتحسين الدورة الدموية\n3. انتظر دقيقة ثم أعد القياس'
          : '⚡ Non-physiological oxygen saturation reading: ${spo2.toStringAsFixed(0)}%\n\n🔬 Advanced Technical Diagnosis:\n• Normal measurement range: 70-100%\n• Check device calibration\n• Ensure optical lens cleanliness\n• Avoid direct light on sensor\n• Remove nail polish or artificial nails\n\n📋 Re-measurement Protocol:\n1. Wash and dry hands\n2. Massage finger to improve circulation\n3. Wait one minute then remeasure';
    }

    // التحليل الطبي المتخصص
    if (spo2 < 90) {
      return isArabic
          ? '🚨 نقص أكسجة دموية حرج: ${spo2.toStringAsFixed(0)}%\n\n⚕️ تقييم طبي عاجل:\n• الحالة تستدعي تدخلاً طبياً فورياً\n• نسبة الأكسجين أقل من المعدل الآمن\n• قد تشير لفشل تنفسي أو قصور رئوي\n\n🏥 إجراءات طوارئ:\n• اطلب المساعدة الطبية فوراً\n• ضع المريض في وضعية جلوس مريحة\n• تأكد من مجرى التنفس المفتوح\n• راقب مستوى الوعي والتنفس\n\n⚠️ علامات خطر إضافية للمراقبة:\n• ضيق تنفس شديد\n• ازرقاق الشفاه أو الأظافر\n• تسارع معدل النبض\n• تشوش أو فقدان وعي'
          : '🚨 Critical Blood Hypoxemia: ${spo2.toStringAsFixed(0)}%\n\n⚕️ Urgent Medical Assessment:\n• Condition requires immediate medical intervention\n• Oxygen saturation below safe threshold\n• May indicate respiratory failure or pulmonary insufficiency\n\n🏥 Emergency Procedures:\n• Call for immediate medical assistance\n• Position patient in comfortable sitting position\n• Ensure open airway\n• Monitor consciousness level and breathing\n\n⚠️ Additional Warning Signs to Monitor:\n• Severe shortness of breath\n• Cyanosis of lips or nails\n• Tachycardia\n• Confusion or loss of consciousness';
    } else if (spo2 >= 90 && spo2 < 95) {
      return isArabic
          ? '⚠️ نقص أكسجة دموية خفيف: ${spo2.toStringAsFixed(0)}%\n\n🩺 تحليل طبي متخصص:\n• النسبة أقل من المعدل الأمثل (≥95%)\n• قد تشير لضعف في الوظيفة الرئوية\n• تستدعي المراقبة الطبية الدقيقة\n\n💊 توصيات علاجية:\n• تقنيات التنفس العميق كل ساعة\n• الجلوس في وضعية منتصبة\n• تجنب المجهود البدني الشاق\n• شرب السوائل الدافئة\n\n📞 استشارة طبية مطلوبة:\n• مراجعة طبيب الرئة خلال 24 ساعة\n• تقييم وظائف التنفس\n• فحص غازات الدم الشرياني\n\n🔍 مراقبة مستمرة لـ:\n• تحسن أو تدهور النسبة\n• ظهور أعراض تنفسية جديدة\n• تغيرات في لون الجلد'
          : '⚠️ Mild Blood Hypoxemia: ${spo2.toStringAsFixed(0)}%\n\n🩺 Specialized Medical Analysis:\n• Level below optimal threshold (≥95%)\n• May indicate impaired pulmonary function\n• Requires careful medical monitoring\n\n💊 Therapeutic Recommendations:\n• Deep breathing techniques every hour\n• Maintain upright sitting position\n• Avoid strenuous physical exertion\n• Drink warm fluids\n\n📞 Medical Consultation Required:\n• Pulmonologist review within 24 hours\n• Pulmonary function assessment\n• Arterial blood gas analysis\n\n🔍 Continuous Monitoring for:\n• Improvement or deterioration of levels\n• New respiratory symptoms\n• Changes in skin color';
    } else if (spo2 >= 95 && spo2 <= 100) {
      return isArabic
          ? '✅ نسبة أكسجة دموية مثلى: ${spo2.toStringAsFixed(0)}%\n\n🫁 تقييم وظيفة الجهاز التنفسي:\n• النسبة ضمن المعدل الطبيعي الممتاز\n• كفاءة تبادل الغازات طبيعية\n• لا يوجد مؤشرات لقصور تنفسي\n\n📊 مؤشرات صحية إيجابية:\n• عمل رئوي سليم ومنتظم\n• دورة دموية فعالة\n• مستوى هيموجلوبين كافي\n• وظيفة قلبية رئوية متوازنة\n\n🏃‍♂️ توصيات للحفاظ على المستوى:\n• ممارسة الرياضة المنتظمة\n• تمارين التنفس اليومية\n• تجنب التدخين والملوثات\n• النوم الكافي والتغذية المتوازنة\n\n📝 ملاحظة طبية:\n• استمر في القياسات الدورية\n• راقب أي تغيرات مفاجئة\n• احتفظ بسجل القراءات'
          : '✅ Optimal Blood Oxygenation: ${spo2.toStringAsFixed(0)}%\n\n🫁 Respiratory System Function Assessment:\n• Level within excellent normal range\n• Normal gas exchange efficiency\n• No indicators of respiratory insufficiency\n\n📊 Positive Health Indicators:\n• Healthy and regular pulmonary function\n• Effective circulation\n• Adequate hemoglobin levels\n• Balanced cardiopulmonary function\n\n🏃‍♂️ Recommendations to Maintain Level:\n• Regular exercise routine\n• Daily breathing exercises\n• Avoid smoking and pollutants\n• Adequate sleep and balanced nutrition\n\n📝 Medical Note:\n• Continue periodic measurements\n• Monitor any sudden changes\n• Keep a record of readings';
    } else {
      return isArabic
          ? '❓ قراءة نسبة الأكسجين تحتاج تأكيد: ${spo2.toStringAsFixed(0)}%\n\n🔧 بروتوكول إعادة التقييم:\n• أعد القياس خلال 5 دقائق\n• استخدم إصبعاً مختلفاً\n• تأكد من دفء اليدين\n• نظف المستشعر بلطف\n\n📞 إذا استمرت النتيجة غير الواضحة:\n• استشر فني الأجهزة الطبية\n• قد تحتاج لمعايرة الجهاز'
          : '❓ Oxygen saturation reading needs confirmation: ${spo2.toStringAsFixed(0)}%\n\n🔧 Re-evaluation Protocol:\n• Remeasure within 5 minutes\n• Use a different finger\n• Ensure warm hands\n• Gently clean the sensor\n\n📞 If unclear results persist:\n• Consult medical equipment technician\n• Device may need calibration';
    }
  }

  /// تحليل شامل للحالة
  static String _generateCompleteAnalysis(
    double temperature,
    double heartRate,
    int systolic,
    int diastolic,
    double spo2,
    bool tempConnected,
    bool hrConnected,
    bool bpConnected,
    bool spo2Connected,
    String deviceId,
    bool isArabic, {
    String? name,
    int? age,
    String? genderNorm,
  }) {
    final connectedDevices = [
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
    ].where((x) => x).length;

    if (connectedDevices == 0) {
      return _deviceNotConnectedMsg(isArabic);
    }

    // تقدير مستوى الاستقرار العام
    int warningCount = 0;
    int criticalCount = 0;

    if (tempConnected && temperature > 0) {
      if (temperature > 38.5 || temperature < 35.0)
        criticalCount++;
      else if (temperature > 37.5 || temperature < 36.0)
        warningCount++;
    }
    if (hrConnected && heartRate > 0) {
      if (heartRate > 130 || heartRate < 50)
        criticalCount++;
      else if (heartRate > 100 || heartRate < 60)
        warningCount++;
    }
    if (bpConnected && (systolic > 0 || diastolic > 0)) {
      if (systolic > 160 || diastolic > 100 || systolic < 80)
        criticalCount++;
      else if (systolic > 140 || diastolic > 90)
        warningCount++;
    }
    if (spo2Connected && spo2 > 0) {
      if (spo2 < 90)
        criticalCount++;
      else if (spo2 < 95)
        warningCount++;
    }

    final String nameToUse = (name != null && name.isNotEmpty)
        ? name
        : (isArabic ? 'المريض' : 'the patient');
    final String stateWordAr = _stateWordArabic(genderNorm);

    String stabilityLine;
    if (criticalCount > 0) {
      stabilityLine = isArabic
          ? '🚨 ${nameToUse} ${stateWordAr} غير مستقرة الآن ويحتاج لتقييم طبي عاجل.'
          : '🚨 $nameToUse is unstable now and needs urgent medical evaluation.';
    } else if (warningCount > 0) {
      stabilityLine = isArabic
          ? '⚠️ ${nameToUse} ${stateWordAr} تحتاج متابعة دقيقة حالياً.'
          : '⚠️ $nameToUse needs close monitoring at the moment.';
    } else {
      stabilityLine = isArabic
          ? '✅ ${nameToUse} ${stateWordAr} مستقرة حالياً.'
          : '✅ $nameToUse is currently stable.';
    }

    // جملة إضافية تعتمد على العمر مثل: "وبناءً على عمره ٥٠ سنة ..."
    String ageConsult = '';
    if (age != null && age > 0) {
      if (criticalCount > 0 || warningCount > 0) {
        if (isArabic) {
          final ageWord = _ageWordArabic(genderNorm);
          final ageStr = _toArabicDigits(age);
          final verb = _consultVerbArabic(
            genderNorm,
            urgent: criticalCount > 0,
          );
          final mustOrShould = criticalCount > 0 ? 'يجب' : 'يُفضّل';
          final urgentWord = criticalCount > 0 ? ' فوراً' : '';
          ageConsult =
              '\n' +
              'وبناءً على $ageWord $ageStr سنة، $mustOrShould $verb الطبيب$urgentWord.';
        } else {
          final poss = _enPossessivePronoun(genderNorm);
          final mustOrShould = criticalCount > 0 ? 'must' : 'should';
          final urgentWord = criticalCount > 0 ? ' immediately' : '';
          ageConsult =
              '\n' +
              'Given $poss age of $age, $nameToUse $mustOrShould consult a doctor$urgentWord.';
        }
      }
    }

    // ملخص موجز بحسب القياسات المتاحة
    final List<String> brief = [];
    if (tempConnected) {
      final t = temperature.toStringAsFixed(1);
      brief.add(isArabic ? 'الحرارة: $t°م' : 'Temp: $t°C');
    }
    if (hrConnected) {
      final h = heartRate.toStringAsFixed(0);
      brief.add(isArabic ? 'النبض: $h/د' : 'HR: $h bpm');
    }
    if (bpConnected) {
      brief.add(
        isArabic ? 'الضغط: $systolic/$diastolic' : 'BP: $systolic/$diastolic',
      );
    }
    if (spo2Connected) {
      final s = spo2.toStringAsFixed(0);
      brief.add(isArabic ? 'الأكسجين: $s%' : 'SpO₂: $s%');
    }

    final summaryLine = brief.isEmpty
        ? ''
        : (isArabic ? 'القياسات الحالية: ' : 'Current measurements: ') +
              brief.join(isArabic ? ' • ' : ' • ');

    // توصيف إنساني قصير
    String narrative = stabilityLine + ageConsult;
    if (summaryLine.isNotEmpty) {
      narrative += '\n' + summaryLine;
    }

    // إضافة تحليل أكثر تفصيلاً بشكل بسيط
    final details = <String>[];
    details.add(
      (isArabic ? '🌡️' : '🌡️') +
          ' ' +
          _analyzeTemperature(temperature, tempConnected, isArabic),
    );
    details.add(
      (isArabic ? '❤️' : '❤️') +
          ' ' +
          _analyzeHeartRate(heartRate, hrConnected, isArabic),
    );
    details.add(
      (isArabic ? '🩺' : '🩺') +
          ' ' +
          _analyzeBloodPressure(systolic, diastolic, bpConnected, isArabic),
    );
    details.add(
      (isArabic ? '🫁' : '🫁') +
          ' ' +
          _analyzeOxygen(spo2, spo2Connected, isArabic),
    );

    narrative += '\n\n' + details.join('\n\n');

    return narrative;
  }

  /// توليد التوصيات الطبية
  static String _generateMedicalRecommendations(
    double temperature,
    double heartRate,
    int systolic,
    int diastolic,
    double spo2,
    bool tempConnected,
    bool hrConnected,
    bool bpConnected,
    bool spo2Connected,
    bool isArabic,
  ) {
    String recommendations = isArabic
        ? '💊 التوصيات الطبية:\n\n'
        : '💊 Medical Recommendations:\n\n';

    // التحقق من وجود أجهزة متصلة أولاً
    final connectedDevices = [
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
    ].where((x) => x).length;

    if (connectedDevices == 0) {
      return _deviceNotConnectedMsg(isArabic);
    }

    List<String> adviceList = [];

    // توصيات درجة الحرارة - فقط للأجهزة المتصلة
    if (tempConnected && temperature > 0.0) {
      if (temperature > 38.0) {
        adviceList.add(
          isArabic
              ? '🌡️ درجة الحرارة مرتفعة (${temperature.toStringAsFixed(1)}°م):\n• استخدم خافض حرارة (باراسيتامول أو إيبوبروفين)\n• اشرب السوائل الباردة بكثرة\n• استخدم كمادات باردة على الجبهة\n• ارتدي ملابس خفيفة\n• راقب الحرارة كل ساعتين'
              : '🌡️ Elevated temperature (${temperature.toStringAsFixed(1)}°C):\n• Use fever reducer (paracetamol or ibuprofen)\n• Drink plenty of cold fluids\n• Apply cold compress to forehead\n• Wear light clothing\n• Monitor temperature every 2 hours',
        );
      } else if (temperature < 36.0) {
        adviceList.add(
          isArabic
              ? '🌡️ درجة الحرارة منخفضة (${temperature.toStringAsFixed(1)}°م):\n• احرص على الدفء بالملابس أو البطانيات\n• اشرب المشروبات الساخنة\n• تجنب التعرض للبرد\n• راجع الطبيب إذا استمر الانخفاض'
              : '🌡️ Low temperature (${temperature.toStringAsFixed(1)}°C):\n• Keep warm with clothing or blankets\n• Drink hot beverages\n• Avoid cold exposure\n• See doctor if continues to drop',
        );
      }
    }

    // توصيات معدل النبض - فقط للأجهزة المتصلة
    if (hrConnected && heartRate > 0.0) {
      if (heartRate > 100) {
        adviceList.add(
          isArabic
              ? '❤️ معدل النبض مرتفع (${heartRate.toStringAsFixed(0)} ن/د):\n• خذ راحة كاملة وتجنب النشاط البدني\n• تجنب الكافيين والمنبهات\n• مارس تقنيات الاسترخاء والتنفس العميق\n• اشرب الماء بانتظام\n• استشر الطبيب إذا استمر الارتفاع'
              : '❤️ Elevated heart rate (${heartRate.toStringAsFixed(0)} BPM):\n• Take complete rest and avoid physical activity\n• Avoid caffeine and stimulants\n• Practice relaxation and deep breathing\n• Drink water regularly\n• Consult doctor if elevation persists',
        );
      } else if (heartRate < 60) {
        adviceList.add(
          isArabic
              ? '❤️ معدل النبض منخفض (${heartRate.toStringAsFixed(0)} ن/د):\n• استشر طبيب القلب للتقييم الشامل\n• راقب الأعراض مثل الدوخة أو الإغماء\n• تجنب النشاط الشاق حتى استشارة الطبيب\n• احتفظ بسجل لمعدل النبض'
              : '❤️ Low heart rate (${heartRate.toStringAsFixed(0)} BPM):\n• Consult cardiologist for comprehensive evaluation\n• Monitor symptoms like dizziness or fainting\n• Avoid strenuous activity until doctor consultation\n• Keep heart rate log',
        );
      }
    }

    // توصيات ضغط الدم - فقط للأجهزة المتصلة
    if (bpConnected && (systolic > 0 || diastolic > 0)) {
      if (systolic > 140 || diastolic > 90) {
        adviceList.add(
          isArabic
              ? '🩺 ضغط الدم مرتفع ($systolic/$diastolic مم زئبق):\n• قلل تناول الملح إلى أقل من 2 جرام يومياً\n• مارس الرياضة المعتدلة 30 دقيقة يومياً\n• تجنب التوتر والضغوط النفسية\n• تابع مع طبيب القلب للعلاج المناسب\n• راقب الضغط يومياً في نفس التوقيت'
              : '🩺 High blood pressure ($systolic/$diastolic mmHg):\n• Reduce salt intake to less than 2g daily\n• Exercise moderately 30 minutes daily\n• Avoid stress and psychological pressure\n• Follow up with cardiologist for appropriate treatment\n• Monitor pressure daily at same time',
        );
      } else if (systolic < 90) {
        adviceList.add(
          isArabic
              ? '🩺 ضغط الدم منخفض ($systolic/$diastolic مم زئبق):\n• اشرب المزيد من السوائل (8-10 أكواب يومياً)\n• تجنب الوقوف السريع من الجلوس أو النوم\n• ارتدي جوارب ضاغطة إذا نصح الطبيب\n• تناول وجبات صغيرة متكررة\n• استشر الطبيب لتحديد السبب'
              : '🩺 Low blood pressure ($systolic/$diastolic mmHg):\n• Drink more fluids (8-10 glasses daily)\n• Avoid sudden standing from sitting/lying\n• Wear compression socks if advised by doctor\n• Eat small frequent meals\n• Consult doctor to determine cause',
        );
      }
    }

    // توصيات الأكسجين - فقط للأجهزة المتصلة
    if (spo2Connected && spo2 > 0.0) {
      if (spo2 < 95) {
        if (spo2 < 90) {
          adviceList.add(
            isArabic
                ? '🫁 نسبة الأكسجين منخفضة خطيرة (${spo2.toStringAsFixed(0)}%):\n• اطلب المساعدة الطبية فوراً - هذه حالة طوارئ\n• اجلس في وضعية منتصبة\n• تأكد من فتح مجرى التنفس\n• لا تتحرك كثيراً وحافظ على الهدوء\n• كن مستعداً للذهاب للمستشفى'
                : '🫁 Critically low oxygen (${spo2.toStringAsFixed(0)}%):\n• Call for immediate medical help - this is an emergency\n• Sit in upright position\n• Ensure open airway\n• Minimize movement and stay calm\n• Be prepared to go to hospital',
          );
        } else {
          adviceList.add(
            isArabic
                ? '🫁 نسبة الأكسجين منخفضة (${spo2.toStringAsFixed(0)}%):\n• احرص على التهوية الجيدة في الغرفة\n• مارس تمارين التنفس العميق كل ساعة\n• اجلس في وضعية منتصبة\n• تجنب التدخين والملوثات\n• استشر طبيب الرئة خلال 24 ساعة'
                : '🫁 Low oxygen saturation (${spo2.toStringAsFixed(0)}%):\n• Ensure good room ventilation\n• Practice deep breathing exercises hourly\n• Sit in upright position\n• Avoid smoking and pollutants\n• Consult pulmonologist within 24 hours',
          );
        }
      }
    }

    // إضافة معلومات عن الأجهزة غير المتصلة
    List<String> disconnectedDevices = [];
    if (!tempConnected) {
      disconnectedDevices.add(isArabic ? 'جهاز الحرارة' : 'Temperature sensor');
    }
    if (!hrConnected) {
      disconnectedDevices.add(isArabic ? 'جهاز النبض' : 'Heart rate monitor');
    }
    if (!bpConnected) {
      disconnectedDevices.add(
        isArabic ? 'جهاز ضغط الدم' : 'Blood pressure monitor',
      );
    }
    if (!spo2Connected) {
      disconnectedDevices.add(isArabic ? 'جهاز الأكسجين' : 'Oxygen monitor');
    }

    if (disconnectedDevices.isNotEmpty) {
      recommendations += isArabic
          ? '📋 ملاحظة مهمة: الأجهزة غير المتصلة:\n• ${disconnectedDevices.join('\n• ')}\n\n'
          : '📋 Important Note: Disconnected devices:\n• ${disconnectedDevices.join('\n• ')}\n\n';
    }

    if (adviceList.isEmpty) {
      recommendations += isArabic
          ? 'جميع العلامات الحيوية المتاحة ضمن المعدل الطبيعي. 👍\n\n📝 توصيات عامة للحفاظ على الصحة:\n• حافظ على نمط حياة صحي\n• اشرب 8 أكواب ماء يومياً\n• مارس الرياضة بانتظام\n• احصل على نوم كافي (7-8 ساعات)\n• تناول طعام متوازن\n• استمر في المراقبة المنتظمة'
          : 'All available vital signs are within normal range. 👍\n\n📝 General health maintenance recommendations:\n• Maintain healthy lifestyle\n• Drink 8 glasses of water daily\n• Exercise regularly\n• Get adequate sleep (7-8 hours)\n• Eat balanced diet\n• Continue regular monitoring';
    } else {
      recommendations += adviceList.join('\n\n');
    }

    return recommendations;
  }

  /// تحليل المخاوف والتحذيرات
  static String _generateConcernsAnalysis(
    double temperature,
    double heartRate,
    int systolic,
    int diastolic,
    double spo2,
    bool tempConnected,
    bool hrConnected,
    bool bpConnected,
    bool spo2Connected,
    bool isArabic,
  ) {
    String concerns = isArabic
        ? '⚠️ تحليل المخاوف:\n\n'
        : '⚠️ Concerns Analysis:\n\n';

    // التحقق من عدد الأجهزة المتصلة أولاً
    final connectedDevices = [
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
    ].where((x) => x).length;

    // إذا لم تكن هناك أجهزة متصلة
    if (connectedDevices == 0) {
      return _deviceNotConnectedMsg(isArabic);
    }

    List<String> criticalIssues = [];
    List<String> warnings = [];

    // فحص درجة الحرارة
    if (tempConnected) {
      if (temperature > 39.0) {
        criticalIssues.add(
          isArabic
              ? '🔴 حمى شديدة - تحتاج عناية طبية فورية'
              : '🔴 High fever - requires immediate medical attention',
        );
      } else if (temperature > 38.0) {
        warnings.add(
          isArabic
              ? '🟡 حمى متوسطة - راقب عن كثب'
              : '🟡 Moderate fever - monitor closely',
        );
      } else if (temperature < 35.0) {
        criticalIssues.add(
          isArabic
              ? '🔴 انخفاض شديد في الحرارة - عناية طبية فورية'
              : '🔴 Severe hypothermia - immediate medical attention',
        );
      }
    }

    // فحص معدل النبض
    if (hrConnected) {
      if (heartRate > 130) {
        criticalIssues.add(
          isArabic
              ? '🔴 تسارع شديد في النبض - استشارة طبية فورية'
              : '🔴 Severe tachycardia - immediate medical consultation',
        );
      } else if (heartRate > 100) {
        warnings.add(
          isArabic
              ? '🟡 تسارع في النبض - مراقبة مطلوبة'
              : '🟡 Elevated heart rate - monitoring required',
        );
      } else if (heartRate < 50) {
        criticalIssues.add(
          isArabic
              ? '🔴 بطء شديد في النبض - فحص طبي فوري'
              : '🔴 Severe bradycardia - immediate medical examination',
        );
      }
    }

    // فحص ضغط الدم
    if (bpConnected) {
      if (systolic > 160 || diastolic > 100) {
        criticalIssues.add(
          isArabic
              ? '🔴 ارتفاع خطير في ضغط الدم - علاج فوري'
              : '🔴 Dangerously high blood pressure - immediate treatment',
        );
      } else if (systolic < 80) {
        criticalIssues.add(
          isArabic
              ? '🔴 انخفاض شديد في ضغط الدم - تدخل طبي فوري'
              : '🔴 Severely low blood pressure - immediate medical intervention',
        );
      }
    }

    // فحص الأكسجين
    if (spo2Connected) {
      if (spo2 < 90) {
        criticalIssues.add(
          isArabic
              ? '🔴 نقص خطير في الأكسجين - أكسجين إضافي فوري'
              : '🔴 Critical oxygen deficiency - immediate supplemental oxygen',
        );
      } else if (spo2 < 95) {
        warnings.add(
          isArabic
              ? '🟡 انخفاض في نسبة الأكسجين - مراقبة حثيثة'
              : '🟡 Low oxygen saturation - close monitoring',
        );
      }
    }

    // إضافة تحذيرات للأجهزة غير المتصلة
    List<String> disconnectedWarnings = [];
    if (!tempConnected) {
      disconnectedWarnings.add(
        isArabic
            ? '🟡 جهاز قياس الحرارة غير متصل - لا يمكن مراقبة الحمى'
            : '🟡 Temperature sensor disconnected - cannot monitor fever',
      );
    }
    if (!hrConnected) {
      disconnectedWarnings.add(
        isArabic
            ? '🟡 جهاز قياس النبض غير متصل - لا يمكن مراقبة مشاكل القلب'
            : '🟡 Heart rate monitor disconnected - cannot monitor cardiac issues',
      );
    }
    if (!bpConnected) {
      disconnectedWarnings.add(
        isArabic
            ? '🟡 جهاز ضغط الدم غير متصل - لا يمكن مراقبة ضغط الدم'
            : '🟡 Blood pressure monitor disconnected - cannot monitor BP issues',
      );
    }
    if (!spo2Connected) {
      disconnectedWarnings.add(
        isArabic
            ? '🟡 جهاز الأكسجين غير متصل - لا يمكن مراقبة مشاكل التنفس'
            : '🟡 Oxygen monitor disconnected - cannot monitor respiratory issues',
      );
    }

    // عرض النتائج
    if (criticalIssues.isNotEmpty) {
      concerns += isArabic ? '🚨 حالات طارئة:\n' : '🚨 Emergency conditions:\n';
      concerns += criticalIssues.join('\n');
      concerns += '\n\n';
    }

    if (warnings.isNotEmpty) {
      concerns += isArabic ? '⚠️ تحذيرات طبية:\n' : '⚠️ Medical warnings:\n';
      concerns += warnings.join('\n');
      concerns += '\n\n';
    }

    if (disconnectedWarnings.isNotEmpty) {
      concerns += isArabic ? '📱 مخاوف الأجهزة:\n' : '📱 Device concerns:\n';
      concerns += disconnectedWarnings.join('\n');
      concerns += '\n\n';
    }

    // الخلاصة النهائية
    if (criticalIssues.isEmpty &&
        warnings.isEmpty &&
        disconnectedWarnings.isEmpty) {
      concerns += isArabic
          ? '✅ لا توجد مخاوف حالياً. جميع الأجهزة متصلة والعلامات الحيوية ضمن المعدل الطبيعي.'
          : '✅ No current concerns. All devices connected and vital signs within normal range.';
    } else if (criticalIssues.isEmpty &&
        warnings.isEmpty &&
        disconnectedWarnings.isNotEmpty) {
      concerns += isArabic
          ? '📋 الخلاصة: لا توجد مخاوف طبية فورية، لكن هناك أجهزة غير متصلة تحتاج إصلاح.'
          : '📋 Summary: No immediate medical concerns, but disconnected devices need attention.';
    } else if (criticalIssues.isEmpty && warnings.isNotEmpty) {
      concerns += isArabic
          ? '📋 الخلاصة: لا توجد حالات طارئة، لكن هناك مؤشرات تحتاج مراقبة.'
          : '📋 Summary: No emergencies, but some indicators need monitoring.';
    } else {
      concerns += isArabic
          ? '🚨 الخلاصة: توجد حالات طبية تحتاج تدخل فوري!'
          : '🚨 Summary: Medical conditions requiring immediate intervention detected!';
    }

    return concerns;
  }

  /// حالة العلامات الحيوية
  static String _generateVitalSignsStatus(
    double temperature,
    double heartRate,
    int systolic,
    int diastolic,
    double spo2,
    bool tempConnected,
    bool hrConnected,
    bool bpConnected,
    bool spo2Connected,
    bool isArabic,
  ) {
    String status = isArabic
        ? '📈 حالة العلامات الحيوية:\n\n'
        : '📈 Vital Signs Status:\n\n';

    // حالة الاتصال
    final connectedCount = [
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
    ].where((x) => x).length;
    status += isArabic
        ? 'الأجهزة المتصلة: $connectedCount من 4\n\n'
        : 'Connected devices: $connectedCount of 4\n\n';

    // درجة الحرارة
    if (tempConnected) {
      String tempStatus = '';
      if (temperature >= 36.0 && temperature <= 37.5) {
        tempStatus = isArabic ? 'طبيعية ✅' : 'Normal ✅';
      } else if (temperature > 37.5) {
        tempStatus = isArabic ? 'مرتفعة ⚠️' : 'Elevated ⚠️';
      } else {
        tempStatus = isArabic ? 'منخفضة ⚠️' : 'Low ⚠️';
      }
      status += isArabic
          ? '🌡️ درجة الحرارة: ${temperature.toStringAsFixed(1)}°م - $tempStatus\n'
          : '🌡️ Temperature: ${temperature.toStringAsFixed(1)}°C - $tempStatus\n';
    } else {
      status += isArabic
          ? '🌡️ درجة الحرارة: غير متصل ❌\n'
          : '🌡️ Temperature: Not connected ❌\n';
    }

    // معدل النبض
    if (hrConnected) {
      String hrStatus = '';
      if (heartRate >= 60 && heartRate <= 100) {
        hrStatus = isArabic ? 'طبيعي ✅' : 'Normal ✅';
      } else if (heartRate > 100) {
        hrStatus = isArabic ? 'مرتفع ⚠️' : 'High ⚠️';
      } else {
        hrStatus = isArabic ? 'منخفض ⚠️' : 'Low ⚠️';
      }
      status += isArabic
          ? '❤️ معدل النبض: ${heartRate.toStringAsFixed(0)} ن/د - $hrStatus\n'
          : '❤️ Heart Rate: ${heartRate.toStringAsFixed(0)} BPM - $hrStatus\n';
    } else {
      status += isArabic
          ? '❤️ معدل النبض: غير متصل ❌\n'
          : '❤️ Heart Rate: Not connected ❌\n';
    }

    // ضغط الدم
    if (bpConnected) {
      String bpStatus = '';
      if (systolic <= 120 && diastolic <= 80) {
        bpStatus = isArabic ? 'طبيعي ✅' : 'Normal ✅';
      } else if (systolic > 140 || diastolic > 90) {
        bpStatus = isArabic ? 'مرتفع ⚠️' : 'High ⚠️';
      } else {
        bpStatus = isArabic ? 'حدي ⚠️' : 'Borderline ⚠️';
      }
      status += isArabic
          ? '🩺 ضغط الدم: $systolic/$diastolic مم زئبق - $bpStatus\n'
          : '🩺 Blood Pressure: $systolic/$diastolic mmHg - $bpStatus\n';
    } else {
      status += isArabic
          ? '🩺 ضغط الدم: غير متصل ❌\n'
          : '🩺 Blood Pressure: Not connected ❌\n';
    }

    // نسبة الأكسجين
    if (spo2Connected) {
      String spo2Status = '';
      if (spo2 >= 95) {
        spo2Status = isArabic ? 'طبيعية ✅' : 'Normal ✅';
      } else if (spo2 >= 90) {
        spo2Status = isArabic ? 'منخفضة ⚠️' : 'Low ⚠️';
      } else {
        spo2Status = isArabic ? 'خطيرة ⛔' : 'Critical ⛔';
      }
      status += isArabic
          ? '🫁 نسبة الأكسجين: ${spo2.toStringAsFixed(0)}% - $spo2Status\n'
          : '🫁 Oxygen Saturation: ${spo2.toStringAsFixed(0)}% - $spo2Status\n';
    } else {
      status += isArabic
          ? '🫁 نسبة الأكسجين: غير متصل ❌\n'
          : '🫁 Oxygen Saturation: Not connected ❌\n';
    }

    return status;
  }

  // دوال مساعدة للتحقق من نوع السؤال
  static bool _isHelpQuestion(String message) {
    return RegExp(
      r'help|مساعدة|كيف|how|what|ماذا|ايه|إيه',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isPatientStatusQuestion(String message) {
    return RegExp(
      r'حالة|المريض|patient|status|condition|وصف|describe|اوصف',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isGeneralAnalysisQuestion(String message) {
    return RegExp(
      r'تحليل|analysis|تقييم|assess|evaluate|قييم',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isTemperatureQuestion(String message) {
    return RegExp(
      r'temperature|حرارة|fever|سخونة|برد',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isHeartRateQuestion(String message) {
    return RegExp(
      r'heart|نبض|قلب|rate|ضربات',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isRespiratoryRateQuestion(String message) {
    return RegExp(
      r'respiratory|تنفس|breathing|breath|معدل التنفس',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isBloodPressureQuestion(String message) {
    return RegExp(
      r'pressure|ضغط|blood|دم',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isOxygenQuestion(String message) {
    return RegExp(
      r'oxygen|أكسجين|spo2|تنفس|breathing',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isMedicalAdviceQuestion(String message) {
    return RegExp(
      r'توصيات|نصائح|medical|recommendations|advice|نصيحة|توصية',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isConcernsQuestion(String message) {
    return RegExp(
      r'مخاوف|concerns|خطر|danger|تحذير|warning|مشاكل|problems',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isVitalSignsStatusQuestion(String message) {
    return RegExp(
      r'علامات حيوية|vital signs|العلامات|الحيوية|signs',
      caseSensitive: false,
    ).hasMatch(message);
  }

  static bool _isNutritionQuestion(String message) {
    return RegExp(
      r'طعام|أكل|أطعمة|غذاء|نظام غذائي|أكلات|diet|food|foods|nutrition|nutritious',
      caseSensitive: false,
    ).hasMatch(message);
  }
}

// (Removed duplicate extension with static helpers; all methods live inside the class now.)
