/// نموذج رسالة المحادثة
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// أنواع الرسائل
enum MessageType {
  text,
  patientStatus,
  nutritionAdvice,
  medicalAdvice,
  suggestedQuestion,
  emergency,
  analysis,
}

/// نموذج تحليل حالة المريض
class PatientAnalysis {
  final String patientId;
  final DateTime analysisDate;
  final VitalSignsStatus vitalSigns;
  final List<MedicalCondition> conditions;
  final String overallStatus;
  final String severity;
  final List<String> recommendations;
  final Map<String, dynamic> rawData;

  PatientAnalysis({
    required this.patientId,
    required this.analysisDate,
    required this.vitalSigns,
    required this.conditions,
    required this.overallStatus,
    required this.severity,
    required this.recommendations,
    required this.rawData,
  });

  factory PatientAnalysis.fromJson(Map<String, dynamic> json) {
    return PatientAnalysis(
      patientId: json['patientId'] ?? '',
      analysisDate: DateTime.parse(json['analysisDate']),
      vitalSigns: VitalSignsStatus.fromJson(json['vitalSigns']),
      conditions:
          (json['conditions'] as List?)
              ?.map((e) => MedicalCondition.fromJson(e))
              .toList() ??
          [],
      overallStatus: json['overallStatus'] ?? '',
      severity: json['severity'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      rawData: json['rawData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'analysisDate': analysisDate.toIso8601String(),
      'vitalSigns': vitalSigns.toJson(),
      'conditions': conditions.map((e) => e.toJson()).toList(),
      'overallStatus': overallStatus,
      'severity': severity,
      'recommendations': recommendations,
      'rawData': rawData,
    };
  }
}

/// نموذج حالة المؤشرات الحيوية
class VitalSignsStatus {
  final TemperatureStatus? temperature;
  final HeartRateStatus? heartRate;
  final BloodPressureStatus? bloodPressure;
  final OxygenSaturationStatus? oxygenSaturation;

  VitalSignsStatus({
    this.temperature,
    this.heartRate,
    this.bloodPressure,
    this.oxygenSaturation,
  });

  factory VitalSignsStatus.fromJson(Map<String, dynamic> json) {
    return VitalSignsStatus(
      temperature: json['temperature'] != null
          ? TemperatureStatus.fromJson(json['temperature'])
          : null,
      heartRate: json['heartRate'] != null
          ? HeartRateStatus.fromJson(json['heartRate'])
          : null,
      bloodPressure: json['bloodPressure'] != null
          ? BloodPressureStatus.fromJson(json['bloodPressure'])
          : null,
      oxygenSaturation: json['oxygenSaturation'] != null
          ? OxygenSaturationStatus.fromJson(json['oxygenSaturation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature?.toJson(),
      'heartRate': heartRate?.toJson(),
      'bloodPressure': bloodPressure?.toJson(),
      'oxygenSaturation': oxygenSaturation?.toJson(),
    };
  }
}

/// نموذج حالة درجة الحرارة
class TemperatureStatus {
  final double value;
  final String status;
  final String severity;
  final String description;
  final String advice;
  final String color;

  TemperatureStatus({
    required this.value,
    required this.status,
    required this.severity,
    required this.description,
    required this.advice,
    required this.color,
  });

  factory TemperatureStatus.fromJson(Map<String, dynamic> json) {
    return TemperatureStatus(
      value: json['value']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'status': status,
      'severity': severity,
      'description': description,
      'advice': advice,
      'color': color,
    };
  }
}

/// نموذج حالة معدل ضربات القلب
class HeartRateStatus {
  final int value;
  final String status;
  final String severity;
  final String description;
  final String advice;
  final String color;

  HeartRateStatus({
    required this.value,
    required this.status,
    required this.severity,
    required this.description,
    required this.advice,
    required this.color,
  });

  factory HeartRateStatus.fromJson(Map<String, dynamic> json) {
    return HeartRateStatus(
      value: json['value']?.toInt() ?? 0,
      status: json['status'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'status': status,
      'severity': severity,
      'description': description,
      'advice': advice,
      'color': color,
    };
  }
}

/// نموذج حالة ضغط الدم
class BloodPressureStatus {
  final int systolic;
  final int diastolic;
  final String status;
  final String severity;
  final String description;
  final String advice;
  final String color;

  BloodPressureStatus({
    required this.systolic,
    required this.diastolic,
    required this.status,
    required this.severity,
    required this.description,
    required this.advice,
    required this.color,
  });

  factory BloodPressureStatus.fromJson(Map<String, dynamic> json) {
    return BloodPressureStatus(
      systolic: json['systolic']?.toInt() ?? 0,
      diastolic: json['diastolic']?.toInt() ?? 0,
      status: json['status'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'status': status,
      'severity': severity,
      'description': description,
      'advice': advice,
      'color': color,
    };
  }
}

/// نموذج حالة نسبة الأكسجين
class OxygenSaturationStatus {
  final double value;
  final String status;
  final String severity;
  final String description;
  final String advice;
  final String color;

  OxygenSaturationStatus({
    required this.value,
    required this.status,
    required this.severity,
    required this.description,
    required this.advice,
    required this.color,
  });

  factory OxygenSaturationStatus.fromJson(Map<String, dynamic> json) {
    return OxygenSaturationStatus(
      value: json['value']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'status': status,
      'severity': severity,
      'description': description,
      'advice': advice,
      'color': color,
    };
  }
}

/// نموذج الحالة الطبية
class MedicalCondition {
  final String name;
  final String severity;
  final String description;
  final List<String> recommendations;
  final bool requiresImmediateAttention;

  MedicalCondition({
    required this.name,
    required this.severity,
    required this.description,
    required this.recommendations,
    required this.requiresImmediateAttention,
  });

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      name: json['name'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      requiresImmediateAttention: json['requiresImmediateAttention'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      'description': description,
      'recommendations': recommendations,
      'requiresImmediateAttention': requiresImmediateAttention,
    };
  }
}
