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
    final temperature = patientData['temperature'] as double? ?? 0.0;
    final heartRate = patientData['heartRate'] as double? ?? 0.0;
    final respiratoryRate = patientData['respiratoryRate'] as double? ?? 0.0;
    final bloodPressure =
        patientData['bloodPressure'] as Map<String, dynamic>? ?? {};
    final spo2 = patientData['spo2'] as double? ?? 0.0;
    final deviceId = patientData['deviceId'] as String? ?? '';

    final systolic = bloodPressure['systolic'] as int? ?? 0;
    final diastolic = bloodPressure['diastolic'] as int? ?? 0;

    // تحديد حالة الاتصال بطريقة أكثر دقة ومهنية
    // الجهاز متصل إذا كانت هناك قراءة معقولة أو إشارة من الجهاز
    final tempConnected = temperature > 0.0;
    final hrConnected = heartRate > 0.0;
    final respiratoryConnected = respiratoryRate > 0.0;
    final bpConnected = (systolic > 0 || diastolic > 0);
    final spo2Connected = spo2 > 0.0;

    final messageLower = message.toLowerCase();

    // أسئلة عن درجة الحرارة
    if (_isTemperatureQuestion(messageLower)) {
      return _analyzeTemperature(temperature, tempConnected, isArabic);
    }

    // أسئلة عن معدل النبض
    if (_isHeartRateQuestion(messageLower)) {
      return _analyzeHeartRate(heartRate, hrConnected, isArabic);
    }

    // أسئلة عن معدل التنفس
    if (_isRespiratoryRateQuestion(messageLower)) {
      return _analyzeRespiratoryRate(
        respiratoryRate,
        respiratoryConnected,
        isArabic,
      );
    }

    // أسئلة عن ضغط الدم
    if (_isBloodPressureQuestion(messageLower)) {
      return _analyzeBloodPressure(systolic, diastolic, bpConnected, isArabic);
    }

    // أسئلة عن الأكسجين
    if (_isOxygenQuestion(messageLower)) {
      return _analyzeOxygen(spo2, spo2Connected, isArabic);
    }

    // أسئلة عن التوصيات الطبية
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

    // أسئلة عن المخاوف
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

    // أسئلة عن حالة العلامات الحيوية
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

    // وصف حالة المريض - التحليل الشامل
    if (_isPatientStatusQuestion(messageLower) ||
        _isGeneralAnalysisQuestion(messageLower)) {
      return _generateCompleteAnalysis(
        temperature,
        heartRate,
        systolic,
        diastolic,
        spo2,
        tempConnected,
        hrConnected,
        bpConnected,
        spo2Connected,
        deviceId,
        isArabic,
      );
    }

    // تحليل عام للحالة
    return _generateCompleteAnalysis(
      temperature,
      heartRate,
      systolic,
      diastolic,
      spo2,
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
      deviceId,
      isArabic,
    );
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
    bool isArabic,
  ) {
    final connectedDevices = [
      tempConnected,
      hrConnected,
      bpConnected,
      spo2Connected,
    ].where((x) => x).length;

    if (connectedDevices == 0) {
      return isArabic
          ? 'جميع الأجهزة غير متصلة حالياً. يرجى التحقق من اتصال الجهاز رقم $deviceId وإعادة المحاولة.'
          : 'All devices are currently disconnected. Please check device $deviceId connection and try again.';
    }

    String analysis = isArabic
        ? 'تحليل شامل لحالة المريض:\n\n'
        : 'Comprehensive patient analysis:\n\n';

    // تحليل درجة الحرارة
    analysis += '🌡️ ';
    analysis += _analyzeTemperature(temperature, tempConnected, isArabic);
    analysis += '\n\n';

    // تحليل معدل النبض
    analysis += '❤️ ';
    analysis += _analyzeHeartRate(heartRate, hrConnected, isArabic);
    analysis += '\n\n';

    // تحليل ضغط الدم
    analysis += '🩺 ';
    analysis += _analyzeBloodPressure(
      systolic,
      diastolic,
      bpConnected,
      isArabic,
    );
    analysis += '\n\n';

    // تحليل الأكسجين
    analysis += '🫁 ';
    analysis += _analyzeOxygen(spo2, spo2Connected, isArabic);
    analysis += '\n\n';

    // توصيات عامة - فقط للحالات الخطيرة الفعلية
    List<bool> criticalConditions = [];

    // فحص الحالات الخطيرة فقط للأجهزة المتصلة
    if (tempConnected && temperature > 0.0) {
      criticalConditions.add(temperature > 38.5 || temperature < 35.0);
    }

    if (hrConnected && heartRate > 0.0) {
      criticalConditions.add(heartRate > 130 || heartRate < 50);
    }

    if (bpConnected && (systolic > 0 || diastolic > 0)) {
      criticalConditions.add(
        systolic > 160 || systolic < 80 || diastolic > 100,
      );
    }

    if (spo2Connected && spo2 > 0.0) {
      criticalConditions.add(spo2 < 90);
    }

    final criticalIssuesCount = criticalConditions.where((x) => x).length;

    if (criticalIssuesCount > 0) {
      analysis += isArabic
          ? '🚨 تحذير عاجل: توجد علامات حيوية تحتاج إلى عناية طبية فورية!'
          : '🚨 Urgent Warning: Vital signs requiring immediate medical attention detected!';
    } else {
      // تحديد حالة عامة بناءً على الأجهزة المتصلة
      if (connectedDevices == 4) {
        analysis += isArabic
            ? '✅ جميع العلامات الحيوية مستقرة. الحالة العامة جيدة.'
            : '✅ All vital signs are stable. Overall condition is good.';
      } else if (connectedDevices > 0) {
        analysis += isArabic
            ? '📊 العلامات الحيوية المتاحة ضمن المعدل الطبيعي. استمر في المراقبة المنتظمة.'
            : '📊 Available vital signs are within normal range. Continue regular monitoring.';
      } else {
        analysis += isArabic
            ? '📱 لا توجد بيانات متاحة حالياً. يرجى التحقق من اتصال الأجهزة.'
            : '📱 No data currently available. Please check device connections.';
      }
    }

    return analysis;
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
      return isArabic
          ? '⚠️ لا يمكن تقديم توصيات طبية حالياً.\n\n📱 السبب: جميع الأجهزة غير متصلة\n\n🔧 الحلول المطلوبة:\n• تحقق من اتصال الأجهزة الطبية\n• تأكد من شحن بطاريات الأجهزة\n• أعد تشغيل الاتصال اللاسلكي\n• راجع دليل تشغيل الأجهزة\n\n📞 للحصول على توصيات طبية دقيقة، يرجى التأكد من اتصال الأجهزة أولاً.'
          : '⚠️ Cannot provide medical recommendations currently.\n\n📱 Reason: All devices are disconnected\n\n🔧 Required Solutions:\n• Check medical device connections\n• Ensure device batteries are charged\n• Restart wireless connection\n• Review device operation manual\n\n📞 For accurate medical recommendations, please ensure devices are connected first.';
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
      return isArabic
          ? '⚠️ تحليل المخاوف:\n\n� جميع الأجهزة الطبية غير متصلة حالياً\n\n� الوضع الحالي:\n• لا توجد بيانات متاحة للتحليل\n• لا يمكن تقييم الحالة الصحية\n• المراقبة الطبية غير نشطة\n\n� خطوات بسيطة لإعادة الاتصال:\n• تحقق من تشغيل الأجهزة\n• تأكد من شحن البطاريات\n• راجع الاتصال اللاسلكي\n• أعد تشغيل الأجهزة إذا لزم الأمر\n\n📋 ملاحظة: إذا كان المريض بخير ولا يحتاج للمراقبة، فلا توجد مشكلة.'
          : '⚠️ Concerns Analysis:\n\n� All medical devices are currently disconnected\n\n� Current Status:\n• No data available for analysis\n• Cannot assess health condition\n• Medical monitoring is inactive\n\n� Simple Steps to Reconnect:\n• Check if devices are powered on\n• Ensure batteries are charged\n• Review wireless connection\n• Restart devices if necessary\n\n📋 Note: If patient is well and doesn\'t need monitoring, there\'s no problem.';
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
}
